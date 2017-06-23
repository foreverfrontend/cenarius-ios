//
//  WXProgressHUDModule.m
//  Cenarius
//
//  Created by M on 2017/6/23.
//  Copyright © 2017年 M. All rights reserved.
//

#import "WXProgressHUDModule.h"

@implementation WXProgressHUDModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(show:))
WX_EXPORT_METHOD(@selector(dismiss:))

@end

