//
//  UIColor+Cenarius.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import UIKit;

@interface UIColor (Cenarius)

/**
 * 字符串形式创建的 UIColor。
 *
 * @param colorComponents 颜色的字符串，颜色格式：rgba(0,0,0,0)。
 */
+ (instancetype)cnrs_colorWithComponent:(NSString *)colorComponents;

@end
