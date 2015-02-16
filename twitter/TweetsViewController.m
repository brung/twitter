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
#import "TextHeaderViewController.h"
#import "ImageHeaderViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "UserCell.h"

static NSInteger const ResultCount = 20;
NSInteger const ViewHome = 0;
NSInteger const ViewUser = 1;
NSInteger const ViewMentions = 2;

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
NSString * const UserCellNibName = @"UserCell";
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
    if (!self.user) {
        self.user = [User currentUser];
    }
    
    self.title = @"Home";

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:TweetCellNibName bundle:nil] forCellReuseIdentifier:TweetCellNibName];
    [self.tableView registerNib:[UINib nibWithNibName:UserCellNibName bundle:nil] forCellReuseIdentifier:UserCellNibName];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    if (self.currentView == ViewHome) {
        [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
        [self.tableView insertSubview:self.refreshControl atIndex:0];
    }
    
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
        if (self.currentView == ViewHome) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [UIView animateWithDuration:1 animations:^{
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }];
        } else if (self.currentView == ViewUser) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.currentView) {
        case ViewUser:
        case ViewMentions:
            return 2;
        case ViewHome:
        default:
            return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((self.currentView == ViewUser || self.currentView == ViewMentions) &&
        section == 0) {
        return 1;
    }
    return self.tweets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.currentView == ViewUser || self.currentView == ViewMentions) {
        switch (section) {
            case 0:
            {
                return 100;
            }
            case 1:
            {
                return 48;
            }
            default:
            {
                return 0;
            }
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.currentView == ViewUser || self.currentView == ViewMentions) {
        if (section == 0) {
            ImageHeaderViewController *vc = [[ImageHeaderViewController alloc] init];
            vc.view.frame = [self.tableView headerViewForSection:section].bounds;
            vc.imageUrl = self.user.backgroundImageUrl;
            [vc willMoveToParentViewController:self];
            [vc didMoveToParentViewController:self];
            return vc.view;
        } else if (section == 1) {
            TextHeaderViewController *vc = [[TextHeaderViewController alloc] init];
            vc.view.frame = [self.tableView headerViewForSection:section].bounds;
            [vc willMoveToParentViewController:self];
            [vc didMoveToParentViewController:self];
            if (self.currentView == ViewUser) {
                vc.textForHeader = [NSString stringWithFormat:@"%ld TWEETS", (long)self.user.statusCount];
            } else {
                vc.textForHeader = @"MENTIONS";
            }
            return vc.view;
            
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.currentView == ViewUser || self.currentView == ViewMentions)
        && indexPath.section == 0) {
        UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UserCellNibName];
        cell.user = self.user;
//        CGAffineTransform transform = CGAffineTransformMakeScale(1.5, 1.5);
//        transform = CGAffineTransformTranslate(transform, 16, -16);
//        cell.profileImage.transform = transform;
        return cell;
        
    }
    if (indexPath.row == self.tweets.count-1 && self.tweets.count >= ResultCount) {
        self.isPaginating = YES;
        [self fetchTweets];
    }
    
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TweetCellNibName];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.currentView == ViewUser || self.currentView == ViewMentions)
        && indexPath.section == 0) {
        return 172.5;
    }
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
    NSLog(@"In TweetsViewController didPressButton %ld", (long)buttonID  );
    switch(buttonID)
    {
        case ButtonIDUserProfile:
        {
            [self.delegate tweetsViewController:self selectedUser:cell.tweet.user];
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
        switch (self.currentView ) {
            default:
            case ViewHome:
            {
                [self fetchHomeTimelineWithParams:params];
                break;
            }
            case ViewUser:
            {
                [self fetchUserTimelineWithParams:params];
                break;
            }
            case ViewMentions:
            {
                [self fetchMentionsTimelineWithParams:params];
                break;
            }
        }
    } else {
        NSLog(@"Not fetching data as another call is already running");
    }
}

- (void)handleFetchResultsTweets:(NSArray *)tweets orError:(NSError *)error {
    [self.refreshControl endRefreshing];
    if (!error) {
        if (self.isPaginating) {
            NSMutableArray *allTweets = [NSMutableArray arrayWithArray:self.tweets];
            [allTweets addObjectsFromArray:tweets];
            self.tweets = [allTweets copy];
        } else {
            self.tweets = tweets;
        }
        if (tweets.count < ResultCount) {
            self.tableView.tableFooterView.hidden = YES;
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
}

- (void) fetchHomeTimelineWithParams:(NSMutableDictionary *)params {
    [[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        [self handleFetchResultsTweets:tweets orError:error];
    }];
}

- (void)fetchUserTimelineWithParams:(NSMutableDictionary *)params {
    [params setObject:self.user.screename forKey:@"screen_name"];
    [[TwitterClient sharedInstance] userTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        [self handleFetchResultsTweets:tweets orError:error];
    }];
}

- (void)fetchMentionsTimelineWithParams:(NSMutableDictionary *)params {
    [[TwitterClient sharedInstance] mentionsTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        [self handleFetchResultsTweets:tweets orError:error];
    }];
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
