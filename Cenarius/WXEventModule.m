//
//  WXEventModule.m
//  Cenarius
//
//  Created by M on 2017/4/17.
//  Copyright © 2017年 M. All rights reserved.
//

#import "WXEventModule.h"
//#import "Cenarius-Swift.h" // Swift类和方法 被 `Objective-C` 识别需要导入

@implementation WXEventModule

#pragma clang diagnostic push //关闭unknow selector的warrning
#pragma clang diagnostic ignored "-Wundeclared-selector"

WX_EXPORT_METHOD(@selector(printSome:callback:)) //Swift 中定义的方法，XCode 转换成的最终的方法名称，在`WeexDemo-Swift.h`里面查看

#pragma clang diagnostic pop

@end
