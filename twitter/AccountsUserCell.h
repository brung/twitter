//
//  AccountsUserCell.h
//  twitter
//
//  Created by Bruce Ng on 2/15/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class AccountsUserCell;
@protocol AccountsUserCellDelegate <NSObject>

- (void) tappedRemoveOnAccountsUserCell:(AccountsUserCell *)cell;

@end

@interface AccountsUserCell : UITableViewCell
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) id<AccountsUserCellDelegate> delegate;
@end
