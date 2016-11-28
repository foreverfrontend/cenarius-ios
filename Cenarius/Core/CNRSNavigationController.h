//
//  CNRSNavigationController.h
//  Cenarius
//
//  Created by Frank Fan on 14-7-25.
//  Copyright (c) 2014年 gdcattsoft. All rights reserved.
//

@import UIKit;

@protocol CNRSViewControllerPanReturnBackDelegate <NSObject>

/**
 * 当前viewController实现该方法，返回是否支持手势返回
 * 该方法可选，默认支持手势返回
 */
- (BOOL)isSupportPanReturnBack;

@end

/**
 * 框架基础导航视图近制器
 * 1.统一处理栈中各个vc支持滑动返回的情况
 */
@interface CNRSNavigationController : UINavigationController<UIGestureRecognizerDelegate>

#pragma mark - UIGestureRecognizerDelegate

/**
 * 不需要手势返回的页面使用类别重写这个方法判断并返回NO时该页面不支持手势返回
 * 最后需要判断是否是根视图，必须增加否则会存在手势和push动画冲突
 if (self.viewControllers.count == 1)//关闭主界面的右滑返回
 {
 return NO;
 }
 else
 {
 return YES;
 }
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

@end
