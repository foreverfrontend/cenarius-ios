//
//  CNRSViewController.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CNRSViewController.h"
#import "CNRSWebViewController.h"
#import "CDVViewController.h"

#import "UIColor+Cenarius.h"
#import "NSURL+Cenarius.h"

#import "CNRSPullRefreshWidget.h"
#import "CNRSNavTitleWidget.h"
#import "CNRSAlertDialogWidget.h"
//#import "CNRSToastWidget.h"
#import "CNRSNavMenuWidget.h"
#import "CNRSCordovaWidget.h"
#import "CNRSNativeWidget.h"
#import "CNRSWebWidget.h"

@interface CNRSViewController ()

@end


@implementation CNRSViewController

#pragma mark - LifeCycle

- (instancetype)initWithHtmlFileURL:(NSURL *)htmlFileURL
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _htmlFileURL = htmlFileURL;
  }
  return self;
}

- (instancetype)initWithURI:(NSURL *)uri
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    _uri = uri;
  }
  return self;
}

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//  NSAssert(NO, @"Should use initWithURI: instead.");
//  return nil;
//}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [NSURLProtocol registerClass:CNRSCacheFileInterceptor.class];
    
    // Widgets
    CNRSPullRefreshWidget *pullRefreshWidget = [[CNRSPullRefreshWidget alloc] init];
    CNRSNavTitleWidget *titleWidget = [[CNRSNavTitleWidget alloc] init];
    CNRSAlertDialogWidget *alertDialogWidget = [[CNRSAlertDialogWidget alloc] init];
//    CNRSToastWidget *toastWidget = [[CNRSToastWidget alloc] init];
    CNRSNavMenuWidget *navMenuWidget = [[CNRSNavMenuWidget alloc] init];
    
    
    CNRSCordovaWidget *cordovaWidget = [[CNRSCordovaWidget alloc] init];
    CNRSNativeWidget *nativeWidget = [[CNRSNativeWidget alloc] init];
    CNRSWebWidget *webWidget = [[CNRSWebWidget alloc] init];
    self.widgets = @[titleWidget, alertDialogWidget, pullRefreshWidget, cordovaWidget, nativeWidget, webWidget, navMenuWidget];
    
//    // ContainerAPIs
//    let geoContainerAPI = RXRGeoContainerAPI()
//    let logContainerAPI = RXRLogContainerAPI()
//    RXRContainerInterceptor.setContainerAPIs([geoContainerAPI, logContainerAPI])
//    URLProtocol.registerClass(RXRContainerInterceptor.self)
    
//    // Decorators
//    let headers = ["Customer-Authorization": "Bearer token"]
//    let parameters = ["apikey": "apikey value"]
//    let requestDecorator = RXRRequestDecorator(headers: headers, parameters: parameters)
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self onPageVisible];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [self onPageInvisible];
}

- (void)dealloc
{
  [NSURLProtocol unregisterClass:CNRSCacheFileInterceptor.class];
}

#pragma mark - Public methods

- (void)onPageVisible
{
//  // Call the WebView's visiblity change hook for javascript.
//  CNRSDebugLog(@"window.Cenarius.Lifecycle.onPageVisible: %@",
//              [_webView stringByEvaluatingJavaScriptFromString:@"window.Cenarius.Lifecycle.onPageVisible()"]);
}

- (void)onPageInvisible
{
//  // Call the WebView's visiblity change hook for javascript.
//  CNRSDebugLog(@"window.Cenarius.Lifecycle.onPageInvisible: %@",
//              [_webView stringByEvaluatingJavaScriptFromString:@"window.Cenarius.Lifecycle.onPageInvisible()"]);
}

- (NSURL *)htmlURL
{
    return [self cnrs_htmlURLWithUri:self.uri htmlFileURL:self.htmlFileURL];
}

- (void)openWebPage:(NSString *)uri parameters:(NSDictionary *)parameters
{
    CNRSWebViewController *controller = [[CNRSWebViewController alloc] initWithURI:[NSURL URLWithString:uri]];
    if (parameters)
    {
        controller.cnrsDictionary = parameters;
    }
    [self.navigationController pushViewController:controller animated:YES];
    [self cnrs_enablePopGesture];
}

- (void)openLightApp:(NSString *)url parameters:(NSDictionary *)parameters
{
    CNRSWebViewController *controller = [[CNRSWebViewController alloc] initWithHtmlFileURL:[NSURL URLWithString:url]];
    if (parameters)
    {
        controller.cnrsDictionary = parameters;
    }
    [self.navigationController pushViewController:controller animated:YES];
    [self cnrs_enablePopGesture];
}

- (void)openNativePage:(NSString *)className parameters:(NSDictionary *)parameters
{
    className = [className stringByAppendingString:@"Controller"];
    CNRSViewController *controller = [[NSClassFromString(className) alloc] init];
    if (parameters)
    {
        controller.cnrsDictionary = parameters;
    }
    [self.navigationController pushViewController:controller animated:YES];
    [self cnrs_enablePopGesture];
}

- (void)openCordovaPage:(NSString *)uri parameters:(NSDictionary *)parameters
{
    CDVViewController *controller = [[CDVViewController alloc] initWithURI:[NSURL URLWithString:uri]];
    if (parameters)
    {
        controller.cnrsDictionary = parameters;
    }
    [self.navigationController pushViewController:controller animated:YES];
    [self cnrs_enablePopGesture];
}

#pragma mark - Private Methods

- (NSURL *)cnrs_htmlURLWithUri:(NSURL *)uri htmlFileURL:(NSURL *)htmlFileURL
{
  if (!htmlFileURL)
  {
      if (uri.query.length != 0 && uri.fragment.length != 0)
      {
          // 为了方便 escape 正确的 uri，做了下面的假设。之后放弃 iOS 7 后可以改用 `queryItem` 来实现。
          // 做个合理假设：html URL 中不应该有 query string 和 fragment。
          CNRSWarnLog(@"local html 's format is not right! Url has query and fragment.");
      }

      htmlFileURL = [[CNRSRouteManager sharedInstance] remoteHtmlURLForURI:uri];
//      // 没有设置 htmlFileURL，则使用本地 html 文件或者服务器读取 html 文件。
//      
//      htmlFileURL = [[CNRSRouteManager sharedInstance] remoteHtmlURLForURI:self.uri];
//      
//      if ([CNRSConfig isCacheEnable]) {
//          // 如果缓存启用，尝试读取本地文件。如果没有本地文件（本地文件包括缓存，和资源文件夹），则从服务器读取。
//          NSURL *localHtmlURL = [[CNRSRouteManager sharedInstance] localHtmlURLForURI:self.uri];
//          if (localHtmlURL) {
//              htmlFileURL = localHtmlURL;
//          }
//      }
//      else {
//          htmlFileURL = [[CNRSRouteManager sharedInstance] remoteHtmlURLForURI:self.uri];
//      }
  }

    return htmlFileURL;

//  if (htmlFileURL.query.length != 0 && htmlFileURL.fragment.length != 0) {
//    // 为了方便 escape 正确的 uri，做了下面的假设。之后放弃 iOS 7 后可以改用 `queryItem` 来实现。
//    // 做个合理假设：html URL 中不应该有 query string 和 fragment。
//    CNRSWarnLog(@"local html 's format is not right! Url has query and fragment.");
//  }
//
//  // `absoluteString` 返回的是已经 escape 过的文本，这里先转换为原始文本。
//  NSString *uriText = uri.absoluteString.stringByRemovingPercentEncoding;
//  // 把 uri 的原始文本所有内容全部 escape。
//  NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@""];
//  uriText = [uriText stringByAddingPercentEncodingWithAllowedCharacters:set];
//
//  return  [NSURL URLWithString:[NSString stringWithFormat:@"%@?uri=%@", htmlFileURL.absoluteString, uriText]];
}

//- (void)cnrs_resetControllerAppearance
//{
//  self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//
//  NSString *bgColor = [self.webView stringByEvaluatingJavaScriptFromString:
//                       @"window.getComputedStyle(document.getElementsByTagName('body')[0]).backgroundColor"];
//  self.webView.backgroundColor = [UIColor cnrs_colorWithComponent:bgColor] ?: [UIColor whiteColor];
//}
//
//- (BOOL)cnrs_openWebPage:(NSURL *)url
//{
//  // 让 App 打开网页，通常 `UIApplicationDelegate` 都会实现 open url 相关的 delegate 方法。
//  id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
//  if ([delegate respondsToSelector:@selector(application:openURL:options:)]) {
//    [delegate application:[UIApplication sharedApplication]
//                  openURL:url
//                  options:@{}];
//  } else if ([delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
//    [delegate application:[UIApplication sharedApplication]
//                  openURL:url
//        sourceApplication:nil
//               annotation:@""];
//  } else if ([delegate respondsToSelector:@selector(application:handleOpenURL:)]) {
//    [delegate application:[UIApplication sharedApplication] handleOpenURL:url];
//  }
//
//  return YES;
//}

- (void)cnrs_enablePopGesture
{
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

@end
