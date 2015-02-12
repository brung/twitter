//
//  SideNavViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/11/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "SideNavViewController.h"
#import "TweetsViewController.h"
#import "UserDetailViewController.h"
#import "MenuCell.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

NSString * const MenuCellNib = @"MenuCell";

@interface SideNavViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) MenuCell *prototypeCell;
@end

@implementation SideNavViewController
- (MenuCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:MenuCellNib];
    }
    return _prototypeCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    User *currentUser = [User currentUser];
    [self.profileImage setImageWithURL:[NSURL URLWithString:currentUser.profileImageUrl]];
    self.nameLabel.text = currentUser.name;
    self.screennameLabel.text = currentUser.screename;
    
    self.menuItems = [MenuItem getMenuItems];
    

    [self.tableView registerNib:[UINib nibWithNibName:MenuCellNib bundle:nil] forCellReuseIdentifier:MenuCellNib];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
        [self.prototypeCell layoutIfNeeded];
        CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        
        return size.height+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MenuCellNib];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[MenuCell class]]) {
        MenuCell *menuCell = (MenuCell *)cell;
        menuCell.menuItem = self.menuItems[indexPath.row];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.row == 0) {
//        UserDetailViewController *vc = [[UserDetailViewController alloc] init];
//        vc.user = [User currentUser];
//        [self.contentView addSubview: vc.view];
//    } else     if (indexPath.row == 1) {
//        TweetsViewController *vc = [[TweetsViewController alloc] init];
//        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
//        [self.contentView addSubview: nvc.view];
//    }
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
