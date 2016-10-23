//
//  CNRSNSURLProtocol.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface CNRSNSURLProtocol : NSURLProtocol

@property (nonatomic, strong) NSURLConnection *connection;

/**
 * 将该请求标记为可以忽略
 *
 * @param request
 */
+ (void)markRequestAsIgnored:(NSMutableURLRequest *)request;

/**
 * 判断该请求是否是被忽略的
 *
 * @param request
 */
+ (BOOL)isRequestIgnored:(NSURLRequest *)request;

@end
