//
//  CNRSWebViewController.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSWebViewController.h"
#import "CNRSProgressViewWidget.h"

@interface CNRSWebViewController ()

@property (nonatomic, strong) NSURL *requestURL;
@property (strong, nonatomic) CNRSProgressViewWidget *progressView;//进度条
@property (strong, nonatomic) UIBarButtonItem *backButton;//返回按钮
@property (strong, nonatomic) UIBarButtonItem *closeButton;//关闭按钮
@property (strong, nonatomic) UIBarButtonItem *refreshButton;//刷新按钮

@end


@implementation CNRSWebViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.htmlFileURL)
    {
        [self _initNav];
    }
    else{
        [self _initBackButton];
        self.navigationItem.leftBarButtonItems = @[_backButton];
    }
    
    [self _initWebView];
    
    if (self.htmlFileURL)
    {
        [self _initProgressView];
    }
    
    [self reloadWebView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 控制进度条在webview顶部
    CGRect frame = _progressView.frame;
    frame.origin.y = self.webView.frame.origin.y - 2;
    _progressView.frame = frame;
}

#pragma mark - Public methods

- (void)reloadWebView
{
    if (!self.requestURL) {
        _requestURL = [self htmlURL];
    }
    
    if (self.requestURL)
    {
        [_webView loadRequest:[NSURLRequest requestWithURL:self.requestURL]];
    }
}

- (void)onPageVisible
{
    // Call the WebView's visiblity change hook for javascript.
    //    CNRSDebugLog(@"window.Cenarius.Lifecycle.onPageVisible: %@",
    //                 [_webView stringByEvaluatingJavaScriptFromString:@"window.Cenarius.Lifecycle.onPageVisible()"]);
}

- (void)onPageInvisible
{
    // Call the WebView's visiblity change hook for javascript.
    //    CNRSDebugLog(@"window.Cenarius.Lifecycle.onPageInvisible: %@",
    //                 [_webView stringByEvaluatingJavaScriptFromString:@"window.Cenarius.Lifecycle.onPageInvisible()"]);
}

- (void)_initNav
{
    [self _initBackButton];
    [self _initCloseButton];
    [self _initRefreshButton];
    
    self.navigationItem.leftBarButtonItems = @[_backButton];
    self.navigationItem.rightBarButtonItem = _refreshButton;
}

- (void)_initBackButton
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [backButton setImage:[CNRSConfig backButtonImage] forState:UIControlStateNormal];
    [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [backButton setImageEdgeInsets:[CNRSConfig backButtonImageEdgeInsets]];
    [backButton addTarget:self action:@selector(_backClick:) forControlEvents:UIControlEventTouchUpInside];
    _backButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)_initCloseButton
{
    _closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(_closeClick:)];
    [_closeButton setTintColor:[UIColor whiteColor]];
}

- (void)_initRefreshButton
{
    _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebView)];
    [_refreshButton setTintColor:[UIColor whiteColor]];
}

- (void)_showCloseButton
{
    self.navigationItem.leftBarButtonItems = @[_backButton,_closeButton];
}

- (void)_initWebView
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _webView.dataDetectorTypes = UIDataDetectorTypeLink;
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
}

- (void)_initProgressView
{
    _progressView = [[CNRSProgressViewWidget alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
    [self.view addSubview:_progressView];
}

/**
 *  返回上一页
 *  如果没有可返回的网页则关闭当前窗口
 *
 *  @param sender 触发控件
 */
- (void)_backClick:(id)sender
{
    if ([_webView canGoBack])
    {
        [_webView goBack];
        if (self.htmlFileURL)
        {
            [self _showCloseButton];
        }
    }
    else
    {
        [self _closeClick:nil];
    }
}

/**
 *  关闭当前VC
 *
 *  @param sender 触发控件
 */
- (void)_closeClick:(id)sender
{
    if(self.navigationController.viewControllers.count > 1)
    {//判断是否还有上一级 viewController
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIWebViewDelegate's method

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *reqURL = request.URL;
    
    if ([reqURL isEqual:self.requestURL]) {
        return YES;
    }
    
    NSString *scheme = [CNRSConfig cnrsProtocolScheme];
    NSString *host = [CNRSConfig cnrsProtocolHost];
    
    if ([request.URL.scheme isEqualToString:scheme]
        && [request.URL.host isEqualToString:host] ) {
        
        NSURL *URL = request.URL;
        
        for (id<CNRSWidget> widget in self.widgets) {
            if ([widget canPerformWithURL:URL]) {
                [widget prepareWithURL:URL];
                [widget performWithController:self];
                CNRSDebugLog(@"Cenarius callback handle: %@", URL);
                return NO;
            }
        }
        
        CNRSDebugLog(@"Cenarius callback can not handle: %@", URL);
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_progressView startLoad];
    [self cnrs_resetControllerAppearance];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_progressView finishLoad];
    [self cnrs_resetControllerAppearance];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_progressView finishLoad];
    [self cnrs_resetControllerAppearance];
}

#pragma mark - Private Methods

- (void)cnrs_resetControllerAppearance
{
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    //    NSString *bgColor = [self.webView stringByEvaluatingJavaScriptFromString:
    //                         @"window.getComputedStyle(document.getElementsByTagName('body')[0]).backgroundColor"];
    //    self.webView.backgroundColor = [UIColor cnrs_colorWithComponent:bgColor] ?: [UIColor whiteColor];
}

//- (BOOL)cnrs_openWebPage:(NSURL *)url
//{
//    // 让 App 打开网页，通常 `UIApplicationDelegate` 都会实现 open url 相关的 delegate 方法。
//    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate respondsToSelector:@selector(application:openURL:options:)]) {
//        [delegate application:[UIApplication sharedApplication]
//                      openURL:url
//                      options:@{}];
//    } else if ([delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
//        [delegate application:[UIApplication sharedApplication]
//                      openURL:url
//            sourceApplication:nil
//                   annotation:@""];
//    } else if ([delegate respondsToSelector:@selector(application:handleOpenURL:)]) {
//        [delegate application:[UIApplication sharedApplication] handleOpenURL:url];
//    }
//
//    return YES;
//}

@end
