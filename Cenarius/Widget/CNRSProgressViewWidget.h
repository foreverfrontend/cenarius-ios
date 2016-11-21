//
//  CNRSProgressViewWidget.h
//  Cenarius
//
//  Created by M on 2016/11/21.
//  Copyright © 2016年 M. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 提供加载时的进度条，仿微信
 */
@interface CNRSProgressViewWidget : UIProgressView

/**
 开始加载
 */
- (void)startLoad;

/**
 结束加载
 */
- (void)finishLoad;


@end
