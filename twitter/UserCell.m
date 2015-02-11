//
//  UserCell.m
//  twitter
//
//  Created by Bruce Ng on 2/10/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "UserCell.h"
#import "UIImageView+AFNetworking.h"

@interface UserCell()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIView *profileWrapperView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusCountLabel;

@end

@implementation UserCell

- (void)awakeFromNib {
    // Initialization code
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    self.profileWrapperView.layer.cornerRadius = 3;
    self.profileWrapperView.clipsToBounds = YES;


}

- (void)layoutSubviews {
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    self.profileWrapperView.layer.cornerRadius = 3;
    self.profileWrapperView.clipsToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    _user = user;
    [self.profileImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    self.nameLabel.text = user.name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", user.screename ];
    self.followerCountLabel.text = [NSString stringWithFormat:@"%ld", user.followersCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%ld", user.followingCount];
    self.statusCountLabel.text = [NSString stringWithFormat:@"%ld", user.statusCount];
}

@end
