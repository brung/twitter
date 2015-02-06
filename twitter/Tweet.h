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
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;
@property (nonatomic) NSInteger retweetCount;
@property (nonatomic) NSInteger favoriteCount;


-(id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end
