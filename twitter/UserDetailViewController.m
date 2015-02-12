//
//  UserDetailViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/10/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "UserDetailViewController.h"
#import "ComposeViewController.h"
#import "TweetDetailViewController.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "UserCell.h"
#import "UIImageView+AFNetworking.h"

NSString * const NibUserCell = @"UserCell";
NSString * const NibTweetCell = @"TweetCell";
static NSInteger const ResultCount = 20;


@interface UserDetailViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate, TweetDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *UsersBGImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) TweetCell *prototypeTweetCell;
@property (nonatomic, strong) UserCell *prototypeUserCell;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL isPaginating;
@end

@implementation UserDetailViewController
- (TweetCell *)prototypeTweetCell {
    if (!_prototypeTweetCell) {
        _prototypeTweetCell = [self.tableView dequeueReusableCellWithIdentifier:NibTweetCell];
    }
    return _prototypeTweetCell;
}
- (UserCell *)prototypeUserCell {
    if (!_prototypeUserCell) {
        _prototypeUserCell = [self.tableView dequeueReusableCellWithIdentifier:NibUserCell];
    }
    return _prototypeUserCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.isUpdating = NO;
    self.isPaginating = NO;
    
    //[self.UsersBGImage setImageWithURL:[NSURL URLWithString:self.user.backgroundImageUrl]];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:NibTweetCell bundle:nil] forCellReuseIdentifier:NibTweetCell];
    [self.tableView registerNib:[UINib nibWithNibName:NibUserCell bundle:nil] forCellReuseIdentifier:NibUserCell];
    
    [self fetchTweets];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 32;
    }
    return 0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        UIImageView * header = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0)
//        [header setImageWithURL:[NSURL URLWithString:self.user.backgroundImageUrl]];
//        
//    }
//    return nil;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.tweets.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self configureCell:self.prototypeUserCell forRowAtIndexPath:indexPath];
        [self.prototypeUserCell layoutIfNeeded];
        CGSize size = [self.prototypeUserCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height+1;
    } else {
        [self configureCell:self.prototypeTweetCell forRowAtIndexPath:indexPath];
        [self.prototypeTweetCell layoutIfNeeded];
        CGSize size = [self.prototypeTweetCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NibUserCell];
        [self configureCell:cell forRowAtIndexPath:indexPath];
        return cell;
    } else {
        TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NibTweetCell];
        [self configureCell:cell forRowAtIndexPath:indexPath];        
        return cell;
    }
    
    
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TweetCell class]]) {
        TweetCell *tweetCell = (TweetCell *)cell;
        tweetCell.tweet = self.tweets[indexPath.row];
        tweetCell.delegate = self;
    } else if ([cell isKindOfClass:[UserCell class]]) {
        UserCell *userCell = (UserCell *)cell;
        userCell.user = self.user;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section > 0) {
        TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
        vc.tweet = self.tweets[indexPath.row];
        vc.delegate = self;
        vc.indexPath = indexPath;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - TweetCellDelegate
- (void)tweetCell:(TweetCell *)cell didPressButton:(NSInteger)buttonID {
    switch(buttonID)
    {
        case ButtongIDUserProfile:
        {
            [cell animateProfileTapNoOp];
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

#pragma mark - Private methods
- (void)fetchTweets {
    if (!self.isUpdating) {
        self.isUpdating = YES;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:self.user.screename forKey:@"screen_name"];
        [params setObject:@(ResultCount) forKey:@"count"];
        if(self.isPaginating) {
            Tweet *oldestTweet = self.tweets[self.tweets.count-1];
            long long oldestId = [oldestTweet.tweetId longLongValue]-1;
            [params setObject:@(oldestId) forKey:@"max_id"];
        }
        [[TwitterClient sharedInstance] getUserTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
