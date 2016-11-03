//
//  CNRSViewController.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNRSCacheFileInterceptor.h"
#import "CNRSRouteManager.h"
#import "CNRSLogging.h"
#import "CNRSConfig.h"
#import "CNRSWidget.h"

@protocol CNRSWidget;

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSViewController` 是一个 Cenarius Container。
 * 它提供了一个使用 web 技术 html, css, javascript 开发 UI 界面的容器。
 * 其他ViewController都应该继承它
 */
@interface CNRSViewController : UIViewController

/**
 * 对应的 uri。
 */
@property (nonatomic, strong, readonly) NSURL *uri;

/**
 对应的 url。
 */
@property (nonatomic, strong) NSURL *htmlFileURL;

///**
// * 内置的 WebView。
// */
//@property (nonatomic, strong, readonly) UIWebView *webView;

/**
 * activities 代表该 Cenarius Container 可以响应的协议。
 */
@property (nonatomic, strong) NSArray<id<CNRSWidget>> *widgets;

/**
 * 初始化一个CNRSViewController。
 *
 * @param uri 该页面对应的 uri。
 *
 * @discussion 会根据 uri 从 Route Map File 中选择对应本地 html 文件加载。如果无本地 html 文件，则从服务器加载 html 资源。
 * 在 UIWebView 中，远程 URL 需要注意跨域问题。
 */
- (instancetype)initWithURI:(NSURL *)uri;

/**
 * 初始化一个CNRSViewController。
 *
 * @param htmlFileURL 该页面对应的 html file url。
 *
 * @discussion 会根据 uri 从 Route Map File 中选择对应本地 html 文件加载。如果无本地 html 文件，则从服务器加载 html 资源。
 * 在 UIWebView 中，远程 URL 需要注意跨域问题。
 */
- (instancetype)initWithHtmlFileURL:(NSURL *)htmlFileURL;

///**
// * 重新加载 WebView。 
// */
//- (void)reloadWebView;

/**
 * 通知 WebView 页面显示，缺省会在 viewWillAppear 里调用。本方法可以由业务层自主定制向 WebView 通知 onPageVisible 的时机。
 */
- (void)onPageVisible;

/**
 * 通知 WebView 页面消失，缺省会在 viewDidDisappear 里调用。本方法可以由业务层自主定制向 WebView 通知 onPageInvisible 的时机。
 */
- (void)onPageInvisible;

/**
 获取html的URL地址，可能是本地或服务器

 @return htmlURL
 */
- (NSURL *)htmlURL;


#pragma mark - Public Nav Methods

/**
 传参
 */
@property (nullable, strong, nonatomic) NSDictionary *cnrsDictionary;

/**
 打开本地web应用
 
 @param uri 相对路径
 @param parameters 参数
 */
- (void)openWebPage:(nonnull NSString *)uri parameters:(nullable NSDictionary *)parameters;

/**
 打开轻应用
 
 @param url 网址
 @param parameters 参数
 */
- (void)openLightApp:(nonnull NSString *)url parameters:(nullable NSDictionary *)parameters;


/**
 打开原生页面
 
 @param className  类名
 @param parameters 参数
 */
- (void)openNativePage:(nonnull NSString *)className parameters:(nullable NSDictionary *)parameters;

/**
 打开Cordova页面

 @param uri        相对路径
 @param parameters 参数
 */
- (void)openCordovaPage:(nonnull NSString *)uri parameters:(nullable NSDictionary *)parameters;

@end


#pragma mark - Public Route Methods

/**
 * 暴露出 Route 相关的接口。
 */
@interface CNRSViewController (Router)

/**
 * 更新 Route Files。
 *
 * @param completion 更新完成后将执行这个 block。
 */
+ (void)updateRouteFilesWithCompletion:(nullable void (^)(BOOL success))completion;

/**
 * 判断存在对应于 uri 的 route 信息
 *
 * @param uri 待判断的 uri
 */
+ (BOOL)isRouteExistForURI:(NSURL *)uri;

/**
 * 判断存在对应于 uri 的 route 信息
 *
 * @param uri 待判断的 uri
 */
+ (BOOL)isLocalRouteFileExistForURI:(NSURL *)uri;

@end

/**
 * 暴露出 Login 相关的接口。
 */
@interface CNRSViewController (Login)

/**
 登录

 @param service    服务器地址
 @param username   用户名
 @param password   密码
 @param completion 更新登录后将执行这个 block
 */
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(nullable void (^)(BOOL success))completion;


NS_ASSUME_NONNULL_END

@end


