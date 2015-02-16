//
//  AccountsUserCell.m
//  twitter
//
//  Created by Bruce Ng on 2/15/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "AccountsUserCell.h"
#import "UIImageView+AFNetworking.h"

@interface AccountsUserCell()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;
@property (nonatomic, assign) CGPoint showRemoveCenter;
@property (nonatomic, assign) CGPoint hideRemoveCenter;
@property (nonatomic) BOOL isShowingRemoveButton;
@end

@implementation AccountsUserCell

- (void)awakeFromNib {
    // Initialization code
    [self.removeButton setHidden:YES];
    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onRemoveButtonPan:)];
    self.gestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    [self.contentView addGestureRecognizer:self.gestureRecognizer];
}

- (void)setUser:(User *)user {
    _user = user;
    [self.profileImage setImageWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
    self.nameLabel.text = self.user.name;
    self.screennameLabel.text = self.user.screename;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onRemoveButtonPan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.removeButton.isHidden) {
            self.showRemoveCenter  = CGPointMake(self.removeButton.center.x, self.removeButton.center.y);
            self.hideRemoveCenter = CGPointMake(self.removeButton.center.x+self.removeButton.frame.size.width, self.removeButton.center.y);
            NSLog(@"setting remove Button current %f hide %f show %f", self.removeButton.center.x, self.hideRemoveCenter.x, self.showRemoveCenter.x);
            self.removeButton.center = self.hideRemoveCenter;
            [self.removeButton setHidden:NO];
        }
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self.contentView];
        CGFloat moveX = self.removeButton.center.x + translation.x;
        if (moveX > self.hideRemoveCenter.x) {
            moveX = self.hideRemoveCenter.x;
        } else if (moveX < self.showRemoveCenter.x) {
            moveX = self.showRemoveCenter.x;
        }
        self.removeButton.center = CGPointMake(moveX, self.removeButton.center.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [sender velocityInView:self.contentView];
        if (velocity.x > 0) {
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.removeButton.center = self.hideRemoveCenter;
            } completion:nil];
        } else if (velocity.x < 0) {
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.removeButton.center = self.showRemoveCenter;
            } completion:nil];
            
        }
    }
}

- (IBAction)onRemoveTap:(id)sender {
    [self.delegate tappedRemoveOnAccountsUserCell:self];
}

@end
