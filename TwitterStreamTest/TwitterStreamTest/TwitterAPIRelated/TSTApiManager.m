//
//  TSTApiManager.m
//  TwitterStreamTest
//
//  Created by Andrei Popa on 20/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import "TSTApiManager.h"
#import "NSString+OAUTH.h"

NSString *const APIBaseURL        = @"https://stream.twitter.com/1.1/statuses/filter.json";
NSString *const APIFetchURLFilter = @"track=banking";

// next constats should not be made public
#warning Add appropriate values for the next constants in order to run the app https://apps.twitter.com/
NSString *const ApiKey            = @"";
NSString *const ApiSecret         = @"";
NSString *const AccessToken       = @"";
NSString *const AccessTokenSecret = @"";
NSString *const SignatureMethod   = @"HMAC-SHA1";

@interface TSTApiManager() <NSURLConnectionDataDelegate>
@property (nonatomic, strong, readwrite) NSDictionary    *newestTweet;
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, strong, readwrite) NSMutableData   *responseData;
@property (nonatomic, assign, readwrite) ApiManagerState state;
@property (nonatomic, assign, readwrite) NSUInteger      httpCode;

// oauth related properties
@property (nonatomic, copy, readwrite) NSString *oauthNonce;
@property (nonatomic, copy, readwrite) NSString *oauthTimeStamp;


- (NSString *)authorizationHeaderForHTTPMethod: (NSString *)httpMethod;

@end

@implementation TSTApiManager

- (id)init {
    self = [super init];
    if (self) {
        // do initialization
        _responseData = [NSMutableData new];
        _state = ApiManagerStateNA;
        _httpCode = 0;
    }
    return self;
}
# pragma mark - Internal Methods
- (NSString *)authorizationHeaderForHTTPMethod: (NSString *)httpMethod {
    NSMutableString *result = [NSMutableString stringWithFormat: @"OAuth "];
    self.oauthNonce = [NSString generateOauthNonce];
    self.oauthTimeStamp = [NSString generateOautTimeStamp];
    NSString *signature = [NSString generateOauthSignatureWithOauthConsumerKey: ApiKey
                                                                    oauthNonce: self.oauthNonce
                                                          oauthSignatureMethod: SignatureMethod
                                                                oauthTimeStamp: self.oauthTimeStamp
                                                                    oauthToken: AccessToken
                                                                  oauthVersion: @"1.0"
                                                                consumerSecret: ApiSecret
                                                              oauthTokenSecret: AccessTokenSecret
                                                                 forHTTPMethod: httpMethod
                                                                   withBaseUrl: APIBaseURL
                           andRequest: APIFetchURLFilter];
    
    [result appendFormat: @"oauth_consumer_key=\"%@\", ", ApiKey];
    [result appendFormat: @"oauth_nonce=\"%@\", ", self.oauthNonce];
    [result appendFormat: @"oauth_signature=\"%@\", ", signature];
    [result appendFormat: @"oauth_signature_method=\"%@\", ",SignatureMethod];
    [result appendFormat: @"oauth_timestamp=\"%@\", ", self.oauthTimeStamp];
    [result appendFormat: @"oauth_token=\"%@\", ", AccessToken];
    [result appendString: @"oauth_version=\"1.0\""];
    return [NSString stringWithString: result];
}

# pragma mark - External Methods
- (void)startFetchingFeed {
    NSLog(@"Starting new fetching feed ");
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"%@?%@", APIBaseURL, APIFetchURLFilter]]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30;
    [request addValue: [self authorizationHeaderForHTTPMethod: request.HTTPMethod] forHTTPHeaderField: @"Authorization"];
    
    self.connection = [[NSURLConnection alloc] initWithRequest: request
                                                      delegate: self
                                              startImmediately: YES];
    self.state = ApiManagerStateReceivingStream;
}

- (void)stopFetchingFeed {
    NSLog(@"Fetching stopped by request");
    [self.connection cancel];
    self.state = ApiManagerStateStoped;
}

# pragma mark - NSURLConnection Delegate methods
- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    self.httpCode = [(NSHTTPURLResponse*)response statusCode];
}

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
    NSError *error = nil;
    [self.responseData appendData: data];
    NSJSONSerialization *receivedJson = [NSJSONSerialization JSONObjectWithData: self.responseData
                                                                options: NSJSONReadingAllowFragments
                                                                  error: &error];
    if (receivedJson && [receivedJson isKindOfClass: [NSDictionary class]]) {
        self.newestTweet = (NSDictionary *)receivedJson;
        self.responseData = [NSMutableData new];
    }
}

- (NSCachedURLResponse *)connection: (NSURLConnection *)connection willCacheResponse: (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {
    self.state = ApiManagerStateStoped;
    NSLog(@"connection did failed with error: %@", error);
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection {
    // the coneection should never finish, if this happens probably it should restart
    self.state = ApiManagerStateStoped;
    NSLog(@"connection did finished loading: %@", connection);
}

@end
