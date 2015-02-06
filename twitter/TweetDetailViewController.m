//
//  TweetDetailViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/5/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import <NSDate+MinimalTimeAgo.h>

@interface TweetDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;

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
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.retweetCount];
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.favoriteCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
