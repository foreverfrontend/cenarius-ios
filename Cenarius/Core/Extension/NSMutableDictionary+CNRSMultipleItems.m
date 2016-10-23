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
  NSMutableArray *array = nil;
  if ([obj isKindOfClass:[NSArray class]]) {
    array = [NSMutableArray arrayWithArray:obj];
  } else {
    array = obj ? [NSMutableArray arrayWithObject:obj] : [NSMutableArray array];
  }
  [array addObject:item];
  [self setObject:[array copy] forKey:aKey];
}

@end
