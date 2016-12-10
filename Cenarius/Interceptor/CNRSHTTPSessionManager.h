//
//  CNRSHTTPSessionManager.h
//  Cenarius
//
//  Created by M on 2016/11/25.
//  Copyright © 2016年 M. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

/**
 AFHTTPSessionManager 的单例， 已注入 openApi拦截
 */
@interface CNRSHTTPSessionManager : AFHTTPSessionManager

+ (CNRSHTTPSessionManager *)sharedInstance;

@end
