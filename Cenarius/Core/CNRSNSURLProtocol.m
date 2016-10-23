//
//  CNRSNSURLProtocol.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSNSURLProtocol.h"

@implementation CNRSNSURLProtocol

- (void)stopLoading
{
  [self.connection cancel];
  self.connection = nil;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  [self.client URLProtocol:self didFailWithError:error];
}

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

@end
