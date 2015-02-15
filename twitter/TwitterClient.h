//
//  TwitterClient.h
//  twitter
//
//  Created by Bruce Ng on 2/3/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

extern NSString * const UserPostedNewTweet;

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)openURL:(NSURL *)url;

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)userTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)updateTweetWithParameters:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)destroyTweet:(NSString *)tweetId completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)retweetId:(NSString *)tweetId completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)unfavoriteTweetWithParameters:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)favoriteTweetWithParameters:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)followUser:(User *)user completion:(void(^)(User *user, NSError *error))completion;
- (void)unfollowUser:(User *)user completion:(void(^)(User *user, NSError *error))completion;

@end
