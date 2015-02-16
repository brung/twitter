//
//  AccountsViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/15/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "AccountsViewController.h"
#import "SideNavViewController.h"
#import "TwitterClient.h"
#import "AccountsUserCell.h"

NSString * const UserCellNib = @"AccountsUserCell";

@interface AccountsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, AccountsUserCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) AccountsUserCell *prototypeCell;

@end

@implementation AccountsViewController
- (AccountsUserCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:UserCellNib];
    }
    return _prototypeCell;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.users = [User getAllUsers];
    self.title = @"Accounts";
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:UserCellNib bundle:nil] forCellReuseIdentifier:UserCellNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    [self.prototypeCell layoutIfNeeded];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountsUserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UserCellNib];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [User setCurrentUser:self.users[indexPath.row]];
    [self presentViewController:[[SideNavViewController alloc] init] animated:YES completion:nil];
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:AccountsUserCell.class]) {
        AccountsUserCell *userCell = (AccountsUserCell *)cell;
        userCell.user = self.users[indexPath.row];
    }
}

- (IBAction)onAddAccountButtonTap:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user != nil) {
            NSLog(@"Welcome to %@", user.name);
            [self presentViewController:[[SideNavViewController alloc] init] animated:YES completion:nil];
        } else {
            // Present error view
        }
    }];
}

- (void) tappedRemoveOnAccountsUserCell:(AccountsUserCell *)cell {
    self.users = [User removeUser:cell.user];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [UIView animateWithDuration:0.4 animations:^{
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }];
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
