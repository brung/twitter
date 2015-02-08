//
//  ComposeViewController.h
//  twitter
//
//  Created by Bruce Ng on 2/7/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface ComposeViewController : UIViewController
@property (nonatomic, strong) Tweet *replyToTweet;

@end
