//
//  NSString+OAUTH.m
//  TwitterStreamTest
//
//  Created by Andrei Popa on 20/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import "NSString+OAUTH.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation NSString (OAUTH)

+ (NSString *)generateOauthNonce {
    NSMutableString *result = [NSMutableString new];

    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int oauthNonceLength = arc4random() % 257; // I do not want a nonce longer than 256 chars
    for (int i=0; i<oauthNonceLength; i++) {
        [result appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform(NSIntegerMax) % [letters length]]];
    }
    return [NSString stringWithString: result];
}

+ (NSString *)percentEncodedString: (NSString *)originalString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                               (CFStringRef)originalString, 
                                                               NULL, 
                                                               (CFStringRef)@"!*'();: @&=+$, /?%#[]", 
                                                               kCFStringEncodingUTF8 ));
}

+ (NSString *)generateOautTimeStamp {
    return [NSString stringWithFormat: @"%f", [[NSDate date] timeIntervalSince1970]];
}

+ (NSString *)generateOauthSignatureWithOauthConsumerKey: (NSString *)consumerKey
                                              oauthNonce: (NSString *)nonce
                                    oauthSignatureMethod: (NSString *)signatureMethod
                                          oauthTimeStamp: (NSString *)timeStamp
                                              oauthToken: (NSString *)token
                                            oauthVersion: (NSString *)version
                                          consumerSecret: (NSString *)consumerSecret
                                        oauthTokenSecret: (NSString *)tokenSecret
                                           forHTTPMethod: (NSString *)httpMethod
                                             withBaseUrl: (NSString *)baseURL
                                              andRequest: (NSString *)request {
    NSMutableString *parameterString = [NSMutableString new];
    // PARAMETER STRING
    [parameterString appendFormat: @"%@=%@", [self percentEncodedString: @"oauth_consumer_key"], [self percentEncodedString: consumerKey]];
    [parameterString appendString: @"&"];
    // oauth_nonce
    [parameterString appendFormat: @"%@=%@", [self percentEncodedString: @"oauth_nonce"], [self percentEncodedString: nonce]];
    [parameterString appendString: @"&"];
    // oauth_signature_method
    [parameterString appendFormat: @"%@=%@", [self percentEncodedString: @"oauth_signature_method"], [self percentEncodedString: signatureMethod]];
    [parameterString appendString: @"&"];
    // oauth_timestamp
    [parameterString appendFormat: @"%@=%@", [self percentEncodedString: @"oauth_timestamp"], [self percentEncodedString: timeStamp]];
    [parameterString appendString: @"&"];
    // oauth_token
    [parameterString appendFormat: @"%@=%@", [self percentEncodedString: @"oauth_token"], [self percentEncodedString: token]];
    [parameterString appendString: @"&"];
    // oauth_version
    [parameterString appendFormat: @"%@=%@", [self percentEncodedString: @"oauth_version"], [self percentEncodedString: version]];
    [parameterString appendString: @"&"];
    // request
    [parameterString appendFormat: @"%@", request];
    // SIGNATURE BASE STRING
    NSMutableString *signatureBaseString = [NSMutableString new];
    // http method
    [signatureBaseString appendString: [httpMethod uppercaseString]];
    [signatureBaseString appendString: @"&"];
    // base URL
    [signatureBaseString appendString: [self percentEncodedString: baseURL]];
    [signatureBaseString appendString: @"&"];
    // parameter string
    [signatureBaseString appendString: [self percentEncodedString: parameterString]];
    // GETTING SIGNING KEY
    NSString *signingKey = [NSString stringWithFormat: @"%@&%@", [self percentEncodedString: consumerSecret], [self percentEncodedString: tokenSecret]];
    return [self percentEncodedString: [self hmacsha1: signatureBaseString secret: signingKey]];
}

# pragma mark - Internal methods

+ (NSString *)hmacsha1: (NSString *)data secret: (NSString *)key {
    const char *cKey  = [key cStringUsingEncoding: NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding: NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes: cHMAC length: sizeof(cHMAC)];
    NSString *hash = [HMAC base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
    return hash;
}

@end
