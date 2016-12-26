//
//  CNRSLightAppController.h
//  Cenarius
//
//  Created by M on 2016/12/22.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSLightAppController` 是一个 Cenarius 轻应用 Container。
 * 它提供了一个使用 web 技术 html, css, javascript 开发 UI 界面的容器。
 */

@interface CNRSLightAppController : CNRSViewController<UIWebViewDelegate>

/**
 * 内置的 WebView。
 */
@property (nonatomic, strong, readonly) UIWebView *webView;

///**
// * 重新加载 WebView。
// */
//- (void)reloadWebView;

@end

NS_ASSUME_NONNULL_END
