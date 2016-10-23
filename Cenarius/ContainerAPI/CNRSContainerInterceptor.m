//
//  CNRSContainerInterceptor.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSContainerInterceptor.h"
#import "CNRSContainerAPI.h"

static NSArray<id<CNRSContainerAPI>> *sContainerAPIs;

@implementation CNRSContainerInterceptor

+ (void)setContainerAPIs:(NSArray<id<CNRSContainerAPI>> *)mockers
{
  sContainerAPIs = mockers;
}

+ (NSArray<id<CNRSContainerAPI>> *)containerAPIs
{
  return sContainerAPIs;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  // 请求不是来自浏览器，不处理
  if (![request.allHTTPHeaderFields[@"User-Agent"] hasPrefix:@"Mozilla"]) {
    return NO;
  }

  for (id<CNRSContainerAPI> containerAPI in sContainerAPIs) {
    if ([containerAPI shouldInterceptRequest:request]) {
      return YES;
    }
  }

  return NO;
}

- (void)startLoading
{
  for (id<CNRSContainerAPI> containerAPI in sContainerAPIs) {
    if ([containerAPI shouldInterceptRequest:self.request]) {

      if ([containerAPI respondsToSelector:@selector(prepareWithRequest:)]) {
        [containerAPI prepareWithRequest:self.request];
      }

      if ([containerAPI respondsToSelector:@selector(performWithRequest:)]) {
        [containerAPI performWithRequest:self.request];
      }

      NSData *data = [containerAPI responseData];
      NSURLResponse *response = [containerAPI responseWithRequest:self.request];
      [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
      [self.client URLProtocol:self didLoadData:data];
      [self.client URLProtocolDidFinishLoading:self];
      break;
    }
  }
}

@end
