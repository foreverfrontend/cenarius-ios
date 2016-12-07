//
//  CNRSNSURLProtocol.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSNSURLProtocol.h"

static NSInteger sRegisterInterceptorCounter;

@implementation CNRSNSURLProtocol

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

#pragma mark - Public methods

+ (void)markRequestAsIgnored:(NSMutableURLRequest *)request
{
  NSString *key = NSStringFromClass([self class]);
  [NSURLProtocol setProperty:@YES forKey:key inRequest:request];
}

+ (BOOL)isRequestIgnored:(NSURLRequest *)request
{
  NSString *key = NSStringFromClass([self class]);
  if ([NSURLProtocol propertyForKey:key inRequest:request]) {
    return YES;
  }
  return NO;
}

+ (BOOL)registerInterceptor
{
    @synchronized (self) {
        sRegisterInterceptorCounter += 1;
    }
    return [NSURLProtocol registerClass:[self class]];
}

+ (void)unregisterInterceptor
{
    @synchronized (self) {
        sRegisterInterceptorCounter -= 1;
        if (sRegisterInterceptorCounter < 0) {
            sRegisterInterceptorCounter = 0;
        }
    }
    
    if (sRegisterInterceptorCounter == 0) {
        return [NSURLProtocol unregisterClass:[self class]];
    }
}

@end
