//
//  TSTTweetModel.h
//  TwitterStreamTest
//
//  Created by Andrei Popa on 22/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const TSTTweeModelLogoImageDownloaded;

@interface TSTTweetModel : NSObject
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *screenName;
@property (nonatomic, copy, readonly) NSString *postedAgo;
@property (nonatomic, copy, readonly) NSString *tweetText;
@property (atomic, strong, readonly) UIImage   *logoImage;

- (id)initWithTweetDictionary: (NSDictionary *)tweetDictionary;

@end

