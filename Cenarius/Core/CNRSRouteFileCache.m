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
    // 默认缓存路径：<Library>/<bundle identifier>.cenarius
    cachePath = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".cenarius"];
  }

  if (![cachePath isAbsolutePath]) {
    cachePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)
                  firstObject] stringByAppendingPathComponent:cachePath];
  }

  _cachePath = [cachePath copy];

  NSError *error;
  [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath
                            withIntermediateDirectories:YES
                                             attributes:@{}
                                                  error:&error];
  if (error) {
    CNRSDebugLog(@"Failed to create directory: %@", _cachePath);
  }
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

- (void)saveRoutesMapFile:(NSData *)data
{
  NSString *filePath = [self.cachePath stringByAppendingPathComponent:RoutesMapFile];
  if (data == nil) {
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
  } else {
    [data writeToFile:filePath atomically:YES];
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
        [data writeToFile:filePath atomically:YES];
    }
}

- (NSData *)routeFileDataForRemoteURL:(NSURL *)url
{
    NSString *filePath = [self routeFilePathForRemoteURL:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [NSData dataWithContentsOfFile:filePath];
    }
    
    return nil;
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
    for (NSDictionary *item in JSON) {
        [items addObject:[[CNRSRoute alloc] initWithDictionary:item]];
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
    NSString *cacheFileName = [self.cachePath stringByAppendingPathComponent:route.fileHash];
    NSString *cacheFilePath = [cacheFileName stringByAppendingPathExtension:route.uri.pathExtension];
    return cacheFilePath;
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
    NSArray *resourceRoutes = [self routesWithData:[self resourceRoutesMapFile]];
    for (CNRSRoute *resourceRoute in resourceRoutes)
    {
        if ([resourceRoute.fileHash isEqualToString:route.fileHash])
        {
            NSString *resourceFileName = resourceRoute.uri.absoluteString;
            NSString *resourceFilePath = [self.resourcePath stringByAppendingPathComponent:resourceFileName];
            return resourceFilePath;
        }
    }
    return nil;
}

//准备删除
- (NSString *)routeFilePathForRemoteURL:(NSURL *)url
{
    NSString *filePath = [self cnrs_cachedRouteFilePathForRemoteURL:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }
    
    filePath = [self cnrs_resourceRouteFilePathForRemoteURL:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }
    
    return nil;
}

- (NSString *)cnrs_cachedRouteFilePathForRemoteURL:(NSURL *)url
{
    NSString *md5 = [[url.absoluteString dataUsingEncoding:NSUTF8StringEncoding] md5];
    NSString *filename = [self.cachePath stringByAppendingPathComponent:md5];
    return [filename stringByAppendingPathExtension:url.pathExtension];
}

- (NSString *)cnrs_resourceRouteFilePathForRemoteURL:(NSURL *)url
{
    NSString *filename = nil;
    NSArray *pathComps = url.pathComponents;
    if (pathComps.count > 2) { // 取后两位作为文件路径
        filename = [[pathComps subarrayWithRange:NSMakeRange(pathComps.count - 2, 2)] componentsJoinedByString:@"/"];
    } else {
        filename = url.path;
    }
    return [self.resourcePath stringByAppendingPathComponent:filename];
}


@end
