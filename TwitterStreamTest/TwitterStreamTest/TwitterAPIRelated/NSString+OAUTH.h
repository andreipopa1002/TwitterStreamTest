//
//  NSString+OAUTH.h
//  TwitterStreamTest
//
//  Created by Andrei Popa on 20/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (OAUTH)

+ (NSString *)generateOauthNonce;
+ (NSString *)percentEncodedString: (NSString *)originalString;
+ (NSString *)generateOautTimeStamp;
+ (NSString *)hmacsha1: (NSString *)data secret: (NSString *)key;
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
                                              andRequest: (NSString *)request;

@end
