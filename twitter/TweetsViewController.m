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
#import "UserDetailViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#import "TweetCell.h"

static NSInteger const ResultCount = 20;

@interface TweetsViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, TweetCellDelegate, TweetDetailViewControllerDelegate>
@property (nonatomic, strong) NSArray *tweets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) TweetCell *prototypeCell;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL isPaginating;
@property (nonatomic) BOOL isInsertingNewPost;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPostNewTweetNotification:) name:UserPostedNewTweet object:nil];
    
    self.isUpdating = NO;
    self.isPaginating = NO;
    self.isInsertingNewPost = NO;
    
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

- (void) viewWillAppear:(BOOL)animated {
    if (self.isInsertingNewPost) {
        self.isInsertingNewPost = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [UIView animateWithDuration:1 animations:^{
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }];
    }
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
    vc.delegate = self;
    vc.indexPath = indexPath;
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
    NSLog(@"In TweetsViewController didPressButton %ld", buttonID  );
    switch(buttonID)
    {
        case ButtonIDUserProfile:
        {
            UserDetailViewController *vc = [[UserDetailViewController alloc] init];
            vc.user = cell.tweet.user;
            [self.navigationController presentViewController:vc animated:YES completion:nil];
            break;
        }
        case ButtonIDReply:
        {
            ComposeViewController *vc = [[ComposeViewController alloc] init];
            vc.replyToTweet = cell.tweet;
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nvc animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (void) tweetCell:(TweetCell *)cell didChangeFavoritedStatus:(BOOL)favorited {
    cell.tweet.favorited = favorited;
    NSLog(@"changing favorite to %@", favorited ? @"YES" : @"NO");
    [self.tableView reloadData];
    [self updateTweetAtIndexPath:[self.tableView indexPathForCell:cell]];
}

- (void) tweetCell:(TweetCell *)cell didChangeRetweetedStatus:(BOOL)retweeted {
    cell.tweet.retweeted = retweeted;
    [self.tableView reloadData];
    [self updateTweetAtIndexPath:[self.tableView indexPathForCell:cell]];
}

- (void)updateTweetAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - TweetDetailViewControllerDelegate methods
- (void) tweetDetailViewController:(TweetDetailViewController *)vc didChangeFavorited:(BOOL)favorited {
    [self updateTweetAtIndexPath:vc.indexPath];
}

- (void) tweetDetailViewController:(TweetDetailViewController *)vc didChangeRetweeted:(BOOL)retweeted {
    [self updateTweetAtIndexPath:vc.indexPath];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self fetchTweets];
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
                [[[UIAlertView alloc] initWithTitle:@"Network error" message:@"Unable to retrieve tweets" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil] show];
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

- (void)onPostNewTweetNotification:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    Tweet *newTweet = userInfo[@"tweet"];
    NSMutableArray *newTweets = [NSMutableArray arrayWithObject:newTweet];
    [newTweets addObjectsFromArray:self.tweets];
    self.tweets = newTweets;
    self.isInsertingNewPost = YES;
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
