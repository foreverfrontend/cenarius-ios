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
#import "CenariusConfigEntity.h"
#import "CNRSFileCopy.h"

#define kAppConfigVersionKey @"kAppConfigVersionKey"

@interface CNRSRouteManager ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) BOOL updatingRoutes;

/**
 * 队列
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end


@implementation CNRSRouteManager
@synthesize maxConcurrentOperationCount = _maxConcurrentOperationCount;

+ (CNRSRouteManager *)sharedInstance
{
    static CNRSRouteManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CNRSRouteManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)updateURLSession{
    if (_session) {
        [_session invalidateAndCancel];
        _session = nil;
    }
    if(_operationQueue) _operationQueue = nil;
    
    NSURLSessionConfiguration *sessionCfg       = [NSURLSessionConfiguration defaultSessionConfiguration];
    _operationQueue                             = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = self.maxConcurrentOperationCount;
    _session = [NSURLSession sessionWithConfiguration:sessionCfg
                                             delegate:nil
                                        delegateQueue:_operationQueue];
}

- (NSInteger)maxConcurrentOperationCount{
    return MAX(1, _maxConcurrentOperationCount);
}

- (void)setRoutesMapURL:(NSURL *)routesMapURL
{
    _routesMapURL = routesMapURL;
}

- (void)setCachePath:(NSString *)cachePath
{
    CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
    routeFileCache.cachePath = cachePath;
    NSArray *item = [routeFileCache routesWithData:[routeFileCache cacheRoutesMapFile]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cacheRoutes = [[NSMutableArray alloc] initWithArray:item];
    });
}


- (void)setResoucePath:(NSString *)resourcePath
{
    CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
    routeFileCache.resourcePath = resourcePath;
    self.resourceRoutes = [routeFileCache routesWithData:[routeFileCache resourceRoutesMapFile]];
}

+ (void)updateRouteFilesWithCompletion:(void (^)(BOOL success))completion
{
    [[CNRSRouteManager sharedInstance] updateRoutesWithCompletion:completion];
}

// 判断版本和更新H5文件
- (void)updateRoutesWithCompletion:(void (^)(BOOL success))completion
{
    if ([CNRSConfig isDevelopModeEnable])
    {
        completion(YES);
        return;
    }
    
    if (self.routesMapURL == nil) {
        CNRSDebugLog(@"[Warning] `routesRemoteURL` not set.");
        completion(NO);
        return;
    }
    
    if (self.updatingRoutes) {
        completion(NO);
        return;
    }
    
    self.updatingRoutes = YES;
    
    
    // 请求H5版本配置 API
    NSMutableURLRequest *requestConfig = [NSMutableURLRequest requestWithURL:[CNRSConfig getConfigUrl]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
    [[self.session dataTaskWithRequest:requestConfig completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
      {
          // 获取配置失败
          if (((NSHTTPURLResponse *)response).statusCode != 200) {
              completion(NO);
              self.updatingRoutes = NO;
          } else {
              CenariusConfigEntity *entity = [[CenariusConfigEntity alloc] initWithData:data];
              NSString *AppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
              // App小于最低版本支持
              if ([AppVersion floatValue] < [entity.iosMinVersion floatValue]) {
                  completion(YES);
                  self.updatingRoutes = NO;
              } else {
                  NSString *appConfigVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kAppConfigVersionKey];
                  // 版本相同不用更新
                  if ([entity.releaseVersion isEqualToString:appConfigVersion]) {
                      completion(YES);
                      self.updatingRoutes = NO;
                  } else {
                      [self _updateRouteAndHtmlWithCompletion:^(BOOL success) {
                          // 更新成功后保存版本号
                          if (success) {
                              [[NSUserDefaults standardUserDefaults] setObject:entity.releaseVersion forKey:kAppConfigVersionKey];
                          }
                          completion(success);
                      }];
                  }
              }
          }
    }] resume];
    
   
}

// 更新路由和H5文件
- (void)_updateRouteAndHtmlWithCompletion:(void (^)(BOOL success))completion {
    
    // 请求路由表 API
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.routesMapURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          dispatch_async(dispatch_get_main_queue(), ^{
              CNRSDebugLog(@"Download %@", response.URL);
              CNRSDebugLog(@"Response: %@", response);
              
              if (((NSHTTPURLResponse *)response).statusCode != 200) {
                  completion(NO);
                  self.updatingRoutes = NO;
                  return;
              }
              
              //先更新内存中的 routes
              CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
              self.routes = [routeFileCache routesWithData:data];
              
              __block NSInteger count = 0;
              
              [CNRSFileCopy resourceMoveToLibraryFinish:^(int d) {
                  float progress = d * 1.0f /count * 0.2;
                  [[NSNotificationCenter defaultCenter] postNotificationName:CNRSDownloadProgressNotification
                                                                      object:@(progress)];
              } finishAll:^{
                  //拷贝完成才读取缓存路由
                  [self setCachePath:[CNRSRouteFileCache sharedInstance].cachePath];
                  
                  [self cnrs_downloadFilesWithinRoutes:self.routes shouldDownloadAll:YES completion:^(BOOL success) {
                      if (success)
                      {
                          // 所有文件更新到最新，保存路由表
                          self.cacheRoutes = self.routes;
                          [routeFileCache saveRoutesMapFile:data];
                          self.updatingRoutes = NO;
                      }
                      else{
                          NSData *data = [routeFileCache dataWithRoutes:[self cacheRoutes]];
                          if(data)[routeFileCache saveRoutesMapFile:data];
                          self.updatingRoutes = NO;
                      }
                      completion(success);
                  }];
              } count:&count];
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
//    NSURL *baseUri = [NSURL URLWithString:uri.path];
//    CNRSRoute *route = [self routeForURI:baseUri];
//    return [self remoteHtmlURLForRoute:route uri:uri];
    
    NSURL *url = [NSURL URLWithString:[[[CNRSConfig remoteFolderUrl].absoluteString stringByAppendingString:@"/"] stringByAppendingString:uri.absoluteString]];
    return url;
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
    if ([url isHttpOrHttps])
    {
        uri = [self cnrs_deleteString:remoteFolderUrlString fromString:urlString];
    }
    //FILE
    else if (url.isFileURL)
    {
        //cache
        uri = [self cnrs_deleteString:routeFileCache.cachePath fromString:urlString];
        if (uri == nil)
        {
            //resource
            uri = [self cnrs_deleteString:routeFileCache.resourcePath fromString:urlString];
        }
    }
    
    if (uri)
    {
        uri = [NSURL URLWithString:[self cnrs_deleteSlash:uri.absoluteString]];
        return uri;
    }
    
    return nil;
}

#pragma mark - Private Methods

- (NSURL *)cnrs_deleteString:(NSString *)deleteString fromString:(NSString *)string
{
    if (deleteString && string)
    {
        NSRange range = [string rangeOfString:deleteString];
        if (range.location != NSNotFound)
        {
            NSString *finalString = [string substringFromIndex:range.location + range.length + 1];
            return [NSURL URLWithString:finalString];
        }
    }
    
    return nil;
}

/**
 *  下载 `routes` 中的资源文件。
 */
- (void)cnrs_downloadFilesWithinRoutes:(NSArray *)routes shouldDownloadAll:(BOOL)shouldDownloadAll completion:(void (^)(BOOL success))completion
{
//    [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:0];
    
    dispatch_queue_t queue               = dispatch_queue_create("CNRS-Download-Routes", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t disgroup            = dispatch_group_create();
    __weak __typeof(self) weakSelf       = self;
    __block BOOL isSuccess               = false;
    __block NSError *errorCompletion     = nil;
    __block NSInteger countIdx           = 0;
    __block NSMutableArray *updateRoutes = [NSMutableArray array];
    __block NSMutableArray *cacheRoutes  = [NSMutableArray array];
    __block void (^downloadCompletion)(NSInteger index,BOOL stop,NSError *error);
    
    if(self.cacheRoutes) {
        [updateRoutes addObjectsFromArray:self.cacheRoutes];
        [cacheRoutes addObjectsFromArray:self.cacheRoutes];
    }
    
    dispatch_group_enter(disgroup);
    downloadCompletion = ^(NSInteger index,BOOL stop,NSError *error){
        CGFloat progress = (index)*1.0f/routes.count * 0.8;
        if (index == routes.count || stop) {
            isSuccess       = !stop;
            errorCompletion = error;
            if (index == routes.count) {
                progress    = 1.0;
            }
            [weakSelf.session invalidateAndCancel];
            dispatch_group_leave(disgroup);
            
            downloadCompletion = nil;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CNRSDownloadProgressNotification
                                                            object:@(progress)];
    };

    dispatch_group_async(disgroup, queue, ^{
        if(![routes count]){
            downloadCompletion(0,true,nil);
        }else{
            [routes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                @autoreleasepool {
                    CNRSRoute *route               = obj;
                    
                    CNRSRoute *resourceRoute       = [[CNRSRouteFileCache sharedInstance] cnrs_cacheRouteForRoute:route cacheRoutes:&cacheRoutes];
                    if(resourceRoute)resourceRoute = updateRoutes[[updateRoutes indexOfObject:resourceRoute]];
                    
                    // 如果哈希值比对不上，则下载。
                    // 如果文件在本地文件存在（要么在缓存，要么在资源文件夹），什么都不需要做
                    
                    CNRSDebugLog(@"resourceRoute: %@ , hash : %@ , location: %@", resourceRoute?@"true":@"false",[resourceRoute.fileHash isEqualToString:route.fileHash]?@"true":@"false", [[CNRSRouteFileCache sharedInstance] cacheFilePathForUri:route.uri]?@"true":@"false");
                    
                    if (!resourceRoute || ![resourceRoute.fileHash isEqualToString:route.fileHash]
                        || ![[CNRSRouteFileCache sharedInstance] cacheFilePathForUri:route.uri])
                    {
                        // 文件不存在，下载下来
                        NSMutableURLRequest *request =
                        [NSMutableURLRequest requestWithURL:route.remoteHTML
                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                            timeoutInterval:60];
                        
                        NSURLSessionDownloadTask *downloadTask =
                        [weakSelf.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
                         {
                             ++countIdx;
                             CNRSDebugLog(@"Download %@", response.URL);
                             
                             if (error || ((NSHTTPURLResponse *)response).statusCode != 200)
                             {
                                 CNRSDebugLog(@"Fail to download remote html: %@", error);
                                 if (shouldDownloadAll)
                                 {
                                     if(downloadCompletion){
                                         if(downloadCompletion)downloadCompletion(countIdx,true,error);
                                     }
                                 }
                                 else
                                 {
                                     // 下载失败，仅删除旧文件
                                     [[CNRSRouteFileCache sharedInstance] saveRouteFileData:nil withRoute:route];
                                     if(downloadCompletion)downloadCompletion(countIdx,false,error);
                                 }
                             }else{
                                 // 下载成功，保存
                                 NSData *data = [NSData dataWithContentsOfURL:location];
                                 [[CNRSRouteFileCache sharedInstance] saveRouteFileData:data withRoute:route];
                                 
                                 if(resourceRoute)[resourceRoute updateRouteFileHash:route.fileHash];
                                 else[updateRoutes addObject:route];
                                 
                                 if(downloadCompletion)downloadCompletion(countIdx,false,error);
                             }
                         }];
                        
                        downloadTask.priority = NSURLSessionTaskPriorityLow;
                        [downloadTask resume];
                    }else{
                        if(downloadCompletion)downloadCompletion(++countIdx,false,nil);
                    }
                }
            }];
        }
    });
    
    dispatch_group_notify(disgroup, queue, ^{
        self.cacheRoutes = updateRoutes;
        if(completion)completion(isSuccess);
        
        updateRoutes = nil;
    });
}

- (void)cnrs_downloadFilesWithinRoutes:(NSArray *)routes shouldDownloadAll:(BOOL)shouldDownloadAll completion:(void (^)(BOOL success))completion index:(int)index
{
    __block int blockIndex = index;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (blockIndex >= routes.count)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
            return;
        }
        
        CNRSRoute *route = routes[index];
        
        // 如果文件在本地文件存在（要么在缓存，要么在资源文件夹），什么都不需要做
        if ([self localHtmlURLForURI:route.uri])
        {
            [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:++blockIndex];
            return;
        }
        
        // 文件不存在，下载下来
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:route.remoteHTML
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:60];
        NSURLSessionDownloadTask *downloadTask =
        [self.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
         {
             CNRSDebugLog(@"Download %@", response.URL);
             
             if (error || ((NSHTTPURLResponse *)response).statusCode != 200)
             {
                 CNRSDebugLog(@"Fail to download remote html: %@", error);
                 if (shouldDownloadAll)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         completion(NO);
                     });
                     return;
                 }
                 else
                 {
                     // 下载失败，仅删除旧文件
                     [[CNRSRouteFileCache sharedInstance] saveRouteFileData:nil withRoute:route];
                     [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:++blockIndex];
                     return;
                 }
             }
             
             // 下载成功，保存
             NSData *data = [NSData dataWithContentsOfURL:location];
             [[CNRSRouteFileCache sharedInstance] saveRouteFileData:data withRoute:route];
             [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:++blockIndex];
         }];
        
        downloadTask.priority = NSURLSessionTaskPriorityLow;
        [downloadTask resume];
    });
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
