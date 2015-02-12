//
//  MenuItem.h
//  twitter
//
//  Created by Bruce Ng on 2/11/15.
//  Copyright (c) 2015 com.yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject
@property (nonatomic, strong) NSString *iconImage;
@property (nonatomic, strong) NSString *itemLabel;


+ (NSArray *)getMenuItems;
@end
