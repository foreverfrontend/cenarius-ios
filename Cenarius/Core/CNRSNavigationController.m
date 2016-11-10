//
//  CNRSNavigationController.m
//  Cenarius
//
//  Created by Frank Fan on 14-7-25.
//  Copyright (c) 2014年 gdcattsoft. All rights reserved.
//

#import "CNRSNavigationController.h"

@interface CNRSNavigationController ()

@end

@implementation CNRSNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self openInteractivePopGestureRecognizer];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    if ((self = [super initWithRootViewController:rootViewController]))
    {
        [self openInteractivePopGestureRecognizer];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self openInteractivePopGestureRecognizer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationBarHidden = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

/**
 * 获取当前视图的UIScreenEdgePanGestureRecognizer对象
 */
/*- (id)getScreenEdgePanGestureRecognizer
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7)
        return nil;
    
    id screenEdgePanGestureRecognizer = nil;
    if (self.navigationController.view.gestureRecognizers.count > 0)
    {
        for (UIGestureRecognizer *recognizer in self.navigationController.view.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:NSClassFromString(@"UIScreenEdgePanGestureRecognizer")])
            {
                screenEdgePanGestureRecognizer = recognizer;
                break;
            }
        }
    }
    
    return screenEdgePanGestureRecognizer;
}*/

/**
 * Custom initialization
 * 在naviVC中统一处理栈中各个vc是否支持滑动返回的情况
 * 当前仅最底层的vc关闭滑动返回
 */
- (void)openInteractivePopGestureRecognizer
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        UIGestureRecognizer *interactivePopGestureRecognizer = [self performSelector:@selector(interactivePopGestureRecognizer)];
        interactivePopGestureRecognizer.delegate = self;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UIViewController<CNRSViewControllerPanReturnBackDelegate> *viewController = [self.viewControllers lastObject];
    if ([viewController respondsToSelector:@selector(isSupportPanReturnBack)])
    {
        return [viewController isSupportPanReturnBack];
    }
    else if (self.viewControllers.count == 1)//关闭主界面的右滑返回
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

// 解决手势会跟tableview和scrollview冲突问题 begin
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:NSClassFromString(@"UIScreenEdgePanGestureRecognizer")];
}
// end

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self openInteractivePopGestureRecognizer];
}

@end
