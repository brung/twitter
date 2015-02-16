//
//  UserDetailsViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/14/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "UserDetailsViewController.h"

@interface UserDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;

@end

@implementation UserDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.nameLabel.text = self.user.name;
    
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@",self.user.screename];
    self.followingCountLabel.text = [self stringFromInteger:self.user.followingCount];
    self.followersCountLabel.text = [self stringFromInteger:self.user.followersCount];
}

- (NSString *)stringFromInteger:(NSInteger)number {
    float count = (float)number;
    if (count > 1000000) {
        count = count /1000000.0;
        return [NSString stringWithFormat:@"%0.1fM", count];
    } else if (count > 1000) {
        count = count / 1000.0;
        return [NSString stringWithFormat:@"%0.1fK", count];
    }
    return [NSString stringWithFormat:@"%ld", (long)number];
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
