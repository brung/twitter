//
//  TweetDetailViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/5/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "ComposeViewController.h"
#import "UIImageView+AFNetworking.h"
#import <NSDate+MinimalTimeAgo.h>

@interface TweetDetailViewController () <TweetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButon;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;


@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage setImageWithURL:[NSURL URLWithString:self.tweet.user.profileImageUrl]];
    self.nameLabel.text = self.tweet.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screename ];
    self.tweetLabel.text = self.tweet.text;
    self.dateLabel.text = [self.tweet.createdAt timeAgo];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteIcon"] forState:UIControlStateNormal];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteIcon_on"] forState:UIControlStateSelected];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweetIcon"] forState:UIControlStateNormal];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweetIcon_on"] forState:UIControlStateSelected];
    [self updateStatusContents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateStatusContents {
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.retweetCount];
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.favoriteCount];
    self.favoriteButton.selected = self.tweet.favorited;
    self.retweetButton.selected = self.tweet.retweeted;
}

#pragma mark - Buttons
- (IBAction)onFavoriteTap:(id)sender {
    self.tweet.delegate = self;
    [self.tweet toggleFavoritedStatus];
}

- (IBAction)onRetweetTap:(id)sender {
    self.tweet.delegate = self;
    [self.tweet toggleRetweetedStatus];
}

- (IBAction)onReplyTap:(id)sender {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    vc.replyToTweet = self.tweet;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}


#pragma mark - TweetDelegate methods
- (void) tweet:(Tweet *)tweet didChangeFavorited:(BOOL)favorited {
    self.tweet = tweet;
    [self updateStatusContents];
    [self.delegate tweetDetailViewController:self didChangeFavorited:favorited];
}

- (void)tweet:(Tweet *)tweet didChangeRetweeted:(BOOL)retweeted {
    self.tweet = tweet;
    [self updateStatusContents];
    [self.delegate tweetDetailViewController:self didChangeRetweeted:retweeted];
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
