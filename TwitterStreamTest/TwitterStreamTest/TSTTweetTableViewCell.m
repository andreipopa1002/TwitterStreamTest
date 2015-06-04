//
//  TSTTweetTableViewCell.m
//  TwitterStreamTest
//
//  Created by Andrei Popa on 20/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import "TSTTweetTableViewCell.h"

CGFloat const CellTopBottomLeftRightPadding                    = 10.0;
CGFloat const LabelsRightAndBetweenPadding                     = 5.0;
CGFloat const LogoImageWidthHeight                             = 48.0;
CGFloat const NameLabelHeight                                  = 16.0;
CGFloat const ScreenNameLabelAndPostedAgoLabelHeight           = 11.0;
CGFloat const NameLabelFontSize                                = 15.0;
CGFloat const ScreenNameLabelAndPostedAgoLabelFontSize         = 10.0;
CGFloat const TweetTextViewMaxHeight                           = 100.0;

/* CELL DESIGN
 +--+-----------------------------------------------------+-+
 |  +-----------------------------------------------------+ |
 |  |               |FirstName LastName  (Bold text)      | |
 |  |               +-------------------------------------+ |
 |  |     Logo      +-------------------------------------+ |
 |  |     Image     |ScreenName                           | |
 |  |     48X48     +-------------------------------------+ |
 |  |               +-------------------------------------+ |
 |  |               |Posted ......... ago                 | |
 |  +-----------------------------------------------------+ |
 |  +-----------------------------------------------------+ |
 |  |                                                     | |
 |  |                                                     | |
 |  |                                                     | |
 |  |  Tweet text                                         | |
 |  |                                                     | |
 |  |                                                     | |
 |  |                                                     | |
 |  |                                                     | |
 |  |                                                     | |
 |  +-----------------------------------------------------+ |
 +--+-----------------------------------------------------+-+
 
 | - cell width should be screen width
 | - logo Image should mentain a left and top padding of 10 pt
 | - namelabel, screenNameLabel and postedAgoLabel should maintain a left
 | - top padding for nameLable should be 10pt
 | - top padding for screenNameLabel and posted ago Label should be 5pts
 | - left & right pading for tweetTextView should be 10pts
 | - top & bottom padding for tweetTextView should be 5pts
 | - tweetTextView should not be scrolable unless it exceeds the height of 200pts, in this case it will be scrollable
 | - 
 */

@interface TSTTweetTableViewCell()
//@property (nonatomic, strong, readwrite) UIActivityIndicatorView *logoImageSpinner;
@property (nonatomic, strong, readwrite) UIImageView *logoImageView;
@property (nonatomic, strong, readwrite) UILabel     *nameLabel;
@property (nonatomic, strong, readwrite) UILabel     *screenNameLabel;
@property (nonatomic, strong, readwrite) UITextView  *tweetTextView;
@property (nonatomic, strong, readwrite) UILabel     *postedAgoLabel;

@property (nonatomic, assign, readwrite) CGFloat cellNecessaryHeight;

@end

@implementation TSTTweetTableViewCell

- (id)initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self) {
        // Initialization code
        // logoImageView
        _logoImageView = [[UIImageView alloc] initWithFrame: CGRectMake(CellTopBottomLeftRightPadding,
                                                                       CellTopBottomLeftRightPadding, 
                                                                       LogoImageWidthHeight, 
                                                                       LogoImageWidthHeight)];
        [self.contentView addSubview: _logoImageView];
        // nameLabel
        _nameLabel = [[UILabel alloc] initWithFrame: CGRectMake(CellTopBottomLeftRightPadding + _logoImageView.frame.size.width + LabelsRightAndBetweenPadding, 
                                                               CellTopBottomLeftRightPadding, 
                                                               self.bounds.size.width - _logoImageView.frame.size.width - (CellTopBottomLeftRightPadding * 2) - LabelsRightAndBetweenPadding, 
                                                               NameLabelHeight)];
        _nameLabel.font = [UIFont boldSystemFontOfSize: NameLabelFontSize];
        _nameLabel.text = @"Name";
        [self.contentView addSubview: _nameLabel];
        // screenNameLabel
        _screenNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(_nameLabel.frame.origin.x, 
                                                                     _nameLabel.frame.origin.y + _nameLabel.frame.size.height + LabelsRightAndBetweenPadding, 
                                                                     _nameLabel.frame.size.width, 
                                                                     ScreenNameLabelAndPostedAgoLabelHeight)];
        _screenNameLabel.font = [UIFont italicSystemFontOfSize: ScreenNameLabelAndPostedAgoLabelFontSize];
        _screenNameLabel.textColor = [UIColor grayColor];
        _screenNameLabel.text = @"ScreenName";
        [self.contentView addSubview: _screenNameLabel];
        // postedAgoLabel
        _postedAgoLabel = [[UILabel alloc] initWithFrame: CGRectMake(_screenNameLabel.frame.origin.x, 
                                                                    _screenNameLabel.frame.origin.y + _screenNameLabel.frame.size.height + LabelsRightAndBetweenPadding, 
                                                                    _screenNameLabel.frame.size.width, 
                                                                    ScreenNameLabelAndPostedAgoLabelHeight)];
        _postedAgoLabel.font = [UIFont systemFontOfSize: ScreenNameLabelAndPostedAgoLabelFontSize];
        _postedAgoLabel.text = @"Posted some time ago";
        [self.contentView addSubview: _postedAgoLabel];
        // tweetTextView
        _tweetTextView = [[UITextView alloc] initWithFrame: CGRectMake(CellTopBottomLeftRightPadding, 
                                                                      CellTopBottomLeftRightPadding + _logoImageView.frame.size.height + LabelsRightAndBetweenPadding, 
                                                                      self.bounds.size.width - 2 * CellTopBottomLeftRightPadding, 
                                                                      TweetTextViewMaxHeight)];
        _tweetTextView.text = @"tweeeeeeeeeet";
        _tweetTextView.editable = NO;
        _tweetTextView.scrollEnabled = YES;
        _tweetTextView.contentInset = UIEdgeInsetsMake(-8, -4, 0, 0);
        _cellNecessaryHeight = TweetTextViewMaxHeight;
        [self.contentView addSubview: _tweetTextView];
    }
    return self;
}

- (void)setSelected: (BOOL)selected animated: (BOOL)animated
{
    [super setSelected: selected animated: animated];

    // Configure the view for the selected state
}

#pragma mark - Setters & Getters

- (CGFloat)cellNecessaryHeight {
    CGFloat necessaryHeight = 0.0;
    necessaryHeight = necessaryHeight + CellTopBottomLeftRightPadding + LogoImageWidthHeight + LabelsRightAndBetweenPadding + CellTopBottomLeftRightPadding; // at this point we have the height that is not going to change
    // we need to compute the height for the variable part of the cell => the tweetTextView
    CGRect textNecessaryRect = [self.tweetTextView.text boundingRectWithSize: CGSizeMake(self.tweetTextView.bounds.size.width, NSUIntegerMax)
                                                                     options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                  attributes: @{NSFontAttributeName: self.tweetTextView.font}
                                                                     context: nil];
    self.tweetTextView.scrollEnabled = NO;
    if (textNecessaryRect.size.height > TweetTextViewMaxHeight) {
        /* if the tweetTextView calculated height is heigher then TweetTextViewMaxHeight, we will make it scrollable and
         set the tweetTextView height to TweetTextViewMaxHeight */
        textNecessaryRect = CGRectMake(textNecessaryRect.origin.x,
                                       textNecessaryRect.origin.y,
                                       textNecessaryRect.size.width,
                                       TweetTextViewMaxHeight);
        self.tweetTextView.scrollEnabled = YES;
    }
    necessaryHeight = necessaryHeight + textNecessaryRect.size.height;
    self.tweetTextView.frame = CGRectMake(self.tweetTextView.frame.origin.x,
                                          self.tweetTextView.frame.origin.y,
                                          self.tweetTextView.frame.size.width,
                                          roundf(textNecessaryRect.size.height) + CellTopBottomLeftRightPadding);
    return (roundf(necessaryHeight));
}

- (void)setLogoImage: (UIImage *)image {
    if (image != _logoImage) {
        _logoImage = image;
        self.logoImageView.image = _logoImage;
    }
}

- (void)setName: (NSString *)name {
    if (_name != name) {
        _name = [name copy];
        self.nameLabel.text = _name;
    }
}

- (void)setScreenName: (NSString *)screenName {
    if (_screenName != screenName) {
        _screenName = [screenName copy];
        self.screenNameLabel.text = _screenName;
    }
}

- (void)setTweetText: (NSString *)tweetText {
    if (_tweetText != tweetText) {
        _tweetText = [tweetText copy];
        self.tweetTextView.text = _tweetText;
        [self cellNecessaryHeight]; // we doo this so that the textView adjusts the textView height
    }
}

- (void)setPostedAgo: (NSString *)postedAgo {
    if (_postedAgo != postedAgo) {
        _postedAgo = [postedAgo copy];
        self.postedAgoLabel.text = _postedAgo;
    }
}

- (void)dealloc {
    
}
@end
