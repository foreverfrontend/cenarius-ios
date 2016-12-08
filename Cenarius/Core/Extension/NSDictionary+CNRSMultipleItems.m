//
//  NSDictionary+CNRSMultipleItems.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "NSDictionary+CNRSMultipleItems.h"

@implementation NSDictionary (CNRSMultipleItems)

- (id)itemForKey:(id)key {
  id obj = [self objectForKey:key];
  if ([obj isKindOfClass:[NSArray class]]) {
    return [obj count] > 0 ? [obj objectAtIndex:0] : nil;
  } else {
    return obj;
  }
}

- (NSArray *)allItemsForKey:(id)key {
  id obj = [self objectForKey:key];
  return [obj isKindOfClass:[NSArray class]] ? obj : (obj ? [NSArray arrayWithObject:obj] : nil);
}

- (NSString *)queryString
{
    NSMutableArray *pairs = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    NSString *query = nil;
    if (pairs.count > 0) {
        query = [pairs componentsJoinedByString:@"&"];
    }
    return query;
}

@end
