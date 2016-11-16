//
//  NSMutableDictionary+CNRSMultipleItems.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "NSMutableDictionary+CNRSMultipleItems.h"

@implementation NSMutableDictionary (CNRSMultipleItems)

- (void)cnrs_addItem:(id)item forKey:(id<NSCopying>)aKey {
    if (item == nil) {
        return;
    }
    id obj = [self objectForKey:aKey];
    if (obj) {
        NSMutableArray *array = [NSMutableArray arrayWithObject:obj];
        [array addObject:item];
        [self setObject:array forKey:aKey];
    }
    else{
        [self setObject:item forKey:aKey];
    }
}

@end
