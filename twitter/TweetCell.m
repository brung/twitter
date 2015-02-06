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

@interface TweetCell()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImage;
@property (weak, nonatomic) IBOutlet UIImageView *retweetImage;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteImage;

@end;

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    [self.profileImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImageUrl]];
    self.nameLabel.text = tweet.user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screename ];
    self.tweetLabel.text = tweet.text;
    self.timeLabel.text = [tweet.createdAt timeAgo];
}
@end
