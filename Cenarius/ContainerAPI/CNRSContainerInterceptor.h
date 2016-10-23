//
//  CNRSContainerInterceptor.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

#import "CNRSNSURLProtocol.h"

@protocol CNRSContainerAPI;

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSContainerInterceptor` 是一个 Cenarius-Container 的请求侦听器。
 * 这个侦听器用于模拟网络请求。这些网络请求并不会发送出去，而是由 Native 处理。
 * 比如向 Web 提供当前位置信息。
 *
 */
@interface CNRSContainerInterceptor : CNRSNSURLProtocol

/**
 * 设置这个侦听器所有的请求模仿器数组，该数组成员是符合 `CNRSContainerAPI` 协议的对象，即一组请求模仿器。
 *
 * @param mockers 模仿器数组
 */
+ (void)setContainerAPIs:(NSArray<id<CNRSContainerAPI>> *)containerAPIs;

/**
 * 这个侦听器所有的请求模仿器，该数组成员是符合 `CNRSContainerAPI` 协议的对象，即一组请求模仿器。
 */
+ (nullable NSArray<id<CNRSContainerAPI>> *)containerAPIs;

@end

NS_ASSUME_NONNULL_END
