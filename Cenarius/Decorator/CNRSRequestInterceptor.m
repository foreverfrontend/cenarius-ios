//
//  CNRSRequestInterceptor.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSRequestInterceptor.h"
#import "CNRSDecorator.h"

static NSArray<id<CNRSDecorator>> *sDecorators;
static NSInteger sRegisterInterceptorCounter;

@implementation CNRSRequestInterceptor

+ (void)setDecorators:(NSArray<id<CNRSDecorator>> *)decorators
{
  sDecorators = decorators;
}

+ (NSArray<id<CNRSDecorator>> *)decorators
{
  return sDecorators;
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

#pragma mark - Implement NSURLProtocol methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  // 请求被忽略（被标记为忽略或者已经请求过），不处理
  if ([self isRequestIgnored:request]) {
    return NO;
  }
//  // 请求不是来自浏览器，不处理
//  if (![request.allHTTPHeaderFields[@"User-Agent"] hasPrefix:@"Mozilla"]) {
//    return NO;
//  }

  for (id<CNRSDecorator> decorator in sDecorators) {
    if ([decorator shouldInterceptRequest:request]){
      return YES;
    }
  }

  return NO;
}

- (void)startLoading
{
  NSParameterAssert(self.connection == nil);
  NSParameterAssert([[self class] canInitWithRequest:self.request]);

  __block NSMutableURLRequest *request = nil;
  if ([self.request isKindOfClass:[NSMutableURLRequest class]]) {
    request = (NSMutableURLRequest *)self.request;
  } else {
    request = [self.request mutableCopy];
  }

  for (id<CNRSDecorator> decorator in sDecorators) {
    if ([decorator shouldInterceptRequest:request]) {
      if ([decorator respondsToSelector:@selector(prepareWithRequest:)]) {
        [decorator prepareWithRequest:request];
      }
      [decorator decorateRequest:request];
    }
  }

  [[self class] markRequestAsIgnored:request];
  self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

@end
