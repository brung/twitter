//
//  SideNavViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/11/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "SideNavViewController.h"
#import "TweetsViewController.h"
#import "MenuCell.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

NSString * const UserSwitchingAccounts = @"UserSwitchingAccountsNotification";
NSString * const MenuCellNib = @"MenuCell";

@interface SideNavViewController () <UITableViewDataSource, UITableViewDelegate, TweetsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) MenuCell *prototypeCell;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic) NSInteger currentView;
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
    NSMutableArray *vcItems = [NSMutableArray array];
    

    [self.tableView registerNib:[UINib nibWithNibName:MenuCellNib bundle:nil] forCellReuseIdentifier:MenuCellNib];
    [self.tableView reloadData];
    
    //Tweets
    TweetsViewController *tvc = [[TweetsViewController alloc] init];
    tvc.user = currentUser;
    tvc.currentView = ViewHome;
    tvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:tvc];
    // Modally present tweents view
    UINavigationBar *navbar = nvc.navigationBar;
    [navbar setBarTintColor:[UIColor colorWithRed:(85/255.0) green:(172/255.0) blue:(238/255.0) alpha:1]];
    navbar.tintColor = [UIColor whiteColor];
    [navbar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],
                                    NSForegroundColorAttributeName,
                                    [UIColor whiteColor],
                                    NSForegroundColorAttributeName,
                                    nil]];
    nvc.view.frame = self.view.frame;
    [vcItems addObject:nvc];

    //User Details
    TweetsViewController *userVC = [[TweetsViewController alloc] init];
    userVC.user = [User currentUser];
    userVC.currentView = ViewUser;
    userVC.view.frame = self.view.frame;
    [vcItems addObject:userVC];

    //Mentions
    TweetsViewController *mentionsVC = [[TweetsViewController alloc] init];
    mentionsVC.user = [User currentUser];
    mentionsVC.currentView = ViewMentions;
    mentionsVC.view.frame = self.view.frame;
    [vcItems addObject:mentionsVC];
    
    self.viewControllers = vcItems;
    self.currentView = ViewHome;
    [nvc willMoveToParentViewController:self];
    [self addChildViewController:nvc];
    [self.contentView addSubview:nvc.view];
    
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
    UIViewController *vc = self.viewControllers[self.currentView];
    [vc willMoveToParentViewController:nil];
    [vc didMoveToParentViewController:nil];
    
    vc = self.viewControllers[indexPath.row];
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    vc.view.frame = self.view.frame;
    [self.contentView addSubview:vc.view];
    self.currentView = indexPath.row;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.contentView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}


#pragma mark - GestureRecognizers
- (IBAction)onViewSwipe:(UIPanGestureRecognizer *)sender {
    CGPoint velocity = [sender velocityInView:self.view];
    CGPoint translation = [sender translationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.startPoint = translation;
    } else if (sender.state == UIGestureRecognizerStateChanged){
        float newX = translation.x;
        if (translation.x < 0) {
            newX = 0;
        } else if (translation.x > self.view.bounds.size.width-60) {
            newX = self.view.bounds.size.width-60;
        }
        self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, newX, 0);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            [UIView animateWithDuration:0.3 animations:^{
                float screenWidth = self.view.bounds.size.width-60;
                self.contentView.transform = CGAffineTransformMakeTranslation(screenWidth, 0);
            }];
        } else if (velocity.x <= 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.contentView.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
            
        }
    }
}
- (IBAction)onLongPress:(UILongPressGestureRecognizer *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:UserSwitchingAccounts object:nil];
}

#pragma mark - Private methods
- (void)tweetsViewController:(TweetsViewController *)tvc selectedUser:(User *)user {
    TweetsViewController *vc = [[TweetsViewController alloc] init];
    vc.user = user;
    vc.currentView = ViewUser;
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    vc.view.frame = self.view.frame;
    [self.contentView addSubview:vc.view];
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
