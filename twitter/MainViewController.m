//
//  MainViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/11/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "MainViewController.h"
#import "SideNavViewController.h"
#import "TweetsViewController.h"

@interface MainViewController ()
@property (nonatomic, strong) UINavigationController *nvc;
@property (nonatomic) CGPoint startPoint;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    SideNavViewController *svc = [[SideNavViewController alloc] init];
    svc.view.frame = self.view.bounds;
    
    [self addChildViewController:svc];
    [self.view addSubview:svc.view];
    
    TweetsViewController *tvc = [[TweetsViewController alloc] init];
    self.nvc = [[UINavigationController alloc] initWithRootViewController:tvc];
    self.nvc.view.frame = self.view.frame;
    [self addChildViewController:self.nvc];
    [self.view addSubview:self.nvc.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onViewSwipe:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    self.nvc.view.transform = CGAffineTransformMakeTranslation(translation.x, 0);
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.startPoint = translation;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        float screenWidth = self.view.bounds.size.width-20;
        
        if (self.startPoint.x < translation.x) {
            self.nvc.view.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            [UIView animateWithDuration:0.2 animations:^{
                self.nvc.view.transform = CGAffineTransformMakeTranslation(screenWidth, 0);
            }];
        } else {
            self.nvc.view.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            [UIView animateWithDuration:0.2 animations:^{
                self.nvc.view.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
            
        }
    }
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
