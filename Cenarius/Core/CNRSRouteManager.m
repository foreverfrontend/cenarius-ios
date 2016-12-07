//
//  CNRSRouteManager.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSRouteManager.h"
#import "CNRSRouteFileCache.h"
#import "CNRSConfig.h"
#import "CNRSRoute.h"
#import "CNRSLogging.h"
#import "NSURL+Cenarius.h"

@interface CNRSRouteManager ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) BOOL updatingRoutes;

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
    }
    return self;
}

- (void)setRoutesMapURL:(NSURL *)routesMapURL
{
    if (_routesMapURL != routesMapURL) {
        _routesMapURL = routesMapURL;
        CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
        self.cacheRoutes = [routeFileCache routesWithData:[routeFileCache cacheRoutesMapFile]];
    }
}

- (void)setCachePath:(NSString *)cachePath
{
    CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
    routeFileCache.cachePath = cachePath;
    self.cacheRoutes = [routeFileCache routesWithData:[routeFileCache cacheRoutesMapFile]];
}

- (void)setResoucePath:(NSString *)resourcePath
{
    CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
    routeFileCache.resourcePath = resourcePath;
    self.resourceRoutes = [routeFileCache routesWithData:[routeFileCache resourceRoutesMapFile]];
}

- (void)updateRoutesWithCompletion:(void (^)(BOOL success))completion
{
    NSParameterAssert([NSThread isMainThread]);
    
    if (self.routesMapURL == nil) {
        CNRSDebugLog(@"[Warning] `routesRemoteURL` not set.");
        return;
    }
    
    if (self.updatingRoutes) {
        completion(NO);
        return;
    }
    
    self.updatingRoutes = YES;
    
    // 请求路由表 API
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.routesMapURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
    //    // 更新 Http UserAgent Header
    //    NSString *externalUserAgent = [CNRSConfig externalUserAgent];
    //    if (externalUserAgent) {
    //        NSString *userAgent = [request.allHTTPHeaderFields objectForKey:@"User-Agent"];
    //        NSString *newUserAgent = externalUserAgent;
    //        if (userAgent) {
    //            newUserAgent = [@[userAgent, externalUserAgent] componentsJoinedByString:@" "];
    //        }
    //        [request setValue:newUserAgent forHTTPHeaderField:@"User-Agent"];
    //    }
    
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          dispatch_async(dispatch_get_main_queue(), ^{
              CNRSDebugLog(@"Download %@", response.URL);
              CNRSDebugLog(@"Response: %@", response);
              
              if (((NSHTTPURLResponse *)response).statusCode != 200) {
//                  if (self.cacheRoutes)
//                  {
//                      self.routes = self.cacheRoutes;
//                  }
//                  else
//                  {
//                      self.routes = self.resourceRoutes;
//                  }
                  completion(NO);
                  self.updatingRoutes = NO;
                  return;
              }
              
              //先更新内存中的 routes
              CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
              self.routes = [routeFileCache routesWithData:data];
              
              //优先下载
              NSArray *downloadFirstList = [CNRSConfig downloadFirstList];
              NSMutableArray *downloadFirstRoutes = [[NSMutableArray alloc] init];
              for (NSString *uri in downloadFirstList)
              {
                  CNRSRoute *route = [self routeForURI:[NSURL URLWithString:uri]];
                  [downloadFirstRoutes addObject:route];
              }
              
              dispatch_async(dispatch_get_global_queue(0, 0), ^{
                  [self cnrs_downloadFilesWithinRoutes:downloadFirstRoutes shouldDownloadAll:YES completion:^(BOOL success) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if (success)
                          {
                              if (self.cacheRoutes == nil)
                              {
                                  //优先下载成功，如果没有 cacheRoutes，立马保存
                                  self.cacheRoutes = self.routes;
                                  [routeFileCache saveRoutesMapFile:data];
                              }
                              else{
                                  //优先下载成功，把下载成功的 routes 加入 cacheRoutes 的最前面
                                  self.cacheRoutes = [NSMutableArray arrayWithArray:[downloadFirstRoutes arrayByAddingObjectsFromArray:self.cacheRoutes]];
                              }
                              completion(YES);
                              
                              dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                  //然后下载最新 routes 中的资源文件
                                  [self cnrs_downloadFilesWithinRoutes:self.routes shouldDownloadAll:NO completion:^(BOOL success) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          if (success)
                                          {
                                              // 所有文件更新到最新，保存路由表
                                              self.cacheRoutes = self.routes;
                                              [routeFileCache saveRoutesMapFile:data];
                                              self.updatingRoutes = NO;
                                          }
                                          else{
                                              self.updatingRoutes = NO;
                                          }
                                      });
                                  }];
                              });
                          }
                          else
                          {
                              //优先下载失败
                              completion(NO);
                              self.updatingRoutes = NO;
                          }
                      });
                  }];
              });
          });
      }] resume];
}

- (NSURL *)localHtmlURLForURI:(NSURL *)uri
{
    //先在缓存文件夹中寻找，再在资源文件夹中寻找。如果在缓存文件和资源文件中都找不到对应的本地文件，返回 nil
    if (uri == nil)
    {
        return nil;
    }
    NSURL *baseUri = [NSURL URLWithString:uri.path];
    //最新的在内存中的 route
    CNRSRoute *route = [self routeForURI:baseUri];
    return [self localHtmlURLForRoute:route uri:uri];
}

- (NSURL *)localHtmlURLForRoute:(CNRSRoute *)route uri:(NSURL *)uri
{
    NSURL *url = [[CNRSRouteFileCache sharedInstance] routeFileURLForRoute:route];
    return [self finalUrlWithBaseUrl:url uri:uri];
}

- (NSURL *)remoteHtmlURLForURI:(NSURL *)uri
{
    NSURL *baseUri = [NSURL URLWithString:uri.path];
    CNRSRoute *route = [self routeForURI:baseUri];
    return [self remoteHtmlURLForRoute:route uri:uri];
}

- (NSURL *)remoteHtmlURLForRoute:(CNRSRoute *)route uri:(NSURL *)uri
{
    return [self finalUrlWithBaseUrl:route.remoteHTML uri:uri];
}

- (NSURL *)finalUrlWithBaseUrl:(NSURL *)url uri:(NSURL *)uri
{
    if (url != nil)
    {
        NSString *query = uri.query;
        NSString *fragment = uri.fragment;
        NSString *urlString = url.absoluteString;
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
        @autoreleasepool {
            if ([route.remoteHTML.absoluteString isEqualToString:URL.absoluteString])
            {
                return route;
            }
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
- (void)cnrs_downloadFilesWithinRoutes:(NSArray *)routes shouldDownloadAll:(BOOL)shouldDownloadAll completion:(void (^)(BOOL success))completion
{
    [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:0];
}

- (void)cnrs_downloadFilesWithinRoutes:(NSArray *)routes shouldDownloadAll:(BOOL)shouldDownloadAll completion:(void (^)(BOOL success))completion index:(int)index
{
    if (index >= routes.count)
    {
        completion(YES);
        return;
    }
    
    CNRSRoute *route = routes[index];
    __block int blockIndex = index;
    
    // 如果文件在本地文件存在（要么在缓存，要么在资源文件夹），什么都不需要做
    if ([self localHtmlURLForURI:route.uri])
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:++blockIndex];
        });
        return;
    }
    
    // 文件不存在，下载下来
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:route.remoteHTML
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
      {
          CNRSDebugLog(@"Download %@", response.URL);
          
          if (error || ((NSHTTPURLResponse *)response).statusCode != 200)
          {
              CNRSDebugLog(@"Fail to download remote html: %@", error);
              if (shouldDownloadAll)
              {
                  completion(NO);
                  return;
              }
              else
              {
                  dispatch_async(dispatch_get_global_queue(0, 0), ^{
                      // 下载失败，仅删除旧文件
                      [[CNRSRouteFileCache sharedInstance] saveRouteFileData:nil withRoute:route];
                      [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:++blockIndex];
                  });
                  return;
              }
          }
          
          dispatch_async(dispatch_get_global_queue(0, 0), ^{
              NSData *data = [NSData dataWithContentsOfURL:location];
              [[CNRSRouteFileCache sharedInstance] saveRouteFileData:data withRoute:route];
              [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:++blockIndex];
          });
      }];
    
    downloadTask.priority = NSURLSessionTaskPriorityLow;
    [downloadTask resume];
}

- (CNRSRoute *)routeForURI:(NSURL *)uri
{
    uri = [NSURL URLWithString:[self cnrs_deleteSlash:uri.absoluteString]];
    NSString *uriString = uri.absoluteString;
    if (uriString.length == 0) {
        return nil;
    }
    
    //路由表
    for (CNRSRoute *route in self.routes)
    {
        @autoreleasepool {
            if ([route.uri.absoluteString isEqualToString:uri.absoluteString])
            {
                return route;
            }
        }
    }
    
    return nil;
}

- (BOOL)isInRoutes:(NSURL *)uri
{
    CNRSRoute *route = [self routeForURI:uri];
    if (route)
    {
        //uri 在路由表中
        return YES;
    }
    return NO;
}

- (BOOL)isInWhiteList:(NSURL *)uri
{
    NSArray *whiteList = [CNRSConfig routesWhiteList];
    for (NSString *path in whiteList)
    {
        @autoreleasepool {
            if ([uri.pathComponents.firstObject hasPrefix:path])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)isUpdatingRoutes{
    return self.updatingRoutes;
}

/**
 删除多余 /
 */
- (NSString *)cnrs_deleteSlash:(NSString *)uri
{
    if ([uri containsString:@"//"])
    {
        uri = [uri stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
        uri = [self cnrs_deleteSlash:uri];
    }
    if ([uri hasPrefix:@"/"])
    {
        uri = [uri substringFromIndex:1];
    }
    return uri;
}

@end
