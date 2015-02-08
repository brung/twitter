//
//  ComposeViewController.m
//  twitter
//
//  Created by Bruce Ng on 2/7/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "ComposeViewController.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennameLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;

@property (nonatomic, strong) UIBarButtonItem *textCounter;
@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;

    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftButton)];
    leftButton.tintColor = [UIColor colorWithRed:(85/255.0) green:(172/255.0) blue:(238/255.0) alpha:1];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onRightButton)];
    rightButton.tintColor = [UIColor colorWithRed:(85/255.0) green:(172/255.0) blue:(238/255.0) alpha:1];
    self.textCounter = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:self action:nil];
    self.textCounter.tintColor = [UIColor lightGrayColor];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightButton, self.textCounter, nil];
    
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage setImageWithURL:[NSURL URLWithString:[User currentUser].profileImageUrl]];
    self.nameLabel.text = [User currentUser].name;
    self.screennameLabel.text = [NSString stringWithFormat:@"@%@", [User currentUser].screename];
    self.tweetText.delegate = self;
    if (self.replyToTweet != nil) {
        self.tweetText.text = [NSString stringWithFormat:@"@%@",self.replyToTweet.user.screename];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextView Delegate
- (void)textViewDidChange:(UITextView *)textView {
    NSInteger count = 140 - [self.tweetText.text length];
    self.textCounter.title = [NSString stringWithFormat:@"%ld", count];
}


#pragma mark - Buttons
- (void)onLeftButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightButton {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.replyToTweet != nil) {
        [params setObject:self.replyToTweet.tweetId forKey:@"in_reply_to_status_id"];
    }
    [params setObject:self.tweetText.text forKey:@"status"];
    [[TwitterClient sharedInstance] updateTweetWithParameters:params completion:^(Tweet *tweet, NSError *error) {
        if(!error) {
            NSLog(@"Posted %@", params);
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"Failed to post %@", error);
        }
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
