//
//  NSDictionary+CNRSMultipleItems.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "NSDictionary+CNRSMultipleItems.h"
#import "NSURL+Cenarius.h"

@implementation NSDictionary (CNRSMultipleItems)

- (id)cnrs_itemForKey:(id)key {
  id obj = [self objectForKey:key];
  if ([obj isKindOfClass:[NSArray class]]) {
    return [obj count] > 0 ? [obj objectAtIndex:0] : nil;
  } else {
    return obj;
  }
}

- (NSArray *)cnrs_allItemsForKey:(id)key {
  id obj = [self objectForKey:key];
  return [obj isKindOfClass:[NSArray class]] ? obj : (obj ? [NSArray arrayWithObject:obj] : nil);
}



@end
