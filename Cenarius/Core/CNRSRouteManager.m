//
//  CNRSRouteManager.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CNRSRouteManager.h"
#import "CNRSRouteFileCache.h"
#import "CNRSConfig.h"
#import "CNRSRoute.h"
#import "CNRSLogging.h"
#import "NSURL+Cenarius.h"

@interface CNRSRouteManager ()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSArray<CNRSRoute *> *routes;
@property (nonatomic, assign) BOOL updatingRoutes;
@property (nonatomic, strong) NSMutableArray *updateRoutesCompletions;

@end


@implementation CNRSRouteManager

+ (CNRSRouteManager *)sharedInstance
{
  static CNRSRouteManager *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[CNRSRouteManager alloc] init];
    instance.routesMapURL = [CNRSConfig routesMapURL];
  });
  return instance;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    NSURLSessionConfiguration *sessionCfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:sessionCfg
                                             delegate:nil
                                        delegateQueue:[[NSOperationQueue alloc] init]];

    _updateRoutesCompletions = [NSMutableArray array];
  }
  return self;
}

- (void)setRoutesMapURL:(NSURL *)routesMapURL
{
  if (_routesMapURL != routesMapURL) {
    _routesMapURL = routesMapURL;
      CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
    self.routes = [routeFileCache routesWithData:[[CNRSRouteFileCache sharedInstance] routesMapFile]];
  }
}

- (void)setCachePath:(NSString *)cachePath
{
  CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
  routeFileCache.cachePath = cachePath;
  self.routes = [routeFileCache routesWithData:[routeFileCache routesMapFile]];
}

- (void)setResoucePath:(NSString *)resourcePath
{
  CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
  routeFileCache.resourcePath = resourcePath;
  self.routes = [routeFileCache routesWithData:[routeFileCache routesMapFile]];
}

- (void)updateRoutesWithCompletion:(void (^)(BOOL success))completion
{
  NSParameterAssert([NSThread isMainThread]);

  if (self.routesMapURL == nil) {
    CNRSDebugLog(@"[Warning] `routesRemoteURL` not set.");
    return;
  }

  if (completion) {
    [self.updateRoutesCompletions addObject:completion];
  }

  if (self.updatingRoutes) {
    return;
  }

  self.updatingRoutes = YES;

  void (^APICompletion)(BOOL) = ^(BOOL success){
    dispatch_async(dispatch_get_main_queue(), ^{
      for (void (^item)(BOOL) in self.updateRoutesCompletions) {
        item(success);
      }
      [self.updateRoutesCompletions removeAllObjects];
      self.updatingRoutes = NO;
    });
  };

  // 请求路由表 API
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.routesMapURL
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:60];
  // 更新 Http UserAgent Header
  NSString *externalUserAgent = [CNRSConfig externalUserAgent];
  if (externalUserAgent) {
    NSString *userAgent = [request.allHTTPHeaderFields objectForKey:@"User-Agent"];
    NSString *newUserAgent = externalUserAgent;
    if (userAgent) {
      newUserAgent = [@[userAgent, externalUserAgent] componentsJoinedByString:@" "];
    }
    [request setValue:newUserAgent forHTTPHeaderField:@"User-Agent"];
  }

  [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    CNRSDebugLog(@"Download %@", response.URL);
    CNRSDebugLog(@"Response: %@", response);

    if (((NSHTTPURLResponse *)response).statusCode != 200) {
      APICompletion(NO);
      return;
    }

      //先更新 `routes.json` 及内存中的 `routes`，然后下载最新 routes 中的资源文件
      CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
      NSArray *routes = [routeFileCache routesWithData:data];
      self.routes = routes;
      [routeFileCache saveRoutesMapFile:data];
      [self cnrs_downloadFilesWithinRoutes:routes completion:^(BOOL success) {
      if (success) {
//        self.routes = routes;
//        CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
//        [routeFileCache saveRoutesMapFile:data];
      }

      APICompletion(success);
    }];
  }] resume];
}

- (NSURL *)localHtmlURLForURI:(NSURL *)uri
{
    //先在缓存文件夹中寻找，再在资源文件夹中寻找。如果在缓存文件和资源文件中都找不到对应的本地文件，返回 nil
    NSURL *baseUri = [NSURL URLWithString:uri.path];
    CNRSRoute *route = [self cnrs_routeForURI:baseUri];
    NSURL *url = [[CNRSRouteFileCache sharedInstance] routeFileURLForRoute:route];
    
    return [self finalUrlWithBaseUrl:url uri:uri];
}

- (NSURL *)remoteHtmlURLForURI:(NSURL *)uri
{
    NSURL *baseUri = [NSURL URLWithString:uri.path];
    CNRSRoute *route = [self cnrs_routeForURI:baseUri];
    if (route)
    {
        return  [self finalUrlWithBaseUrl:route.remoteHTML uri:uri];
    }
    return nil;
}

- (NSURL *)finalUrlWithBaseUrl:(NSURL *)url uri:(NSURL *)uri
{
    if (url != nil)
    {
        NSString *parameterString = uri.parameterString;
        NSString *query = uri.query;
        NSString *fragment = uri.fragment;
        NSString *urlString = url.absoluteString;
        if (parameterString.length > 0) {
            urlString = [[NSString alloc] initWithFormat:@"%@;%@",urlString,parameterString];
        }
        if (query.length > 0) {
            urlString = [[NSString alloc] initWithFormat:@"%@?%@",urlString,query];
        }
        if (fragment.length > 0) {
            urlString = [[NSString alloc] initWithFormat:@"%@#%@",urlString,fragment];
        }
        url = [NSURL URLWithString:urlString];
    }
    
    return url;
}

//- (BOOL)isRoutesContainRemoteURL:(NSURL *)remoteURL
//{
//    CNRSRoute *route = [self routeForRemoteURL:remoteURL];
//    if (route) {
//        return YES;
//    }
//    return NO;
//}

- (CNRSRoute *)routeForRemoteURL:(NSURL *)remoteURL
{
    NSURL *URL = [[NSURL alloc] initWithScheme:[remoteURL scheme]
                                          host:[remoteURL host]
                                          path:[remoteURL path]];
    for (CNRSRoute *route in self.routes)
    {
        if ([route.remoteHTML.absoluteString isEqualToString:URL.absoluteString])
        {
            return route;
        }
    }
    return nil;
}

- (NSURL *)uriForUrl:(NSURL *)url
{
    NSURL *uri = nil;
    CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
    NSString *urlString = url.absoluteString;
    //HTTP
    NSString *remoteFolderUrlString = [CNRSConfig remoteFolderUrl].absoluteString;
    if ([url cnrs_isHttpOrHttps])
    {
        uri = [self cnrs_deleteString:remoteFolderUrlString fromString:urlString];
        if (uri)
        {
            return uri;
        }
    }
    //FILE
    if (url.isFileURL)
    {
        //cache
        uri = [self cnrs_deleteString:routeFileCache.cachePath fromString:urlString];
        if (uri)
        {
            return uri;
        }
        //resource
        else
        {
            uri = [self cnrs_deleteString:routeFileCache.resourcePath fromString:urlString];
            if (uri)
            {
                return uri;
            }
        }
    }
    
    return nil;
}

#pragma mark - Private Methods

- (NSURL *)cnrs_deleteString:(NSString *)deleteString fromString:(NSString *)string
{
    NSRange range = [string rangeOfString:deleteString];
    if (range.location != NSNotFound)
    {
        NSString *finalString = [string substringFromIndex:range.location + range.length + 1];
        return [NSURL URLWithString:finalString];
    }
    return nil;
}

/**
 *  下载 `routes` 中的资源文件。
 */
- (void)cnrs_downloadFilesWithinRoutes:(NSArray *)routes completion:(void (^)(BOOL success))completion
{
  dispatch_group_t downloadGroup = nil;
  if (completion) {
    downloadGroup = dispatch_group_create();
  }

  BOOL __block success = YES;

  for (CNRSRoute *route in routes) {

    // 如果文件在本地文件存在（要么在缓存，要么在资源文件夹），什么都不需要做
      if ([self localHtmlURLForURI:route.uri]) {
      continue;
    }

    if (downloadGroup) { dispatch_group_enter(downloadGroup); }

    // 文件不存在，下载下来。
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:route.remoteHTML
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
    [[self.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {

      CNRSDebugLog(@"Download %@", response.URL);
//      CNRSDebugLog(@"Response: %@", response);

      if (error || ((NSHTTPURLResponse *)response).statusCode != 200) {
        success = NO;
        if (downloadGroup) { dispatch_group_leave(downloadGroup); }

        CNRSDebugLog(@"Fail to move download remote html: %@", error);
        return;
      }

      NSData *data = [NSData dataWithContentsOfURL:location];
      [[CNRSRouteFileCache sharedInstance] saveRouteFileData:data withRoute:route];

      if (downloadGroup) { dispatch_group_leave(downloadGroup); }
    }] resume];
  }

  if (downloadGroup) {
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
      completion(success);
    });
  }
}

- (CNRSRoute *)cnrs_routeForURI:(NSURL *)uri
{
    NSString *uriString = uri.absoluteString;
    if (uriString.length == 0) {
        return nil;
    }
    
    for (CNRSRoute *route in self.routes)
    {
        if ([route.uri.absoluteString isEqualToString:uri.absoluteString])
        {
            return route;
        }
    }
    
    return nil;
}

@end
