//
//  CNRSHTTPSessionManager.m
//  Cenarius
//
//  Created by M on 2016/11/25.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSHTTPSessionManager.h"
#import "CNRSRequestInterceptor.h"

@implementation CNRSHTTPSessionManager

+ (CNRSHTTPSessionManager *)sharedInstance
{
    static CNRSHTTPSessionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSMutableArray * protocolsArray = [sessionConfiguration.protocolClasses mutableCopy];
        [protocolsArray insertObject:[CNRSRequestInterceptor class] atIndex:0];
        sessionConfiguration.protocolClasses = protocolsArray;
        instance = [[CNRSHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
    });
    return instance;
}

@end
