//
//  TweetCell.h
//  twitter
//
//  Created by Bruce Ng on 2/5/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

static int const ButtonIDReply = 1;
static int const ButtonIDRetweet = 2;
static int const ButtonIDFavorite = 3;

@class TweetCell;
@protocol TweetCellDelegate <NSObject>
- (void)tweetCell:(TweetCell *)cell didPressButton:(NSInteger)buttonID;
@end

@interface TweetCell : UITableViewCell
@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, strong) id<TweetCellDelegate> delegate;

@end
