//
//  TSTTweetModel.m
//  TwitterStreamTest
//
//  Created by Andrei Popa on 22/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import "TSTTweetModel.h"
NSString *const TSTTweeModelLogoImageDownloaded = @"TSTTweeModelLogoImageDownloaded";

@interface TSTTweetModel()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *screenName;
@property (nonatomic, copy, readwrite) NSString *postedAgo;
@property (nonatomic, copy, readwrite) NSString *timeOfPost;
@property (nonatomic, copy, readwrite) NSString *tweetText;
@property (atomic, strong, readwrite) UIImage   *logoImage;

@end

@implementation TSTTweetModel
- (id)initWithTweetDictionary: (NSDictionary *)tweetDictionary {
    self = [super init];
    if (self) {
        NSDictionary *userInfo = [tweetDictionary objectForKey: @"user"];
        _name = [userInfo objectForKey: @"name"];
        _screenName = [NSString stringWithFormat: @"@%@", [userInfo objectForKey: @"screen_name"]];
        _timeOfPost = [tweetDictionary objectForKey: @"created_at"];
        _tweetText = [tweetDictionary objectForKey: @"text"];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *imageURL = [NSURL URLWithString: [userInfo objectForKey: @"profile_image_url"]];
            NSData *imageData = [NSData dataWithContentsOfURL: imageURL];
            _logoImage = [UIImage imageWithData:imageData];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TSTTweeModelLogoImageDownloaded object:nil];
            });
        });

    }
    return self;
}

- (NSString *)postedAgo {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"EE LLLL d HH:mm:ss Z yyyy"];
    NSDate *dateOfTweet = [dateFormat dateFromString: self.timeOfPost];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSSecondCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit
                                               fromDate: dateOfTweet toDate: [NSDate date] options: 0];
    NSString *result = nil;
    /* for some reason it seems that sometimes the time received from the server is into the future comparing to the current time
     in order to achieve a pleasant aspect we will show to the user the absolute value of our result */
    if ([components month]) {
        result = [NSString stringWithFormat: @"Posted %d month(s) ago.", abs([components month])];
    } else if ([components day]) {
        result = [NSString stringWithFormat: @"Posted %d day(s) ago.", abs([components day])];
    } else if ([components hour]) {
        if ([components minute]) {
            result = [NSString stringWithFormat: @"Posted %d hour(s) and %d minute(s) ago.", abs([components hour]), abs([components minute])];
        } else {
            result = [NSString stringWithFormat: @"Posted %d hour(s) ago.", abs([components hour])];
        }
    } else if ([components minute]) {
        result = [NSString stringWithFormat: @"Posted %d minute(s) ago", abs([components minute])];
    } else if ([components second]) {
        result = [NSString stringWithFormat: @"Posted %d second(s) ago.", abs([components second])];
    } else {
        result = @"Posted less than a second ago.";
    }
    return result;
}


@end
