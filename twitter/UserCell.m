//
//  UserCell.m
//  twitter
//
//  Created by Bruce Ng on 2/14/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "UserCell.h"
#import "UserDetailsViewController.h"
#import "UserTaglineViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"

@interface UserCell() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIPageControl *userInfoPaging;
@property (weak, nonatomic) IBOutlet UIScrollView *userInfoView;
@property (weak, nonatomic) IBOutlet UIView *followingButton;
@property (weak, nonatomic) IBOutlet UIView *followButton;
@property (nonatomic, strong) UITapGestureRecognizer *followingButtonTap;
@property (nonatomic, strong) UITapGestureRecognizer *followButtonTap;

@end

@implementation UserCell

- (void)awakeFromNib {
    // Initialization code
    self.followButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFollowTap:)];
    self.followButtonTap.delegate = self;
    self.followingButtonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFollowingTap:)];
    self.followingButtonTap.delegate = self;
    self.userInfoView.delegate = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    self.followingButton.layer.cornerRadius = 3;
    self.followingButton.clipsToBounds = YES;
    [self.followingButton addGestureRecognizer:self.followingButtonTap];
    self.followButton.layer.cornerRadius = 3;
    self.followButton.clipsToBounds = YES;
    [self.followButton addGestureRecognizer:self.followButtonTap];
    
}

- (void)displayFollowButton {
    if (self.user.following) {
        self.followingButton.hidden = NO;
        self.followButton.hidden = YES;
    } else {
        self.followingButton.hidden = YES;
        self.followButton.hidden = NO;
    }
}

- (void)setUser:(User *)user {
    _user = user;
    [self.profileImage setImageWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
    [self displayFollowButton];
    UserDetailsViewController *vc = [[UserDetailsViewController alloc] init];
    vc.user = self.user;
    
    
    vc.view.frame = self.userInfoView.bounds;
    //    [vc willMoveToParentViewController:self];
    //    [vc didMoveToParentViewController:self];
    [self.userInfoView addSubview:vc.view];
    
    
    CGRect frame = CGRectMake(self.userInfoView.bounds.size.width, 0, self.userInfoView.bounds.size.width, self.userInfoView.bounds.size.height);
    UserTaglineViewController *tvc = [[UserTaglineViewController alloc] init];
    tvc.labelText = self.user.tagline;
    tvc.view.frame = frame;
    [self.userInfoView addSubview:tvc.view];
    self.userInfoView.contentSize = CGSizeMake(2*self.userInfoView.frame.size.width, self.userInfoView.frame.size.height);

}

- (IBAction)onFollowTap:(id)sender {
        [[TwitterClient sharedInstance] followUser:self.user completion:^(User *user, NSError *error) {
            if (!error) {
                user.following = YES;
                self.user = user;
                [self displayFollowButton];
            }
        }];
}

- (IBAction)onFollowingTap:(id)sender {
    [[TwitterClient sharedInstance] unfollowUser:self.user completion:^(User *user, NSError *error) {
        if (!error) {
            user.following = NO;
            self.user = user;
            [self displayFollowButton];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.userInfoView.frame.size.width;
    int page = floor((self.userInfoView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.userInfoPaging.currentPage = page;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
