//
//  CNRSHTTPSessionManager.m
//  Cenarius
//
//  Created by M on 2016/11/25.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSHTTPSessionManager.h"
#import "CNRSOpenApiRequestInterceptor.h"
#import "CNRSHTTPRequestSerializer.h"

@implementation CNRSHTTPSessionManager

+ (CNRSHTTPSessionManager *)sharedInstance
{
    static CNRSHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSMutableArray * protocolsArray = [sessionConfiguration.protocolClasses mutableCopy];
        [protocolsArray insertObject:[CNRSOpenApiRequestInterceptor class] atIndex:0];
        sessionConfiguration.protocolClasses = protocolsArray;
        manager = [[CNRSHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
        manager.requestSerializer = [CNRSHTTPRequestSerializer serializer];
        
    });
    return manager;
}

@end
