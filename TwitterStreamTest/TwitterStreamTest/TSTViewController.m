//
//  TSTViewController.m
//  TwitterStreamTest
//
//  Created by Andrei Popa on 19/05/2014.
//  Copyright (c) 2014 Andrei Popa. All rights reserved.
//

#import "TSTViewController.h"
#import "NSString+OAUTH.h"
#import "TSTApiManager.h"
#import "TSTTweetTableViewCell.h"
#import "TSTTweetModel.h"

NSUInteger const MaxFeedStartingAttempts = 3;
NSUInteger const MaxTweets               = 10;

@interface TSTViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong, readwrite) TSTApiManager *apiManager;
@property (atomic, strong, readwrite) NSMutableArray   *mostRecentTweets;
@property (nonatomic, assign, readwrite) NSUInteger    startedFeedAttempts;

@property (nonatomic, strong, readwrite) UITableView   *tableView;

- (void)handleApiManagerStateChange;

@end

@implementation TSTViewController

# pragma mark - Controller work
- (void)setupControllerData {
    self.apiManager = [TSTApiManager new];
    self.mostRecentTweets = [[NSMutableArray alloc] initWithCapacity: MaxTweets+1]; // +1 represents a temp record that will be deleted in an animated way
    [self.apiManager addObserver: self forKeyPath: @"newestTweet" options: NSKeyValueObservingOptionNew context: nil];
    [self.apiManager addObserver: self forKeyPath: @"state" options: NSKeyValueObservingOptionNew context: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableViewInfo:) name:TSTTweeModelLogoImageDownloaded object:nil];
    [self.apiManager startFetchingFeed];
    self.startedFeedAttempts++;

}

- (void)observeValueForKeyPath: (NSString *)keyPath ofObject: (id)object change: (NSDictionary *)change context: (void *)context {
    if ([keyPath isEqualToString: @"newestTweet"]) {
        // we have a new tweet we need to process it
        [self addNewTweet: self.apiManager.newestTweet];
    } else if ([keyPath isEqualToString: @"state"]) {
        // the state of the api manager changed, measures need to be taken
        [self handleApiManagerStateChange];
    }
}

- (void)addNewTweet: (NSDictionary *)tweet {
    TSTTweetModel *tweetModel = [[TSTTweetModel alloc] initWithTweetDictionary:tweet];
    if (self.mostRecentTweets.count >= MaxTweets) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mostRecentTweets removeObjectAtIndex: 0];
            [self.tableView beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
        });
    }
    [self.mostRecentTweets addObject: tweetModel];
    [self updateTableViewInfo:nil];
}

- (void)handleApiManagerStateChange {
    if (self.apiManager.state == ApiManagerStateReceivingStream) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    } else {
        if (self.startedFeedAttempts < MaxFeedStartingAttempts) {
            NSLog(@"Feed failed with status code: %d - restarting feed!", self.apiManager.httpCode);
            [self.apiManager startFetchingFeed];
            self.startedFeedAttempts++;
        } else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
            // we need to handle this and inform the user if necessary
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"An error occurred!"
                                                            message: @"Please make sure you are connected to the internet and try again later!"
                                                           delegate: nil
                                                  cancelButtonTitle: @"Terminate app"
                                                  otherButtonTitles: @"Retry", nil];
            alert.delegate = self;
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            // terminate app
            NSLog(@"Terminating app due to user request");
            exit(0);
            break;
        }
        case 1: {
            // retry
            NSLog(@"Resetting the startedFeedAttempts counter due to user request");
            self.startedFeedAttempts = 0;
            [self.apiManager startFetchingFeed];
            self.startedFeedAttempts++;
            break;
        }
        default:
            break;
    }
}

# pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupControllerData];
    
    self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(self.view.frame.origin.x, 
                                                                   self.view.frame.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height, 
                                                                   self.view.frame.size.width, 
                                                                   self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview: self.tableView];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)updateTableViewInfo :(id)sender {
    [self.tableView reloadData];
}

- (void)populateCell: (TSTTweetTableViewCell *)cell withModelInfo: (TSTTweetModel *)tweetModel {
    cell.name = tweetModel.name;
    cell.screenName = tweetModel.screenName;
    cell.postedAgo = tweetModel.postedAgo;
    cell.tweetText = tweetModel.tweetText;
    cell.logoImage= tweetModel.logoImage;
}

# pragma mark - TableView dataSource and delegate methods
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    return self.mostRecentTweets.count;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    NSString *identifier = @"tweet";
    
    TSTTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"tweet"];
    if (!cell) {
        cell = [[TSTTweetTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    TSTTweetModel *tweetModel = [self.mostRecentTweets objectAtIndex:indexPath.row];
    [self populateCell:cell withModelInfo:tweetModel];
    return cell;
}

- (CGFloat)tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath {
    TSTTweetTableViewCell *dummyCell = [[TSTTweetTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"dummy"];
    [self populateCell:dummyCell withModelInfo: [self.mostRecentTweets objectAtIndex: indexPath.row]];
    return dummyCell.cellNecessaryHeight;
}

#pragma mark - Memory management
- (void)dealloc {
    [self.apiManager removeObserver: self forKeyPath: @"newestTweet"];
    [self.apiManager removeObserver: self forKeyPath: @"state"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TSTTweeModelLogoImageDownloaded object:nil];
}

@end
