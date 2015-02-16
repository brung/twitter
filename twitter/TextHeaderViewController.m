//
//  TextHeaderViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/14/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "TextHeaderViewController.h"

@interface TextHeaderViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textHeaderLabel;
@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation TextHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTextForHeader:(NSString *)textForHeader {
    _textForHeader = textForHeader;
    self.textHeaderLabel.text = textForHeader;
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
