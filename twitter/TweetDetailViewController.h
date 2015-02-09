//
//  TweetDetailViewController.h
//  twitter
//
//  Created by Bruce Ng on 2/5/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetDetailViewController;
@protocol TweetDetailViewControllerDelegate <NSObject>
- (void) tweetDetailViewController:(TweetDetailViewController *)vc didChangeFavorited:(BOOL)favorited;
- (void) tweetDetailViewController:(TweetDetailViewController *)vc didChangeRetweeted:(BOOL)retweeted;

@end

@interface TweetDetailViewController : UIViewController
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, strong) id<TweetDetailViewControllerDelegate> delegate;
@end
