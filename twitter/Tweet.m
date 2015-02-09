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

- (void)toggleFavoritedStatus {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.tweetId forKey:@"id"];
    if (self.favorited) {
        [[TwitterClient sharedInstance] unfavoriteTweetWithParameters:params completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                self.favorited = NO;
                self.favoriteCount--;
                [self.delegate tweet:self didChangeFavorited:self.favorited];
                NSLog(@"Success removing favorite");
            } else {
                NSLog(@"Error removing favorite");
            }
        }];
    } else {
        [[TwitterClient sharedInstance] favoriteTweetWithParameters:params completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                self.favorited = YES;
                self.favoriteCount++;
                [self.delegate tweet:self didChangeFavorited:self.favorited];
                NSLog(@"Success adding favorite");
            } else {
                NSLog(@"Error adding favorite: %@", error);
            }

        }];
    }
}

- (void)toggleRetweetedStatus {
    if (self.retweeted) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"200" forKey:@"count"];
        [params setValue:@"true" forKey:@"trim_user"];
        [params setValue:@"true" forKey:@"exclude_replies"];
        [params setValue:@"true" forKey:@"include_rts"];
        [params setValue:[User currentUser].screename forKey:@"screen_name"];
        [[TwitterClient sharedInstance] getUserTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
            if (!error) {
                for (Tweet *tweet in tweets) {
                    NSLog(@"Looking to delete retweet of %@", self.tweetId);
                    if ([tweet.retweetedId longLongValue] == [self.tweetId longLongValue]) {
                        [[TwitterClient sharedInstance] destroyTweet:tweet.tweetId completion:^(Tweet *tweet, NSError *error) {
                            if (!error) {
                                self.retweeted = NO;
                                self.retweetCount--;
                                [self.delegate tweet:self didChangeRetweeted:self.retweeted];
                                NSLog(@"Success removing retweet");
                            } else {
                                NSLog(@"Error removing retweet %@", error);
                            }
                        }];
                        break;
                    } else {
                        NSLog(@"Unable to find user's retweet");
                    }
                }
            } else {
                NSLog(@"Error removing tweet: unable to retrieve posted tweets %@", error);
            }
        }];
    } else {
        [[TwitterClient sharedInstance] retweetId:self.tweetId completion:^(Tweet *tweet, NSError *error) {
            if (!error) {
                self.retweeted = YES;
                self.retweetCount++;
                [self.delegate tweet:self didChangeRetweeted:self.retweeted];
                NSLog(@"Success adding retweet");
            } else {
                NSLog(@"Error adding retweet: %@", error);
            }

        }];
    }
}

#pragma  mark - Static methods

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    return tweets;
}


@end
