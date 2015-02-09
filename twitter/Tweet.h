//
//  Tweet.h
//  twitter
//
//  Created by Bruce Ng on 2/4/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@class Tweet;
@protocol TweetDelegate <NSObject>

-(void)tweet:(Tweet *)tweet didChangeFavorited:(BOOL)favorited;
-(void)tweet:(Tweet *)tweet didChangeRetweeted:(BOOL)retweeted;


@end


@interface Tweet : NSObject
@property (nonatomic, strong) NSString *tweetId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;
@property (nonatomic) NSInteger retweetCount;
@property (nonatomic) NSInteger favoriteCount;
@property (nonatomic) BOOL favorited;
@property (nonatomic) BOOL retweeted;
@property (nonatomic, strong) NSString *retweetedId;

@property (nonatomic, strong) id<TweetDelegate> delegate;


- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)toggleFavoritedStatus;
- (void)toggleRetweetedStatus;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end
