//
//  CNRSConfig.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSConfig.h"
#import "CNRSRouteManager.h"

@implementation CNRSConfig

static NSString *sCNRSProtocolScheme;
static NSString *sCNRSProtocolHost;
static NSString *sCNRSUserAgent;
static NSURL *sRoutesMapURL;
static NSString *sRoutesCachePath;
static NSString *sRoutesResourcePath;
static BOOL sIsCacheEnable = YES;
static NSURL *sRoutesMapURL;
static NSURL *sRemoteFolderUrl;
static UIImage *sBackButtonImage;
static UIEdgeInsets sBackButtonImageEdgeInsets;
static BOOL sIsDevelopModeEnable;
static BOOL sIsLogEnable;

static NSString * const DefaultCNRSScheme = @"cenarius";
static NSString * const DefaultCNRSHost = @"cenarius-container";

+ (void)setCNRSProtocolScheme:(NSString *)scheme
{
  @synchronized (self) {
    sCNRSProtocolScheme = scheme;
  }
}

+ (NSString *)cnrsProtocolScheme
{
  if (sCNRSProtocolScheme) {
    return sCNRSProtocolScheme;
  }
  return DefaultCNRSScheme;
}

+ (void)setCNRSProtocolHost:(NSString *)host
{
  @synchronized (self) {
    sCNRSProtocolHost = host;
  }
}

+ (NSString *)cnrsProtocolHost
{
  if (sCNRSProtocolHost) {
    return sCNRSProtocolHost;
  }
  return DefaultCNRSHost;
}

//+ (void)setRoutesMapURL:(NSURL *)routesMapURL
//{
//  @synchronized (self) {
//    sRoutesMapURL = routesMapURL;
//  }
//}

+ (NSURL *)routesMapURL
{
  return sRoutesMapURL;
}

+ (void)setRoutesCachePath:(NSString *)routesCachePath
{
  @synchronized (self) {
    sRoutesCachePath = routesCachePath;
  }
}

+ (NSString *)routesCachePath
{
  return sRoutesCachePath;
}

+ (void)setRoutesResourcePath:(NSString *)routesResourcePath
{
  @synchronized (self) {
    sRoutesResourcePath = routesResourcePath;
  }
}

+ (NSString *)routesResourcePath
{
  return sRoutesResourcePath;
}

+ (void)setExternalUserAgent:(NSString *)externalUserAgent
{
  if ([sCNRSUserAgent isEqualToString:externalUserAgent]) {
    return;
  }

  @synchronized (self) {
    sCNRSUserAgent = externalUserAgent;

    NSArray<NSString *> *externalUserAgents = [externalUserAgent componentsSeparatedByString:@" "];

    NSMutableString *newUserAgent = [NSMutableString string];
    NSString *oldUserAgent = [[UIWebView new] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    if (oldUserAgent) {
      [newUserAgent appendString:oldUserAgent];
    }

    for (NSString *item in externalUserAgents) {
      if (![newUserAgent containsString:item]) {
        [newUserAgent appendFormat:@" %@", item];
      }
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": newUserAgent}];

  }
}

+ (NSString *)externalUserAgent
{
  return sCNRSUserAgent;
}

+ (void)updateConfig
{
  CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
  routeManager.routesMapURL = sRoutesMapURL;
  [routeManager setCachePath:sRoutesCachePath];
  [routeManager setResoucePath:sRoutesResourcePath];
}

+ (void)setCacheEnable:(BOOL)isCacheEnable
{
  @synchronized (self) {
    sIsCacheEnable = isCacheEnable;
  }
}

+(BOOL)isCacheEnable
{
  return sIsCacheEnable;
}

+ (void)setRemoteFolderUrl:(NSURL *)remoteFolderUrl
{
    @synchronized (self) {
        sRemoteFolderUrl = remoteFolderUrl;
        sRoutesMapURL = [sRemoteFolderUrl URLByAppendingPathComponent:RoutesMapFile];
    }
}

+ (nullable NSURL *)remoteFolderUrl
{
    return sRemoteFolderUrl;
}

+ (void)setBackButtonImage:(UIImage *)image edgeInsets:(UIEdgeInsets)edgeInsets
{
    @synchronized (self) {
        sBackButtonImage = image;
        sBackButtonImageEdgeInsets = edgeInsets;
    }
}

+ (UIImage *)backButtonImage
{
    return sBackButtonImage;
}

+ (UIEdgeInsets )backButtonImageEdgeInsets
{
    return sBackButtonImageEdgeInsets;
}

+ (void)setDevelopModeEnable:(BOOL)isDevelopModeEnable
{
    @synchronized (self) {
        sIsDevelopModeEnable = isDevelopModeEnable;
    }
}

+ (BOOL)isDevelopModeEnable
{
    return sIsDevelopModeEnable;
}

+ (void)setLogEnable:(BOOL)isLogEnable
{
    @synchronized (self) {
        sIsLogEnable = isLogEnable;
    }
}

+ (BOOL)isLogEnable
{
    return sIsLogEnable;
}

@end
