//
//  CNRSNavTitleWidget.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSNavTitleWidget.h"
#import "CNRSViewController.h"

@interface CNRSNavTitleWidget ()

@property (nonatomic, strong) NSDictionary *cnrsDictionary;
@property (nonatomic, copy) NSString *title;

@end


@implementation CNRSNavTitleWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
  NSString *path = URL.path;
  if (path && [path isEqualToString:@"/widget/nav_title"]) {
    return YES;
  }
  return NO;
}

- (void)prepareWithURL:(NSURL *)URL
{
    _cnrsDictionary = [URL cnrs_jsonDictionary];
    _title = _cnrsDictionary[@"title"];
}

- (void)performWithController:(CNRSViewController *)controller
{
  controller.title = _title;
}

@end
