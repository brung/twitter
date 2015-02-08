//
//  Tweet.m
//  twitter
//
//  Created by Bruce Ng on 2/4/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "Tweet.h"
#import "TwitterClient.h"
@interface Tweet()
@end

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.text = dictionary[@"text"];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        NSString *createdAtString = dictionary[@"created_at"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createdAtString];
        self.tweetId = dictionary[@"id"];
        self.retweetCount = [dictionary[@"retweet_count"] integerValue];
        self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        self.retweetedId = [dictionary valueForKeyPath:@"retweeted_status.id"];
    }
    
    return self;
}

- (void)favoriteWithCompletion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.tweetId forKey:@"id"];
    if (self.favorited) {
        [[TwitterClient sharedInstance] unfavoriteTweetWithParameters:params completion:completion];
    } else {
        [[TwitterClient sharedInstance] favoriteTweetWithParameters:params completion:completion];
    }
}

- (void)retweetWithCompletion:(void (^)(Tweet *tweet, NSError *error))completion {
    [[TwitterClient sharedInstance] retweetId:self.tweetId completion:completion];
}


+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    return tweets;
}

@end
