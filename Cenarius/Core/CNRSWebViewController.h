//
//  CNRSWebViewController.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSWebViewController` 是一个 Cenarius Container。
 * 它提供了一个使用 web 技术 html, css, javascript 开发 UI 界面的容器。
 */
@interface CNRSWebViewController : CNRSViewController <UIWebViewDelegate>

/**
 * 内置的 WebView。
 */
@property (nonatomic, strong, readonly) UIWebView *webView;

/**
 * 重新加载 WebView。
 */
- (void)reloadWebView;

@end

NS_ASSUME_NONNULL_END
