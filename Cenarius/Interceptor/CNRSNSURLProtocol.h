//
//  CNRSNSURLProtocol.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface CNRSNSURLProtocol : NSURLProtocol<NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *cnrsDataTask;
@property (nonatomic, strong) NSURLSession *cnrsSession;

/**
 * 将该请求标记为可以忽略
 */
+ (void)markRequestAsIgnored:(NSMutableURLRequest *)request;

/**
 * 判断该请求是否是被忽略的
 */
+ (BOOL)isRequestIgnored:(NSURLRequest *)request;

/**
 * 注册一个侦听器。
 */
+ (BOOL)registerInterceptor;

/**
 * 注销一个侦听器。
 */
+ (void)unregisterInterceptor;

@end
