//
//  CNRSRequestInterceptor.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

#import "CNRSNSURLProtocol.h"

@protocol CNRSDecorator;

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSRequestInterceptor` 是一个 Cenarius-Container 的请求侦听器。
 * 这个侦听器用于修改请求，比如增添请求的 url 参数，添加自定义的 http header。
 *
 */
@interface CNRSRequestInterceptor : CNRSNSURLProtocol

/**
 * 设置这个侦听器所有的请求装修器数组，该数组成员是符合 `CNRSDecorator` 协议的对象，即一组请求装修器。
 * 
 * @param decorators 装修器数组
 */
+ (void)setDecorators:(NSArray<id<CNRSDecorator>> *)decorators;

/**
 * 获得对应的请求装修器数组，该数组成员是符合 `CNRSDecorator` 协议的对象，即一组请求装修器。
 */
+ (nullable NSArray<id<CNRSDecorator>> *)decorators;

@end

NS_ASSUME_NONNULL_END
