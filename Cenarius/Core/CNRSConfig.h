//
//  CNRSConfig.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//路由表文件名
static NSString * const RoutesMapFile = @"routes.json";

/**
 * `CNRSConfig` 提供对 Cenarius 的全局配置接口。
 */
@interface CNRSConfig : NSObject

/**
 * 设置 cnrsProtocolScheme。
 *
 * @discussion Cenarius-Container 实现了一些供 Web 调用的功能。Web 调用这些功能的方式是发出一个特定的请求。
 * `cnrsProtocolHost` 是对这些特定请求的 scheme 的商定。如不设置，缺省为 cenarius。
 */
+ (void)setCNRSProtocolScheme:(NSString *)scheme;

/**
 * 读取 cnrsProtocolScheme。
 *
 * @discussion Cenarius-Container 实现了一些供 Web 调用的功能。Web 调用这些功能的方式是发出一个特定的请求。
 * `cnrsProtocolHost` 是对这些特定请求的 scheme 的商定。如不设置，缺省为 cenarius。
 */
+ (NSString *)cnrsProtocolScheme;

/**
 * 设置 cnrsProtocolHost。
 *
 * @discussion Cenarius-Container 实现了一些供 Web 调用的功能。Web 调用这些功能的方式是发出一个特定的请求。
 * `cnrsProtocolHost` 是对这些特定请求的 host 的商定。如不设置，缺省为 cenarius-container。
 */
+ (void)setCNRSProtocolHost:(NSString *)host;

/**
 * 读取 cnrsProtocolHost。
 * 
 * @discussion Cenarius-Container 实现了一些供 Web 调用的功能。Web 调用这些功能的方式是发出一个特定的请求。
 * `cnrsProtocolHost` 是对这些特定请求的 host 的商定。如不设置，缺省为 cenarius-container。
 */
+ (NSString *)cnrsProtocolHost;

///**
// * 设置 Routes Map URL。
// */
//+ (void)setRoutesMapURL:(NSURL *)routesMapURL;

/**
 * 读取 Routes Map URL。
 */
+ (nullable NSURL *)routesMapURL;

/**
 * 设置 Route Files 的 Cache URL。
 */
+ (void)setRoutesCachePath:(nullable NSString *)routesCachePath;

/**
 * 读取 Route Files 的 Cache URL。
 */
+ (nullable NSString *)routesCachePath;

/**
 * 设置 Route Files 的 Resource Path。
 */
+ (void)setRoutesResourcePath:(nullable NSString *)routesResourcePath;

/**
 * 读取 Route Files 的 Resource Path。
 */
+ (nullable NSString *)routesResourcePath;

/**
 * 设置 Cenarius 接收的外部 User-Agent。Cenarius 会将这个 UserAgent 加到其所发出的所有的请求的 Headers 中。
 */
+ (void)setExternalUserAgent:(NSString *)userAgent;

/**
 * 读取 Cenarius 接收的外部 User-Agent。
 */
+ (NSString *)externalUserAgent;

/**
 * 更新全局配置。
 */
+ (void)updateConfig;

/**
 * 全局设置 Cenarius Container 是否使用路由文件的本地 Cache。
 * 如果使用，优先读取本地缓存的 html 文件；如果不使用，则每次都读取服务器的 html 文件。
 */
+ (void)setCacheEnable:(BOOL)isCacheEnable;

/**
 * 读取 Cenarius Container 是否使用缓存的全局配置。该缺省是打开的。Cenarius Container 会使用缓存保存 html 文件。
 */
+ (BOOL)isCacheEnable;

/**
 * 设置远程资源地址。
 */
+ (void)setRemoteFolderUrl:(NSURL *)remoteFolderUrl;

/**
 * 等待route刷新的callback
 */
+ (nullable NSURL *)remoteFolderUrl;

/**
 设置返回按钮图标
 
 @param image      图标
 @param edgeInsets 偏移
 */
+ (void)setBackButtonImage:(UIImage *)image edgeInsets:(UIEdgeInsets)edgeInsets;

/**
 读取返回按钮图标
 */
+ (UIImage *)backButtonImage;

/**
 读取返回按钮图标偏移
 */
+ (UIEdgeInsets )backButtonImageEdgeInsets;

/**
 是否启用调试模式。开启后，会禁用路由表。Cenarius Container 会读取Docment目录。
 */
+ (void)setDevelopModeEnable:(BOOL)isDevelopModeEnable;

/**
 * 读取 Cenarius Container 是否启用调试模式。该缺省是关闭的。Cenarius Container 会读取Docment目录。
 */
+ (BOOL)isDevelopModeEnable;

/**
 设置输出 log
 */
+ (void)setLogEnable:(BOOL)isLogEnable;

/**
 是否输出 log
 */
+ (BOOL)isLogEnable;

@end

NS_ASSUME_NONNULL_END
