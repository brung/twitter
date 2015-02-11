//
//  TweetCell.m
//  twitter
//
//  Created by Bruce Ng on 2/5/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import <NSDateMinimalTimeAgo/NSDate+MinimalTimeAgo.h>

@interface TweetCell() <TweetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end;

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    UIGestureRecognizer *singleTapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserProfileTap)];
    [self.profileImage addGestureRecognizer:singleTapImage];
    [self.profileImage setMultipleTouchEnabled:YES];
    [self.profileImage setUserInteractionEnabled:YES];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweetIcon"] forState:UIControlStateNormal];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweetIcon_on"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteIcon"] forState:UIControlStateNormal];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteIcon_on"] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    self.tweetLabel.preferredMaxLayoutWidth = self.tweetLabel.frame.size.width;
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    [self.profileImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImageUrl]];
    self.nameLabel.text = tweet.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screename ];
    self.tweetLabel.text = tweet.text;
    self.timeLabel.text = [tweet.createdAt timeAgo];
    self.retweetButton.selected = tweet.retweeted;
    self.favoriteButton.selected = tweet.favorited;
    self.tweet.delegate = self;
}

- (IBAction)onReplyTap:(id)sender {
    [self.delegate tweetCell:self didPressButton:ButtonIDReply];
}

- (IBAction)onRetweetTap:(id)sender {
    [self.delegate tweetCell:self didPressButton:ButtonIDRetweet];
    [self.tweet toggleRetweetedStatus];
}

- (void)onUserProfileTap {
    [self.delegate tweetCell:self didPressButton:ButtongIDUserProfile];
}

- (IBAction)onFavoriteTap:(id)sender {
    [self.delegate tweetCell:self didPressButton:ButtonIDFavorite];
    [self.tweet toggleFavoritedStatus];
}

- (void)tweet:(Tweet *)tweet didChangeFavorited:(BOOL)favorited {
    [self.delegate tweetCell:self didChangeFavoritedStatus:favorited];
}

- (void)tweet:(Tweet *)tweet didChangeRetweeted:(BOOL)retweeted {
    [self.delegate tweetCell:self didChangeRetweetedStatus:retweeted];
}

- (void)animateProfileTapNoOp {
    [UIView animateWithDuration:0.2 animations:^{
        self.profileImage.transform = CGAffineTransformMakeScale(1.15, 1.15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0 initialSpringVelocity:0.8 options:0 animations:^{
        } completion:^(BOOL finished) {
            self.profileImage.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

@end
