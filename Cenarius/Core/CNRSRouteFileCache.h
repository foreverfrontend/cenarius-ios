//
//  CNRSRouteFileCache.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSRoute.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSRouteCache` 提供对 Route files 的读取。
 * Route files 包括用于渲染 cenarius 页面的静态文件，例如 html, css, js, image。
 * 为何我们会自己实现一个缓存，而不使用 NSURLCache?
 * 因为获取 Route 信息有两个来源，要么从本地缓存（上线后发布，下载的资源会有本地缓存），要么资源文件夹（上线时打入的）。这和 NSURLCache 缓存机制不同。
 * 1. 本地缓存；
 * 2. 资源：应用打包的资源文件中有一份, 这部分资源不会改变。
 *
 * `CNRSRouteCache` offer the access method of Route files.
 * Route files include cenarius page 's static file like html, css, js, image.
 * Why we write this cache instead of using NSURLCache?
 * It's because that there are two sources of Route files，local cache (create and save the downloaded resources in cache after app release) or resource file (in the release ipa):
 * 1. local cache: disk cache；
 * 2. resource file: a copy in ipa's resource bundle, this resource will not change.
 */
@interface CNRSRouteFileCache : NSObject

/**
 * cachePath, 如果是相对路径的话，则认为其是相对于应用缓存路径。
 */
@property (nonatomic, copy) NSString *cachePath;

/**
 * Cenarius 资源地址, 会在打包应用时，打包进入 ipa。如果是相对路径的话，则认为其是相对于 main bundle 路径。
 */
@property (nonatomic, copy) NSString *resourcePath;

/**
 * 单例方法，获取一个 CNRSRouteFileCache 实例。
 *
 * Get CNRSRouteFileCache Singleton instance.
 */
+ (CNRSRouteFileCache *)sharedInstance;

/**
 * 存储 Route Map File，文件名为 `routes.json`。
 *
 * Save routes map file with file name : `routes.json`.
 */
- (void)saveRoutesMapFile:(NSData *)routesData;

/**
 * 读取 Route Map File。
 *
 * Read routes map file.
 */
- (nullable NSData *)routesMapFile;

/**
 * 读取 cache Route Map File。
 *
 * Read cache routes map file.
 */
- (NSData *)cacheRoutesMapFile;

/**
 * 读取 resource Route Map File。
 *
 * Read resource routes map file.
 */
- (NSData *)resourceRoutesMapFile;


/**
 * 将 `url` 下载下来的资源数据，存入缓存。
 *
 * Save the route file with url.
 */
- (void)saveRouteFileData:(nullable NSData *)data withRoute:(CNRSRoute *)route;

/**
 * 获取 route 对于的本地 url。先在缓存文件夹中寻找，再在资源文件夹中寻找。如果在缓存文件和资源文件中都找不到对应的本地文件，返回 nil。
 *
 * Get the local url for route. Search the local file first from cache file, then from resource file.
 * If it dose not exist in cache file and resource file, return nil.
 */
- (nullable NSURL *)routeFileURLForRoute:(CNRSRoute *)route;

/**
 * 清理缓存。
 *
 * Clean Cache。
 */
- (void)cleanCache;

/**
 读取 routes

 @param data routes data

 @return routes
 */
- (nullable NSMutableArray *)routesWithData:(NSData *)data;

/**
 获取 uri 对应的缓存文件夹地址
 */
- (NSString *)cacheFilePathForUri:(NSURL *)uri;

/**
 获取 uri 对应的资源文件夹地址
 */
- (NSString *)resourceFilePathForUri:(NSURL *)uri;

@end

NS_ASSUME_NONNULL_END
