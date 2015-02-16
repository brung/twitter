//
//  UserTaglineViewController.h
//  twitter
//
//  Created by Bruce Ng on 2/16/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserTaglineViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (nonatomic, strong) NSString *labelText;
@end
