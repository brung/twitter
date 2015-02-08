//
//  TweetsViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/4/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "TweetsViewController.h"
#import "TweetDetailViewController.h"
#import "ComposeViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#import "TweetCell.h"

static NSInteger const ResultCount = 20;

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate>
@property (nonatomic, strong) NSArray *tweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) TweetCell *prototypeCell;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL isPaginating;

@end

@implementation TweetsViewController
NSString * const TweetCellNibName = @"TweetCell";
- (TweetCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:TweetCellNibName];
    }
    return _prototypeCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.isUpdating = NO;
    self.isPaginating = NO;
    
    self.title = @"Home";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:TweetCellNibName bundle:nil] forCellReuseIdentifier:TweetCellNibName];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 50)];
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingView startAnimating];
    loadingView.center = tableFooterView.center;
    [tableFooterView addSubview:loadingView];
    self.tableView.tableFooterView = tableFooterView;
    
    [self fetchTweets];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.tweets.count-1) {
        self.isPaginating = YES;
        [self fetchTweets];
    }
    
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TweetCellNibName];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    [self.prototypeCell layoutIfNeeded];
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height+1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.tweet = self.tweets[indexPath.row];
    //UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TweetCell class]]) {
        TweetCell *tweetCell = (TweetCell *)cell;
        tweetCell.tweet = self.tweets[indexPath.row];
        tweetCell.delegate = self;
    }
}

#pragma mark - TweetCellDelegate
- (void)tweetCell:(TweetCell *)cell didPressButton:(NSInteger)buttonID {
    switch(buttonID)
    {
        case ButtonIDReply:
        {
            ComposeViewController *vc = [[ComposeViewController alloc] init];
            vc.replyToTweet = cell.tweet;
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nvc animated:YES completion:nil];
            break;
        }
        case ButtonIDRetweet:
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            Tweet *origTweet = self.tweets[indexPath.row];
            [cell.tweet retweetWithCompletion:^(Tweet *tweet, NSError *error) {
                if (!error) {
                    origTweet.favorited = tweet.favorited;
                    origTweet.retweeted = tweet.retweeted;
                    origTweet.favoriteCount = tweet.favoriteCount;
                    origTweet.retweetCount =  tweet.retweetCount;
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                    NSLog(@"Successful retweet");
                } else {
                    NSLog(@"Failed to retweet: %@", error);
                    //TODO display error message
                }
            }];
            break;
        }
        case ButtonIDFavorite:
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            Tweet *origTweet = self.tweets[indexPath.row];
            [cell.tweet favoriteWithCompletion:^(Tweet *tweet, NSError *error) {
                if (!error) {
                    origTweet.favorited = tweet.favorited;
                    origTweet.retweeted = tweet.retweeted;
                    origTweet.favoriteCount = tweet.favoriteCount;
                    origTweet.retweetCount =  tweet.retweetCount;
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                    NSLog(@"Successful edit favorite");
                } else {
                    NSLog(@"Failed to favorite: %@", error);
                    //TODO display error message
                }
            }];

            break;
        }
        default:
            break;
    }
}

#pragma mark - Private methods
- (void)onLeftButton {
    [User logout];
}

- (void)onRightButton {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)fetchTweets {
    if (!self.isUpdating) {
        self.isUpdating = YES;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@(ResultCount) forKey:@"count"];
        if(self.isPaginating) {
            Tweet *oldestTweet = self.tweets[self.tweets.count-1];
            long long oldestId = [oldestTweet.tweetId longLongValue]-1;
            [params setObject:@(oldestId) forKey:@"max_id"];
        }
        [[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
            [self.refreshControl endRefreshing];
            if (!error) {
                if (self.isPaginating) {
                    NSMutableArray *allTweets = [NSMutableArray arrayWithArray:self.tweets];
                    [allTweets addObjectsFromArray:tweets];
                    self.tweets = [allTweets copy];
                } else {
                    self.tweets = tweets;
                }
                [self.tableView reloadData];
                self.isUpdating = NO;
                self.isPaginating = NO;
            } else {
                NSLog(@"Got an error retrieving tweets: %@", error);
                self.isUpdating = NO;
                self.isPaginating = NO;
            }
        }];
    } else {
        NSLog(@"Not fetching data as another call is already running");
    }
}

- (void)onRefresh {
    [self fetchTweets];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
