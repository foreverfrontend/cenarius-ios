//
//  CNRSWebViewController.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSWebViewController.h"

@interface CNRSWebViewController ()

@property (nonatomic, strong) NSURL *requestURL;
@property (strong, nonatomic) UIProgressView *progressView;//进度条
@property (strong, nonatomic) UIBarButtonItem *backButton;//返回按钮
@property (strong, nonatomic) UIBarButtonItem *closeButton;//关闭按钮
@property (strong, nonatomic) UIBarButtonItem *refreshButton;//刷新按钮
@property (nonatomic) BOOL isWebViewFinishLoad;
@property (strong, nonatomic) NSTimer *progressTimer;

@end


@implementation CNRSWebViewController

#pragma mark - LifeCycle

//- (instancetype)initWithHtmlFileURL:(NSURL *)htmlFileURL
//{
//    self = [super initWithNibName:nil bundle:nil];
//    if (self) {
//        _htmlFileURL = htmlFileURL;
//        _requestURL = htmlFileURL;
//        
//    }
//    return self;
//}

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
    
//    [NSURLProtocol registerClass:CNRSCacheFileInterceptor.class];
}



//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self onPageVisible];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    [self onPageInvisible];
//}

//- (void)dealloc
//{
//    [NSURLProtocol unregisterClass:CNRSCacheFileInterceptor.class];
//}

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
    
//    //暂时禁用缓存
//    if (_htmlFileURL) {
//        [_webView loadRequest:[NSURLRequest requestWithURL:self.htmlFileURL]];
//    }
//    else{
//        [_webView loadRequest:[NSURLRequest requestWithURL:self.uri]];
//    }
}

- (void)onPageVisible
{
    // Call the WebView's visiblity change hook for javascript.
    CNRSDebugLog(@"window.Cenarius.Lifecycle.onPageVisible: %@",
                 [_webView stringByEvaluatingJavaScriptFromString:@"window.Cenarius.Lifecycle.onPageVisible()"]);
}

- (void)onPageInvisible
{
    // Call the WebView's visiblity change hook for javascript.
    CNRSDebugLog(@"window.Cenarius.Lifecycle.onPageInvisible: %@",
                 [_webView stringByEvaluatingJavaScriptFromString:@"window.Cenarius.Lifecycle.onPageInvisible()"]);
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
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
    _progressView.trackTintColor = [UIColor clearColor];
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

///**
// *  刷新当前页面
// *
// *  @param sender 触发控件
// */
//- (void)_refresh:(id)sender
//{
//    [self.webView reload];
//}

-(void)timerCallback
{
    if (_isWebViewFinishLoad)
    {
        if (_progressView.progress >= 1)
        {
            _progressView.hidden = YES;
            [_progressTimer invalidate];
        }
        else
        {
            _progressView.progress += 0.1;
        }
    }
    else
    {
        _progressView.progress += 0.05;
        if (_progressView.progress >= 0.95)
        {
            _progressView.progress = 0.95;
        }
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
    
//    // http:// or https:// 开头，则打开网页
//    if ([reqURL cnrs_isHttpOrHttps]) {
//        return ![self cnrs_openWebPage:reqURL];
//    }
    
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
    _isWebViewFinishLoad = NO;
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    [self cnrs_resetControllerAppearance];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _isWebViewFinishLoad = YES;
    [self cnrs_resetControllerAppearance];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _isWebViewFinishLoad = YES;
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
