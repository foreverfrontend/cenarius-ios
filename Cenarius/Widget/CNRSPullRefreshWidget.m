//
//  CNRSPullRefreshWidget.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSPullRefreshWidget.h"
#import "CNRSWebViewController.h"
#import "CDVViewController.h"

@interface CNRSPullRefreshWidget ()

@property (nonatomic, strong) NSDictionary *cnrsDictionary;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, assign) BOOL onRefreshStart;

@end


@implementation CNRSPullRefreshWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
  NSString *path = URL.path;
  if (path && [path isEqualToString:@"/widget/pull_to_refresh"]) {
    return YES;
  }
  return NO;
}

- (void)prepareWithURL:(NSURL *)URL
{
    _cnrsDictionary = [URL cnrs_jsonDictionary];
    _action = _cnrsDictionary[@"action"];
}

- (void)performWithController:(CNRSViewController *)controller
{
  if ([self.action isEqualToString:@"enable"] && !self.refreshControl.isRefreshing) {
    // Web 通知该页面有下拉组件
    if (!self.refreshControl) {
        if ([controller isKindOfClass:[CNRSWebViewController class]])
        {
            self.refreshControl = [self cnrs_refreshControllerWithScrollView:((CNRSWebViewController *)controller).webView];
        }
        else if ([controller isKindOfClass:[CDVViewController class]])
        {
            self.refreshControl = [self cnrs_refreshControllerWithScrollView:(UIWebView *)((CDVViewController *)controller).webView];
        }
    }

  } else if ([self.action isEqualToString:@"complete"]) {
    // Web 通知下拉动作完成
    [self.refreshControl endRefreshing];
    self.onRefreshStart = NO;
  }
}

#pragma mark - Private

- (UIRefreshControl *)cnrs_refreshControllerWithScrollView:(UIWebView *)webView
{
  UIScrollView *scrollView = webView.scrollView;
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  [scrollView addSubview:refreshControl];
  [refreshControl addTarget:self action:@selector(cnrs_refresh:) forControlEvents:UIControlEventValueChanged];
  return refreshControl;
}

- (void)cnrs_refresh:(UIRefreshControl *)refreshControl
{
  UIView *view = [[refreshControl superview] superview];
  if ([view isKindOfClass:[UIWebView class]] && !self.onRefreshStart) {
    self.onRefreshStart = YES;
    UIWebView *webView = (UIWebView *)view;
    [webView stringByEvaluatingJavaScriptFromString:@"window.Cenarius.Widget.PullToRefresh.onRefreshStart()"];
  }
}

@end
