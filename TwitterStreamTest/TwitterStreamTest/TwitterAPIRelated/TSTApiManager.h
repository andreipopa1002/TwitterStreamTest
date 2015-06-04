//
//  TSTApiManager.h
//  TwitterStreamTest
//
//  Created by Andrei Popa on 20/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ApiManagerStateNA, 
    ApiManagerStateReceivingStream, 
    ApiManagerStateStoped
} ApiManagerState;

@interface TSTApiManager : NSObject

@property (nonatomic, strong, readonly) NSDictionary    *newestTweet;
@property (nonatomic, assign, readonly) ApiManagerState state;
@property (nonatomic, assign, readonly) NSUInteger      httpCode;

- (void)startFetchingFeed;
- (void)stopFetchingFeed;

@end
