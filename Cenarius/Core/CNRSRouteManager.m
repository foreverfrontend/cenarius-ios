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
#import "NSString+Cenarius.h"

#define kAppConfigVersionKey @"kAppConfigVersionKey"

@interface CNRSRouteManager ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) BOOL updatingRoutes;

/**
 * 队列
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) CGFloat progressReta;

/**
 下载最后调用的Block
 */
@property (nonatomic, copy) void(^downloadCompletionBlock)(int64_t index,BOOL stop);

/**
 互斥锁
 */
@property (nonatomic, strong) NSLock *lock;

/**
 需要更新的下载队列
 */
@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask *> *downloadQueue;

/**
 和下载队列呼应的CNRSRoute关系
 */
@property (nonatomic, strong) NSMutableDictionary *downloadRouteQueue;

/**
 记录下载失败，重试成功则剔除。
 */
@property (nonatomic, strong) NSMutableDictionary *downloadFailQueue;

/**
 下载总数
 */
@property (nonatomic, assign) int64_t totalBytesWritten;

/**
 已处理数量
 */
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;
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
        self.lock = [[NSLock alloc] init];
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
    sessionCfg.sharedContainerIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    sessionCfg.timeoutIntervalForRequest = 60;
    _operationQueue                             = [[NSOperationQueue alloc] init];
    _operationQueue.maxConcurrentOperationCount = self.maxConcurrentOperationCount;
    _session = [NSURLSession sessionWithConfiguration:sessionCfg
                                             delegate:self
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
    routeFileCache.cachePath           = cachePath;
    NSMutableDictionary *item          = [routeFileCache routeDictsWithData:[routeFileCache cacheRoutesMapFile]];
    self.cacheUriRoutes                = [[NSMutableDictionary alloc] initWithDictionary:item];
    self.cacheRoutes                   = [[NSMutableArray alloc] initWithArray:item.allValues];
}


- (void)setResoucePath:(NSString *)resourcePath
{
    CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
    routeFileCache.resourcePath        = resourcePath;
    NSMutableDictionary *item          = [routeFileCache routeDictsWithData:[routeFileCache resourceRoutesMapFile]];
    self.resourceUriRoutes             = [[NSMutableDictionary alloc] initWithDictionary:item];
    self.resourceRoutes                = [[NSMutableArray alloc] initWithArray:item.allValues];
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
    __weak __typeof(self) weakSelf = self;
    
    // 请求H5版本配置 API
    NSMutableURLRequest *requestConfig = [NSMutableURLRequest requestWithURL:[CNRSConfig getConfigUrl]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
    [[[NSURLSession sharedSession] dataTaskWithRequest:requestConfig completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
      {
          // 获取配置失败
          if (data == nil && ((NSHTTPURLResponse *)response).statusCode != 200) {
              completion(NO);
              weakSelf.updatingRoutes = NO;
          } else {
              NSString *cenarius_config = @"cenarius-config.json";
              
              void (^compareReleaseVersion)() = ^(){
                  // App小于最低版本支持
                  if(![CNRSFileCopy isCompareIosMinVersion:data] && [CNRSFileCopy isCompareReleaseVersion:data]){
                      [weakSelf _updateRouteAndHtmlWithCompletion:^(BOOL success) {
                          if ( success ){
                              NSFileManager *fm     = [NSFileManager defaultManager];
                              NSString *cachePath   = [[CNRSRouteFileCache sharedInstance] cachePath];
                              cachePath             = [cachePath stringByAppendingPathComponent:cenarius_config];
                              NSString *cacheString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                              
                              [fm removeItemAtPath:cachePath error:nil];
                              [cacheString writeToFile:cachePath atomically:true encoding:NSUTF8StringEncoding error:nil];
                          }
                          completion(success);
                          self.updatingRoutes = NO;
                      }];
                  }else{
                      [[NSNotificationCenter defaultCenter] postNotificationName:CNRSDownloadProgressNotification
                                                                          object:@(1)];
                      completion(YES);
                      self.updatingRoutes = NO;
                  }
              };
              
              self.progressReta = 1.0;
              
              NSString *resourcePath    = [[NSBundle mainBundle] pathForResource:@"www" ofType:nil];
              resourcePath              = [resourcePath stringByAppendingPathComponent:cenarius_config];
              NSData *resourceData      = [NSData dataWithContentsOfFile:resourcePath];
              
              if ([CNRSFileCopy isUnzipFileAtPath] && resourceData) {
                  if (![CNRSFileCopy isCompareIosMinVersion:data] && [CNRSFileCopy releaseVersion:data compare:resourceData]) {
                      self.progressReta = 0.5;
                  }
                  
                  [CNRSFileCopy resourceUnzipToLibraeyWithProgress:^(long entryNumber, long total) {
                      float progress = entryNumber * 1.0f / total * self.progressReta;
                      [[NSNotificationCenter defaultCenter] postNotificationName:CNRSDownloadProgressNotification
                                                                          object:@(progress)];
                  } completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
                      if (succeeded) {
                          
                          NSFileManager *fm   = [NSFileManager defaultManager];
                          NSString *cachePath = [[CNRSRouteFileCache sharedInstance] cachePath];
                          cachePath = [cachePath stringByAppendingPathComponent:cenarius_config];
                          
                          [fm removeItemAtPath:resourcePath error:nil];
                          [fm copyItemAtPath:resourcePath toPath:cachePath error:&error];
                          
                          compareReleaseVersion();
                      }else{
                          completion(NO);
                          self.updatingRoutes = NO;
                      }
                  }];
              }else compareReleaseVersion();
          }

    }] resume];
    
   
}

// 更新路由和H5文件
- (void)_updateRouteAndHtmlWithCompletion:(void (^)(BOOL success))completion {
    // 请求路由表 API
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.routesMapURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
    __weak __typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          dispatch_async(dispatch_get_main_queue(), ^{
              CNRSDebugLog(@"Download %@", response.URL);
              CNRSDebugLog(@"Response: %@", response);
              
              if (data == nil || ((NSHTTPURLResponse *)response).statusCode != 200) {
                  completion(NO);
                  weakSelf.updatingRoutes = NO;
                  return;
              }
              
              //先更新内存中的 routes
              CNRSRouteFileCache *routeFileCache = [CNRSRouteFileCache sharedInstance];
              weakSelf.routes = [routeFileCache routesWithData:data];
              
              //当值为0.5的时候，说明是从资源文件夹拷贝过来的。
              if (weakSelf.progressReta == 0.5f) {
                  [weakSelf setResoucePath:@"www"];
                  weakSelf.cacheRoutes = [NSMutableArray array];
                  if (weakSelf.resourceRoutes) {
                      [weakSelf.cacheRoutes addObjectsFromArray:weakSelf.resourceRoutes];
                  }
                  
                  weakSelf.cacheUriRoutes = [NSMutableDictionary dictionary];
                  if (weakSelf.resourceUriRoutes) {
                      [weakSelf.cacheUriRoutes addEntriesFromDictionary:weakSelf.resourceUriRoutes];
                  }
              }else{
                  [weakSelf setCachePath:@"www"];
              }
              
              if(weakSelf.downloadQueue)[weakSelf.downloadQueue removeAllObjects];
              else weakSelf.downloadQueue = [NSMutableArray array];
              
              if(weakSelf.downloadRouteQueue)[weakSelf.downloadRouteQueue removeAllObjects];
              else weakSelf.downloadRouteQueue = [NSMutableDictionary dictionary];
              
              if(weakSelf.downloadFailQueue)[weakSelf.downloadFailQueue removeAllObjects];
              else weakSelf.downloadFailQueue = [NSMutableDictionary dictionary];
              
              weakSelf.totalBytesWritten = [weakSelf.routes count];
              weakSelf.totalBytesExpectedToWrite = 0;
              
              
              [weakSelf cnrs_downloadFilesWithinRoutes:weakSelf.routes shouldDownloadAll:true completion:^(BOOL success,NSArray *updateRoutes) {
                  //Routes更新只从下载数据来更新，（data == nil） === 下载失败
                  weakSelf.updatingRoutes = NO;
                  NSData *data            = [routeFileCache dataWithRoutes:updateRoutes];
                  if(data){
                      [routeFileCache saveRoutesMapFile:data];
                  }else{
                      success = false;
                  }
                  completion(success);
              } progressReta:weakSelf.progressReta];
          });
      }] resume];
}

- (NSURL *)localHtmlURLForURI:(NSURL *)uri
{
//    //先在缓存文件夹中寻找，再在资源文件夹中寻找。如果在缓存文件和资源文件中都找不到对应的本地文件，返回 nil
    if (uri == nil)
    {
        return nil;
    }
//    NSURL *baseUri = [NSURL URLWithString:uri.path];
//    //最新的在内存中的 route
//    CNRSRoute *route = [self routeForURI:baseUri];
//    return [self localHtmlURLForRoute:route uri:uri];
    NSString *urlString = [@"file://" stringByAppendingString:[[CNRSRouteFileCache sharedInstance] cacheFilePathForUri:uri]];
    NSURL *htmlFileURL = [NSURL URLWithString:urlString];
    return htmlFileURL;
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
#pragma mark - NSURLSessionDelegate
// 当系统错误或者已经被销毁的时候，error 为nil
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    if (!error) {
        [self.session invalidateAndCancel];
        self.session = nil;
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    CNRSRoute *route = [self routeForTask:task];
    CNRSRoute *cacheUriRoute = self.cacheUriRoutes[route.uri.absoluteString];
    [cacheUriRoute updateRouteFileHash:error?@"下载失败需要改变hash":route.fileHash];
    if (error) {
        CNRSDebugLog(@"Fail to download remote html: %@", error);
        // 下载失败，仅删除旧文件
        [[CNRSRouteFileCache sharedInstance] saveRouteFileData:nil withRoute:route];
        
        //-1009 "似乎已断开与互联网的连接。"
        //-1005 网络连接已中断
        if (error.code == -1005 || error.code == -1009) {
            self.downloadCompletionBlock(self.totalBytesExpectedToWrite, true);
        }else{
            //下载失败重试, 下载失败需要判断是网络超时，还是没有网络，还是其他错误。 没有网络，不需要重试
            [self downloadCompletion:false task:task didCompleteWithError:error];
        }
    }else{
        [self downloadCompletion:true task:task didCompleteWithError:error];
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    // 下载成功，保存
    NSData *data = [NSData dataWithContentsOfURL:location];
    [[CNRSRouteFileCache sharedInstance] saveRouteFileData:data withRoute:[self routeForTask:downloadTask]];
    
    [self resume:1];
}
#pragma mark -
- (void)resume:(NSUInteger)maxConcurrentOperationCount{
    [self.lock lock];
    for (int i = 0 ; i < maxConcurrentOperationCount; i++) {
        if ([self.downloadQueue count]) {
            [[self.downloadQueue lastObject] resume];
            [self.downloadQueue removeLastObject];
        }
    }
    [self.lock unlock];
}
- (void)downloadCompletion:(BOOL)success task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self.lock lock];
    
    if (success) {
        self.totalBytesExpectedToWrite++;
        [self.downloadFailQueue removeObjectForKey:@(task.taskIdentifier)];
    }else{
        NSParameterAssert(task);
        NSParameterAssert(error);
        
        int count = [self.downloadFailQueue[@(task.taskIdentifier)] intValue];
        if (count < 2) {
            NSData *resume_data = error.userInfo[NSURLSessionDownloadTaskResumeData];
            NSURLSessionDownloadTask* new_task = nil;
            if (resume_data) {
                new_task = [_session downloadTaskWithResumeData:resume_data];
            }else{
                new_task = [_session downloadTaskWithRequest:task.currentRequest];
            }
            
            self.downloadFailQueue[@(new_task.taskIdentifier)] = @(++count);
            [self.downloadFailQueue removeObjectForKey:@(task.taskIdentifier)];
            [self.lock unlock];
            CNRSRoute *route = [self routeForTask:task];
            [self setRoute:route forTask:new_task];
            [new_task resume];
            
            return;
        }
    }
    
    BOOL isStop = false;
    if (self.totalBytesWritten == self.totalBytesExpectedToWrite + [self.downloadFailQueue count] + [self.downloadQueue count]) {
        isStop = [self.downloadFailQueue count]?true:false;
    }
    if(self.downloadCompletionBlock)self.downloadCompletionBlock(self.totalBytesExpectedToWrite, isStop);
    [self.lock unlock];
}
- (CNRSRoute *)routeForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    CNRSRoute *route = nil;
    [self.lock lock];
    route = self.downloadRouteQueue[@(task.taskIdentifier)];
    [self.lock unlock];
    
    return route;
}
- (void)setRoute:(CNRSRoute *)route
            forTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    NSParameterAssert(route);
    
    [self.lock lock];
    self.downloadRouteQueue[@(task.taskIdentifier)] = route;
    [self.lock unlock];
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
- (void)cnrs_downloadFilesWithinRoutes:(NSArray *)routes shouldDownloadAll:(BOOL)shouldDownloadAll completion:(void (^)(BOOL success,NSArray *updateRoutes))completion progressReta:(float)progressReta
{
//    [self cnrs_downloadFilesWithinRoutes:routes shouldDownloadAll:shouldDownloadAll completion:completion index:0];
    
    dispatch_queue_t queue               = dispatch_queue_create("CNRS-Download-Routes", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t disgroup            = dispatch_group_create();
    __weak __typeof(self) weakSelf       = self;
    __block BOOL isSuccess               = false;
    __block CGFloat progress = 0.0;
    
    dispatch_group_enter(disgroup);
    progressReta = MIN(MAX(progressReta, 0.5), 1.0);
    self.downloadCompletionBlock = ^(int64_t index,BOOL stop){
        if(stop){
            if(progress >= 1) progress = 0.99;
        }else{
            if (index == routes.count){
                progress = 1.0;
            }else
                progress = (index)*1.0f/routes.count * progressReta + (progressReta==1.0?0.0:0.5);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CNRSDownloadProgressNotification
                                                            object:@(progress)];
        
        if (index == routes.count || stop) {
            isSuccess       = !stop;
            
            [weakSelf.session invalidateAndCancel];
            weakSelf.session = nil;
            
            dispatch_group_leave(disgroup);
        }
    };

    dispatch_group_async(disgroup, queue, ^{
        if(![routes count]){
            weakSelf.downloadCompletionBlock(0, true);
        }else{
            [weakSelf cnrs_downloadTaskWithinRoutes:routes shouldDownloadAll:shouldDownloadAll];
        }
    });
    
    dispatch_group_notify(disgroup, queue, ^{
        if(completion)completion(isSuccess,weakSelf.cacheUriRoutes.allValues);
        weakSelf.downloadCompletionBlock = nil;
    });
}
- (void)cnrs_downloadTaskWithinRoutes:(NSArray *)routes shouldDownloadAll:(BOOL)shouldDownloadAll{
    __weak __typeof(self) weakSelf       = self;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    for (id obj in routes) {
        @autoreleasepool {
            CNRSRoute *route               = obj;
            CNRSRoute *resourceRoute       = weakSelf.cacheUriRoutes[[route.uri absoluteString]];
            
            // 如果哈希值比对不上，则下载。
            // 如果文件在本地文件存在（要么在缓存，要么在资源文件夹），什么都不需要做
            CNRSDebugLog(@"resourceRoute: %@ , hash : %@ , location: %@", resourceRoute?@"true":@"false",[resourceRoute.fileHash isEqualToString:route.fileHash]?@"true":@"false", [[CNRSRouteFileCache sharedInstance] cacheFilePathForUri:route.uri]?@"true":@"false");
            // 检查本地是否存存在
            NSString *routeFilePath = [[CNRSRouteFileCache sharedInstance] cacheFilePathForUri:route.uri];
            BOOL isFileExists =  [fm fileExistsAtPath:routeFilePath];
            
            if ((!resourceRoute || ![resourceRoute.fileHash isEqualToString:route.fileHash]
                 || !isFileExists)
                && weakSelf.session)
            {
                NSParameterAssert(weakSelf.session);
                if(resourceRoute == nil){
                    //新增文件
                    weakSelf.cacheUriRoutes[[route.uri absoluteString]] = route;
                }
                // 文件不存在，下载下来
                NSMutableURLRequest *request =
                [NSMutableURLRequest requestWithURL:route.remoteHTML
                                        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                    timeoutInterval:60];
                
                NSURLSessionDownloadTask *downloadTask = [weakSelf.session downloadTaskWithRequest:request];
                
                CNRSDebugLog(@"resourceRoute download url: %@ ", [route.uri absoluteString]);
                
                downloadTask.priority = NSURLSessionTaskPriorityLow;
                [self.downloadQueue addObject:downloadTask];
                [self setRoute:route forTask:downloadTask];
            }else{
                [self downloadCompletion:true task:nil didCompleteWithError:nil];
            }
        }
    }
    if([self.downloadQueue count])[self resume:self.maxConcurrentOperationCount];
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

#pragma mark - CNRSRoute

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
