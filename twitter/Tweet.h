//
//  Tweet.h
//  twitter
//
//  Created by Bruce Ng on 2/4/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

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


- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)favoriteWithCompletion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)retweetWithCompletion:(void (^)(Tweet *tweet, NSError *error))completion;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end
