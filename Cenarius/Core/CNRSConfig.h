//
//  CNRSConfig.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSConfig` 下载进度通知，Object为float
 */
extern NSString* const CNRSDownloadProgressNotification;

/**
 * `CNRSConfig` webView设置title通知，Object为UIWebView对象，UserInfo[@"title"] 为标题
 */
extern NSString* const CNRSWebViewDidReceiveTitle;

//路由表文件名
static NSString * const RoutesMapFile = @"cenarius-routes.json";
static NSString * const CenariusConfig = @"cenarius-config.json";

/**
 * `CNRSConfig` 提供对 Cenarius 的全局配置接口。
 */
@interface CNRSConfig : NSObject

/**
 * 获取版本更新信息URL
 */
+ (NSURL *)getConfigUrl;

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
 设置路由表白名单
 */
+ (void)setRoutesWhiteList:(NSArray *)whiteList;

/**
 读取路由表白名单
 */
+ (NSArray *)routesWhiteList;

/**
 设置路由表白名单
 */
+ (void)setDownloadFirstList:(NSArray *)downloadFirstList;

/**
 读取优先下载名单，下载完成才能进 app
 */
+ (NSArray *)downloadFirstList;

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
 设置登录的 appKey appSecret
 */
+ (void)setLoginWithService:(NSString *)service appKey:(NSString *)appKey appSecret:(NSString *)appSecret;

/**
 获取登录 appKey
 */
+ (NSString *)loginAppKey;

/**
 获取登录 appSecret
 */
+(NSString *)loginAppSecret;

/**
 获取登录 service
 */
+(NSString *)loginService;

/**
 设置下载的并行数，当值为1的时候，为串行。
 */
+ (void)setMaxConcurrentOperationCount:(NSInteger)OperationCount;
@end

NS_ASSUME_NONNULL_END
