//
//  CNRSOpenApiRequestInterceptor.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSOpenApiRequestInterceptor.h"
#import "NSURL+Cenarius.h"
#import "CNRSOpenApi.h"
#import "NSDictionary+Cenarius.h"

@interface CNRSOpenApiRequestInterceptor()

@end

@implementation CNRSOpenApiRequestInterceptor

#pragma mark - NSURLProtocol's methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // 请求被忽略（被标记为忽略或者已经请求过），不处理
    if ([self isRequestIgnored:request])
    {
        return NO;
    }
    
    if ([request.URL isHttpOrHttps])
    {
        if ([request.allHTTPHeaderFields[@"X-Requested-With"] isEqualToString:@"OpenAPIRequest"] && [request.URL.queryDictionary itemForKey:@"sign"] == nil)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)startLoading
{
    NSMutableURLRequest *request = nil;
    request = [self.request mutableCopy];

    NSString *query = [CNRSOpenApi openApiQuery:request];
    if (query) {
//        NSURLComponents *urlComps = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
//        urlComps.query = query;
//        request.URL = urlComps.URL;
//        request.URL = [NSURL URLWithString:query];
        NSRange range = [request.URL.absoluteString  rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",[request.URL.absoluteString substringToIndex:range.location],query]];
        }else{
            request.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",request.URL.absoluteString,query]];
        }
    }
    
    [[self class] markRequestAsIgnored:request];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.cnrsSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.cnrsDataTask = [self.cnrsSession dataTaskWithRequest:request];
    [self.cnrsDataTask resume];
}

- (void)stopLoading
{
    [self.cnrsDataTask cancel];
    [self.cnrsSession invalidateAndCancel];
    self.cnrsDataTask = nil;
    self.cnrsSession = nil;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
    {
        [self.client URLProtocol:self didFailWithError:error];
    }
    else
    {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

@end
