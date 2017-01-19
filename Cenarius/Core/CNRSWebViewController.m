//
//  CNRSWebViewController.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSWebViewController.h"
#import "CNRSProgressViewWidget.h"

#pragma mark - CNRSBackButton

@interface CNRSBackButton : UIButton
@end
@implementation CNRSBackButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = 9;
    CGFloat imageH = 16;
    CGFloat imageX = -10;
    CGFloat imageY = (contentRect.size.height - imageH) * 0.5;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    
    CGFloat titleW = contentRect.size.width - 10 - 9 - 5;
    CGFloat titleH = contentRect.size.height ;
    CGFloat titleX = -10 + 9 +5;
    CGFloat titleY = 0;
    
    return CGRectMake(titleX, titleY, titleW, titleH);
    
}

@end

#pragma mark - CNRSWebViewController

@interface CNRSWebViewController ()

@property (nonatomic, strong) NSURL *requestURL;
@property (strong, nonatomic) UINavigationItem *navItem;//导航栏
@property (strong, nonatomic) UINavigationBar *navBar;//导航栏
@property (strong, nonatomic) CNRSProgressViewWidget *progressView;//进度条
@property (strong, nonatomic) UIBarButtonItem *backButton;//返回按钮
@property (strong, nonatomic) UIBarButtonItem *closeButton;//关闭按钮
@property (strong, nonatomic) UIBarButtonItem *refreshButton;//刷新按钮

@end


@implementation CNRSWebViewController

#pragma mark - Super methods
- (void)setTitle:(NSString *)title{
    if(self.navItem)self.navItem.title = title;
    [super setTitle:title];
}

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
    
//    self.navBar              = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
//    self.navBar.barTintColor = [UIColor whiteColor];
//    self.navBar.translucent  = NO;
//    self.navBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self _createCustomNavigationBar];
    [self.view addSubview:self.navBar];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.navBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.navBar addConstraint:[NSLayoutConstraint constraintWithItem:self.navBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:65]];
    
    self.navItem = [[UINavigationItem alloc] init];
    self.navItem.leftBarButtonItems = @[_backButton];
    self.navItem.rightBarButtonItem = _refreshButton;
    self.navItem.title = self.title;
    [self.navBar pushNavigationItem:self.navItem animated:YES];
}

- (UIView *)_createCustomNavigationBar{
    
    if (!self.navBar) {
        UINavigationBar *barView = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
        barView.barTintColor     = [UIColor whiteColor];
        barView.shadowImage      = [UIImage new];
        barView.translucent      = YES;
        
        
        [self setNavBar:barView];
        [self.view addSubview:self.navBar];
        [barView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    // 分割线
    UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(0, 65-1, self.navBar.frame.size.width, 1.0)];
    line.backgroundColor = [UIColor lightGrayColor];
    
    [self.navBar addSubview:line];
    [line setTranslatesAutoresizingMaskIntoConstraints:NO];
//     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.navBar attribute:NSLayoutAttributeBottom multiplier:1 constant:1.0 / [UIScreen mainScreen].scale]];
    return self.navBar;
}

- (void)_initBackButton
{
    CNRSBackButton *back      = [[CNRSBackButton alloc] init];
    back.frame            = (CGRect){CGPointZero, 70, 35};
    back.titleLabel.font  =[UIFont systemFontOfSize:16];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back setImage:[CNRSConfig backButtonImage] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(_backClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _backButton     = [[UIBarButtonItem alloc] initWithCustomView:back];
}

- (void)_initCloseButton
{
    _closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(_closeClick:)];
    [_closeButton setTintColor:[UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1.0f]];
    _closeButton.imageInsets = UIEdgeInsetsMake(3, 0, 3, 0);
}

- (void)_initRefreshButton
{
    _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebView)];
    [_refreshButton setTintColor:[UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1.0f]];
    _refreshButton.imageInsets = UIEdgeInsetsMake(3, 0, 3, 0);
}

- (void)_showCloseButton
{
    if(self.navItem)self.navItem.leftBarButtonItems = @[_backButton,_closeButton];
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
    
    if (self.navBar) {
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.navBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    }
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
- (void)webViewDidReceiveTitle:(NSString *)title{
    self.navItem = title;
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

@interface UIWebView (title)

@end

@implementation UIWebView (title)

//收到标题，把标题展示到窗口上面
- (void)webView:(id)sender didReceiveTitle:(NSString *)title forFrame:(void *)frame
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidReceiveTitle:)]) {
        [self.delegate performSelector:@selector(webViewDidReceiveTitle:) withObject:title];
    }
}

@end
