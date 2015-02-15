//
//  TweetsViewController.h
//  twitter
//
//  Created by Bruce Ng on 2/4/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

extern NSInteger const ViewHome;
extern NSInteger const ViewUser;
extern NSInteger const ViewMentions;

@class TweetsViewController;
@protocol TweetsViewControllerDelegate <NSObject>

- (void) tweetsViewController:(TweetsViewController *)tvc selectedUser:(User *)user;

@end

@interface TweetsViewController : UIViewController
@property (nonatomic) NSInteger currentView;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) id<TweetsViewControllerDelegate> delegate;

@end
