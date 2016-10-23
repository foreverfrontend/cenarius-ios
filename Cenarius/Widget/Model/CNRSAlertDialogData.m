//
//  CNRSAlertDialogData.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSAlertDialogData.h"

@implementation CNRSAlertDialogButton

- (NSString *)text
{
  return [self.dictionary objectForKey:@"text"];
}

- (NSString *)action
{
  return [self.dictionary objectForKey:@"action"];
}

@end


@implementation CNRSAlertDialogData

- (NSString *)title
{
  return [self.dictionary objectForKey:@"title"];
}

- (NSString *)message
{
  return [self.dictionary objectForKey:@"message"];
}

- (NSArray<CNRSAlertDialogButton *> *)buttons
{
  NSMutableArray<CNRSAlertDialogButton *> *result = [NSMutableArray array];
  NSArray *array = [self.dictionary objectForKey:@"buttons"];
  for (id dic in array) {
    if ([dic isKindOfClass:[NSDictionary class]]) {
      CNRSAlertDialogButton *button = [[CNRSAlertDialogButton alloc] initWithDictionary:dic];
      if (button) {
        [result addObject:button];
      }
    }
  }
  return result;
}

@end
