//
//  CNRSRouteFileCache.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSRouteFileCache.h"
#import "CNRSConfig.h"
#import "CNRSRoute.h"
#import "CNRSLogging.h"
#import "NSData+CNRSDigest.h"
#import "CNRSRouteManager.h"

@implementation CNRSRouteFileCache

+ (CNRSRouteFileCache *)sharedInstance
{
    static CNRSRouteFileCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CNRSRouteFileCache alloc] init];
        instance.cachePath = [CNRSConfig routesCachePath];
        instance.resourcePath = [CNRSConfig routesResourcePath];
    });
    return instance;
}

- (instancetype)initWithCachePath:(NSString *)cachePath
                     resourcePath:(NSString *)resourcePath
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - Save & Read methods

- (void)setCachePath:(NSString *)cachePath
{
    // cache dir
    if (!cachePath) {
        //    // 默认缓存路径：<Library>/<bundle identifier>.cenarius
        //    cachePath = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".cenarius"];
        
        // 默认缓存路径：<Library>/www
        cachePath = @"www";
    }
    
    if (![cachePath isAbsolutePath]) {
        cachePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)
                      firstObject] stringByAppendingPathComponent:cachePath];
    }
    
    _cachePath = [cachePath copy];
    
    NSURL *cachePathUrl = [NSURL URLWithString:_cachePath];
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtURL:cachePathUrl withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        CNRSDebugLog(@"Failed to create directory: %@", _cachePath);
    }
    // 把这个目录设置为不用iCloud备份
    [cachePathUrl setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
}

- (void)setResourcePath:(NSString *)resourcePath
{
    // resource dir
    if (!resourcePath && [resourcePath length] > 0) {
        // 默认资源路径：<Bundle>/cenarius
        resourcePath = [[NSBundle mainBundle] pathForResource:@"cenarius" ofType:nil];
    }
    
    if (![resourcePath isAbsolutePath]) {
        resourcePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:resourcePath];
    }
    _resourcePath = [resourcePath copy];
}

- (void)cleanCache
{
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:self.cachePath error:nil];
    [manager createDirectoryAtPath:self.cachePath
       withIntermediateDirectories:YES
                        attributes:@{}
                             error:NULL];
}

- (void)saveRoutesMapFile:(NSArray *)routes cacheRoutes:(NSArray *)cacheRoutes
{
    NSString *filePath = [self.cachePath stringByAppendingPathComponent:RoutesMapFile];
    if (routes == nil) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    } else {
        //删除不用的和更新的文件
        if (routes && cacheRoutes)
        {
            [self cnrs_deleteOldFilesWithNewRoutes:routes oldRoutes:cacheRoutes];
        }
        //保存新routes
        [routes writeToFile:filePath atomically:YES];
    }
}

- (NSData *)routesMapFile
{
    NSData *cacheRoutesMapFile = [self cacheRoutesMapFile];
    if (cacheRoutesMapFile)
    {
        return cacheRoutesMapFile;
    }
    
    NSData *resourceRoutesMapFile = [self resourceRoutesMapFile];
    if (resourceRoutesMapFile)
    {
        return resourceRoutesMapFile;
    }
    
    return nil;
}

- (NSData *)cacheRoutesMapFile
{
    NSString *filePath = [self.cachePath stringByAppendingPathComponent:RoutesMapFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return [NSData dataWithContentsOfFile:filePath];
    }
    
    return nil;
}

- (NSData *)resourceRoutesMapFile
{
    NSString *filePath = [self.resourcePath stringByAppendingPathComponent:RoutesMapFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [NSData dataWithContentsOfFile:filePath];
    }
    
    return nil;
}

- (void)saveRouteFileData:(NSData *)data withRoute:(CNRSRoute *)route
{
    NSString *filePath = [self cnrs_cacheRouteFilePathForRoute:route];
    if (data == nil)
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    else
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 删除旧文件
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtURL:[NSURL URLWithString:filePath] error:nil];
        }
        
        // 创建目录
        [fileManager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        // 写数据
        [data writeToFile:filePath atomically:YES];
    }
}

- (NSArray *)routesWithData:(NSData *)data
{
    if (data == nil) {
        return nil;
    }
    
    NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (JSON == nil) {
        return nil;
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSDictionary *item in JSON)
    {
        @autoreleasepool {
            [items addObject:[[CNRSRoute alloc] initWithDictionary:item]];
        }
    }
    
    return items;
}

- (NSURL *)routeFileURLForRoute:(CNRSRoute *)route
{
    if (route == nil)
    {
        return nil;
    }
    
    NSURL *cacheRouteFileURL = [self cnrs_cacheRouteFileURLForRoute:route];
    if (cacheRouteFileURL)
    {
        return cacheRouteFileURL;
    }
    
    NSURL *resourceRouteFileURL = [self cnrs_resourceRouteFileURLForRoute:route];
    if (resourceRouteFileURL)
    {
        return resourceRouteFileURL;
    }
    
    
    return nil;
}

- (NSString *)cacheFilePathForUri:(NSURL *)uri{
    NSString *cacheFilePath = [self.cachePath stringByAppendingPathComponent:uri.absoluteString];
    return cacheFilePath;
}

- (NSString *)resourceFilePathForUri:(NSURL *)uri
{
    NSString *resourceFileName = uri.absoluteString;
    NSString *resourceFilePath = [self.resourcePath stringByAppendingPathComponent:resourceFileName];
    return resourceFilePath;
}

#pragma mark - Private methods

/**
 读取 route 对应的缓存路径
 */
- (NSURL *)cnrs_cacheRouteFileURLForRoute:(CNRSRoute *)route
{
    NSString *cacheFilePath = [self cnrs_cacheRouteFilePathForRoute:route];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath])
    {
        return [NSURL fileURLWithPath:cacheFilePath];
    }
    return nil;
}

- (NSString *)cnrs_cacheRouteFilePathForRoute:(CNRSRoute *)route
{
    //路由表正在更新的时候需要对比 hash
    CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
    if (routeManager.cacheRoutes && routeManager.cacheRoutes != routeManager.routes)
    {
        for (CNRSRoute *cacheRoute in routeManager.cacheRoutes)
        {
            @autoreleasepool
            {
                if ([cacheRoute.fileHash isEqualToString:route.fileHash])
                {
                    return [self cacheFilePathForUri:cacheRoute.uri];
                }
            }
        }
        
        return nil;
    }
    else
    {
        return [self cacheFilePathForUri:route.uri];
    }
}

/**
 读取 route 对应的资源路径
 */
- (NSURL *)cnrs_resourceRouteFileURLForRoute:(CNRSRoute *)route
{
    NSString *resourceFilePath = [self cnrs_resourceRouteFilePathForRoute:route];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourceFilePath])
    {
        return [NSURL fileURLWithPath:resourceFilePath];;
    }
    return nil;
}

- (NSString *)cnrs_resourceRouteFilePathForRoute:(CNRSRoute *)route
{
    CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
    for (CNRSRoute *resourceRoute in routeManager.resourceRoutes)
    {
        @autoreleasepool
        {
            if ([resourceRoute.fileHash isEqualToString:route.fileHash])
            {
                return [self resourceFilePathForUri:resourceRoute.uri];
            }
        }
    }
    
    return nil;
}

- (void)cnrs_deleteOldFilesWithNewRoutes:(NSArray *)newRoutes oldRoutes:(NSArray *)oldRoutes
{
    //找到需要删除的和更新的文件
    NSMutableArray *changedRoutes = [[NSMutableArray alloc] init];
    NSMutableArray *deletedRoutes = [[NSMutableArray alloc] init];
    for (CNRSRoute *oldRoute in oldRoutes)
    {
        @autoreleasepool
        {
            BOOL isDeleted = YES;
            for (CNRSRoute *newRoute in newRoutes)
            {
                if ([oldRoute.uri.absoluteString isEqualToString:newRoute.uri.absoluteString])
                {
                    isDeleted = NO;
                    if (![newRoute.fileHash isEqualToString:oldRoute.fileHash])
                    {
                        [changedRoutes addObject:oldRoute];
                    }
                }
            }
            if (isDeleted)
            {
                [deletedRoutes addObject:oldRoute];
            }
        }
    }
    
    [deletedRoutes addObjectsFromArray:changedRoutes];
    for (CNRSRoute *route in deletedRoutes)
    {
        @autoreleasepool
        {
            [self saveRouteFileData:nil withRoute:route];
        }
        
    }
}

@end
