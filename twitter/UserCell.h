//
//  UserCell.h
//  twitter
//
//  Created by Bruce Ng on 2/14/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface UserCell : UITableViewCell
@property (nonatomic, strong) User *user;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;


@end
