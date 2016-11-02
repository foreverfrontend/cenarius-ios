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
#import "CNRSConfig.h"

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
    if ([CNRSConfig isDevelopModeEnable])
    {
        NSString *docPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                              firstObject] stringByAppendingPathComponent:[CNRSConfig routesResourcePath]];
        docPath = [@"file://" stringByAppendingString:docPath];
        NSString *urlStr = [docPath stringByAppendingPathComponent:self.uri.absoluteString];
        NSURL *url = [NSURL URLWithString:urlStr];
        return url;
    }
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
  if (htmlFileURL == nil)
  {
      if (uri.query.length != 0 || uri.fragment.length != 0)
      {
          // 为了方便 escape 正确的 uri，做了下面的假设。之后放弃 iOS 7 后可以改用 `queryItem` 来实现。
          // 做个合理假设：html URL 中不应该有 query string 和 fragment。
          CNRSWarnLog(@"local html 's format is not right! Url has query and fragment.");
      }

      htmlFileURL = [[CNRSRouteManager sharedInstance] localHtmlURLForURI:uri];
      if (htmlFileURL == nil) {
          htmlFileURL = [[CNRSRouteManager sharedInstance] remoteHtmlURLForURI:uri];
      }
  }

    return htmlFileURL;
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
