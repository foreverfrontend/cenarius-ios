//
//  CNRSRouteManager.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import UIKit;

@class CNRSRoute;

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSRouteManager` 提供了对路由信息的管理和使用接口。
 */
@interface CNRSRouteManager : NSObject

/**
 * uri 和 html 对应关系的路由表。
 *
 * 路由表读取路径优先级：
 * - 缓存路由表。
 * - 配置中地址的根目录下的路由表。
 *
 * 路由表更新策略：
 * - 对象创建后。
 * - 当通过 `htmlForURI:` 没有找到目标 html 时。
 */
@property (nonatomic, strong) NSMutableArray<CNRSRoute *> *routes;
@property (nonatomic, strong) NSMutableArray<CNRSRoute *> *cacheRoutes;
@property (nonatomic, strong) NSMutableArray<CNRSRoute *> *resourceRoutes;

/**
 * 读取 Routes Map 信息的 URL 地址。路由表应该由服务器提供。
 */
@property (nonatomic, strong) NSURL *routesMapURL;

/**
 *  设置当前下载的并行数，当值为1时，为串行下载。
 */
@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;

/**
 * 单例方法，获取一个 CNRSRouteManager 实例。
 */
+ (CNRSRouteManager *)sharedInstance;

/**
 * 删除旧的URLSession，并创建新的URLSession
 */
- (void)updateURLSession;

/**
 * 设置缓存地址。如果是相对路径的话，则认为其是相对于应用缓存路径
 */
- (void)setCachePath:(NSString *)cachePath;

/**
 * 设置 cenarius 资源地址。如果是相对路径的话，则认为其是相对于 main bundle 路径。
 */
- (void)setResoucePath:(NSString *)resourcePath;

/**
 * 查找 uri 对应的本地 html 文件 URL。先查 Cache，再查 Resource
 */
- (nullable NSURL *)localHtmlURLForURI:(NSURL *)uri;

- (nullable NSURL *)localHtmlURLForRoute:(CNRSRoute *)route uri:(NSURL *)uri;

/**
 * 查找 uri 对应的服务器上 html 文件。
 */
- (nullable NSURL *)remoteHtmlURLForURI:(NSURL *)uri;

- (nullable NSURL *)remoteHtmlURLForRoute:(CNRSRoute *)route uri:(NSURL *)uri;

/**
 * 立即同步路由表。
 *
 * @param completion 同步完成后的回调
 */
- (void)updateRoutesWithCompletion:(void (^)(BOOL success))completion;

/**
 * 立即同步路由表。
 *
 * @param completion 同步完成后的回调
 */
+ (void)updateRouteFilesWithCompletion:(void (^)(BOOL success))completion;

/**
 查找 远程 url 对应的 route。
 
 @param remoteURL 远程 url
 
 @return route
 */
- (nullable CNRSRoute *)routeForRemoteURL:(NSURL *)remoteURL;

/**
 获取 url 中的 uri，可能没有
 
 @param url url
 
 @return uri
 */
- (nullable NSURL *)uriForUrl:(NSURL *)url;

/**
 获取 uri 对应的 route，可能没有
 
 @param uri uri
 
 @return route
 */
- (nullable CNRSRoute *)routeForURI:(NSURL *)uri;

/**
 uri 是否在路由表中
 */
- (BOOL)isInRoutes:(NSURL *)uri;

/**
 uri 是否在白名单中
 */
- (BOOL)isInWhiteList:(NSURL *)uri;

/**
 是否正在更新路由表（路由表还没保存）
 */
- (BOOL)isUpdatingRoutes;

@end

NS_ASSUME_NONNULL_END

