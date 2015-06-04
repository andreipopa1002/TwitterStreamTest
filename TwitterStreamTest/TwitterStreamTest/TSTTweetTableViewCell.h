//
//  TSTTweetTableViewCell.h
//  TwitterStreamTest
//
//  Created by Andrei Popa on 20/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSTTweetTableViewCell : UITableViewCell
@property (nonatomic, strong, readwrite) UIImage *logoImage;
@property (nonatomic, copy, readwrite) NSString  *name;
@property (nonatomic, copy, readwrite) NSString  *screenName;
@property (nonatomic, copy, readwrite) NSString  *tweetText;
@property (nonatomic, copy, readwrite) NSString  *postedAgo;
@property (nonatomic, assign, readonly) CGFloat  cellNecessaryHeight;

@end
