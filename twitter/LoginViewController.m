//
//  LoginViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/3/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "MainViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
- (IBAction)onLogin:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user != nil) {
            NSLog(@"Welcome to %@", user.name);
            // Modally present tweents view
//            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:[[SideNavViewController alloc] init]];
//            UINavigationBar *navbar = nvc.navigationBar;
//            [navbar setBarTintColor:[UIColor colorWithRed:(85/255.0) green:(172/255.0) blue:(238/255.0) alpha:1]];
//            navbar.tintColor = [UIColor whiteColor];
//            [navbar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                            [UIColor whiteColor],
//                                            NSForegroundColorAttributeName,
//                                            [UIColor whiteColor],
//                                            NSForegroundColorAttributeName,
//                                            nil]];
//            [self presentViewController:nvc animated:YES completion:nil];
            [self presentViewController:[[MainViewController alloc] init] animated:YES completion:nil];
        } else {
            // Present error view
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
