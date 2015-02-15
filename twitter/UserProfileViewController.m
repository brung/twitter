//
//  UserProfileViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/14/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UserDetailsViewController.h"
#import "TweetsViewController.h"
#import "TwitterClient.h"
#import "UIImageView+AFNetworking.h"

@interface UserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (nonatomic, strong) TweetsViewController *tableView;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    
    if (!self.user) {
        self.user = [User currentUser];
    }
    if (self.currentView != ViewUser && self.currentView != ViewMentions) {
        self.currentView = ViewUser;
    }
    
    [self.bgImage setImageWithURL:[NSURL URLWithString:self.user.backgroundImageUrl]];
    [self.bgImage clipsToBounds];
    [self.profileImage setImageWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
    [self setFollowButtonLabel];
    
    if (self.user == [User currentUser]) {
        self.followButton.hidden = YES;
    }
    
    UserDetailsViewController *uvc = [[UserDetailsViewController alloc] init];
    uvc.user = self.user;
    [uvc willMoveToParentViewController:self];
    uvc.view.frame = self.descriptionView.bounds;
    [self.descriptionView addSubview:uvc.view];
    
    self.tableView = [[TweetsViewController alloc] init];
    self.tableView.user = self.user;
    self.tableView.currentView = self.currentView;
    self.tableView.view.frame = self.contentView.bounds;
    
    [self.tableView willMoveToParentViewController:self];
    [self addChildViewController:self.tableView];
    [self.contentView addSubview:self.tableView.view];
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    self.followButton.hidden = (self.user == [User currentUser]);
    [self.tableView willMoveToParentViewController:nil];
    [self.tableView didMoveToParentViewController:nil];
    
    self.tableView = [[TweetsViewController alloc] init];
    self.tableView.user = self.user;
    self.tableView.currentView = self.currentView;
    self.tableView.view.frame = self.contentView.bounds;
    
    [self.tableView willMoveToParentViewController:self];
    [self addChildViewController:self.tableView];
    [self.contentView addSubview:self.tableView.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setFollowButtonLabel {
    if (self.user.following) {
        self.followButton.titleLabel.text = @"Unfollow";
    } else {
        self.followButton.titleLabel.text = @"Follow";
    }
}

- (IBAction)onFollowButtonTap:(id)sender {
    if (self.user.following) {
        [[TwitterClient sharedInstance] unfollowUser:self.user completion:^(User *user, NSError *error) {
            self.user = user;
            [self setFollowButtonLabel];
        }];
    } else {
        [[TwitterClient sharedInstance] followUser:self.user completion:^(User *user, NSError *error) {
            self.user = user;
            [self setFollowButtonLabel];
        }];
        
    }
}

- (IBAction)onSegmentControlTap:(id)sender {
    
    
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
