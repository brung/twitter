//
//  UserProfileViewController.h
//  twitter
//
//  Created by Bruce Ng on 2/14/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserProfileViewController : UIViewController
@property (nonatomic, strong) User *user;
@property (nonatomic) NSInteger currentView;

@end
