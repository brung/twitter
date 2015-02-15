//
//  MenuItem.m
//  twitter
//
//  Created by Bruce Ng on 2/11/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.iconImage = dictionary[@"iconImageName"];
        self.itemLabel = dictionary[@"name"];
    }
    return self;
}

+ (NSArray *)getMenuItems {
    NSArray *items = @[@{@"iconImageName" : @"twitter", @"name" : @"Home"},
                       @{@"iconImageName" : @"twitter", @"name" : @"Profile"},
                       @{@"iconImageName" : @"twitter", @"name" : @"Mentions"}];
    NSMutableArray *returnItems = [NSMutableArray array];
    for (NSDictionary *dict in items) {
        [returnItems addObject:[[MenuItem alloc] initWithDictionary:dict]];
    }
    return returnItems;
}

@end
