//
//  CNRSViewController+Router.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSViewController.h"
#import "CNRSRouteManager.h"

@implementation CNRSViewController (Router)

#pragma mark - Route File Interface

+ (void)updateRouteFilesWithCompletion:(void (^)(BOOL success))completion
{
  CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
  [routeManager updateRoutesWithCompletion:completion];
}

//+ (BOOL)isRouteExistForURI:(NSURL *)uri
//{
//  CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
//  NSURL *remoteHtml = [routeManager remoteHtmlURLForURI:uri];
//  if (remoteHtml) {
//    return YES;
//  }
//  return NO;
//}
//
//+ (BOOL)isLocalRouteFileExistForURI:(NSURL *)uri
//{
//  CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
//  NSURL *localHtml = [routeManager localHtmlURLForURI:uri];
//  if (localHtml) {
//    return YES;
//  }
//  return NO;
//}

@end
