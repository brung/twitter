//
//  User.m
//  twitter
//
//  Created by Bruce Ng on 2/4/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

static User *_currentUser = nil;
NSString * const kCurrentUserKey = @"kCurrentUserKey";
NSString * const kAllAccountsKey = @"kAllAccounts";

+ (User *)currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    return _currentUser;
}

+ (void)setCurrentUser:(User *)user {
    _currentUser = user;
    if (_currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:_currentUser.dictionary options:0 error:NULL];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *)getAllUsers {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kAllAccountsKey];
    if (data != nil) {
        NSArray *array =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSMutableArray *users = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [users addObject:[[User alloc] initWithDictionary:dict]];
        }
        return users;
    }
    return [NSArray array];
}

+ (NSArray *)getAllUsersAsDictionaries {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kAllAccountsKey];
    if (data != nil) {
        NSArray *array =[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        return array;
    }
    return [NSArray array];
}

- (void)saveNewUser {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[User getAllUsersAsDictionaries]];
    BOOL userAlreadyExists = NO;
    for (NSUInteger i=0; i < array.count; i++) {
        NSDictionary *userDict = array[i];
        if ([self.screename isEqualToString:userDict[@"screen_name"]]) {
            userAlreadyExists = YES;
            return;
        }
    }
    [array addObject:self.dictionary];
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAllAccountsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)removeUser:(User *)user {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[User getAllUsersAsDictionaries]];
    NSMutableArray *users = [NSMutableArray array];
    NSInteger indexToRemove = 0;
    for (NSUInteger i=0; i < array.count; i++) {
        NSDictionary *userDict = array[i];
        if ([user.screename isEqualToString:userDict[@"screen_name"]]) {
            indexToRemove = i;
            if ([user.screename isEqualToString:[User currentUser].screename]) {
                [User setCurrentUser:nil];
                [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
            }
        } else {
            [users addObject:[[User alloc] initWithDictionary:userDict]];
        }
    }
    [array removeObjectAtIndex:indexToRemove];

    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAllAccountsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return users;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screename = dictionary[@"screen_name"];
        self.profileImageUrl = dictionary[@"profile_image_url"];
        self.tagline = dictionary[@"description"];
        self.backgroundImageUrl = dictionary[@"profile_background_image_url"];
        self.statusCount = [dictionary[@"statuses_count"] integerValue];
        self.followersCount = [dictionary[@"followers_count"] integerValue];
        self.followingCount = [dictionary[@"friends_count"] integerValue];
        self.backgroundColor = dictionary[@"profile_background_color"];
        self.following = [dictionary[@"following"] boolValue];
    }
    
    return self;
}

@end
