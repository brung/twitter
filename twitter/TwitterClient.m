//
//  TwitterClient.m
//  twitter
//
//  Created by Bruce Ng on 2/3/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "TwitterClient.h"

NSString * const kTwitterConsumerKey = @"LJrg3rFF5Dyy55iuX7n3tdAOe";
NSString * const kTwitterConsumerSecret = @"jCGpEHF2zxoTqgq5NoNo8t11OBUv0tIBhO58dh5rfrn85J5x9B";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";
NSString * const UserPostedNewTweet = @"UserPostedNewTweet";

@interface TwitterClient()
@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);
@end

@implementation TwitterClient

+ (TwitterClient*)sharedInstance {
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        [[UIApplication sharedApplication] openURL:authURL];
        
    } failure:^(NSError *error) {
        NSLog(@"Failed to get the request token");
        self.loginCompletion(nil, error);
    }];

}

- (void)openURL:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            NSLog(@"current user: %@", user.name);
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to get current user!");
            self.loginCompletion(nil, error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"Failed to get access token");
        self.loginCompletion(nil, error);
    }];
}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Response: %@", responseObject);
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)getUserTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/user_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Response: %@", responseObject);
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}


- (void)updateTweetWithParameters:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    //https://dev.twitter.com/rest/reference/post/statuses/update
    //REquired : status
    //Optional : in_reply_to_status_id, possibly_sensitvie, lat, long, place_id, display_coordinates, trim_user, media_ids
    [self POST:@"1.1/statuses/update.json" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // No op.  All data passed in parasms
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *returnTweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(returnTweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)destroyTweet:(NSString *)tweetId completion:(void (^)(Tweet *tweet, NSError *error))completion {
    //https://dev.twitter.com/rest/reference/post/statuses/update
    //REquired : status
    //Optional : in_reply_to_status_id, possibly_sensitvie, lat, long, place_id, display_coordinates, trim_user, media_ids
    [self POST:[NSString stringWithFormat:@"1.1/statuses/destroy/%@.json",tweetId]  parameters:[NSDictionary dictionary] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // No op.  All data passed in parasms
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *returnTweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(returnTweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)retweetId:(NSString *)tweetId completion:(void (^)(Tweet *tweet, NSError *error))completion {
    //https://dev.twitter.com/rest/reference/post/statuses/retweet/%3Aid
    //Required: id
    //Optional: trim_user for only getting author id instead of full user
    [self POST:[NSString stringWithFormat: @"1.1/statuses/retweet/%@.json",tweetId] parameters:[NSDictionary dictionary] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // No op.  All data passed in parasms
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *returnTweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(returnTweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)deleteRetweetId:(NSString *)tweetId completion:(void (^)(Tweet *tweet, NSError *error))completion {
    
}

- (void)favoriteTweetWithParameters:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [self handleFavorite:YES withParameters:params completion:completion];
}

- (void)unfavoriteTweetWithParameters:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [self handleFavorite:NO withParameters:params completion:completion];
}

- (void)handleFavorite:(BOOL)favorite withParameters:(NSDictionary *)params completion:(void (^)(Tweet *responseTweet, NSError *error))completion {
    NSString *endpoint = favorite ? @"create" : @"destroy";
    //https://dev.twitter.com/rest/reference/post/favorites/create
    //Required: id
    //Optional: include_entities
    [self POST:[NSString stringWithFormat:@"1.1/favorites/%@.json",endpoint] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // No op.  All data passed in parasms
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Tweet *returnTweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(returnTweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}


- (void)replyTweetId:(NSString *)tweetId withParams:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [newParams setObject:tweetId forKey:@"in_reply_to_status_id"];
    [self updateTweetWithParameters:newParams completion:completion];
}




@end
