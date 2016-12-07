//
//  CNRSCacheFileInterceptor.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSCacheFileInterceptor.h"
#import "CNRSRouteFileCache.h"
#import "CNRSLogging.h"
#import "NSURL+Cenarius.h"
#import "CNRSRouteManager.h"
#import "CNRSConfig.h"

@interface CNRSCacheFileInterceptor ()<NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) CNRSRoute *route;

@end


@implementation CNRSCacheFileInterceptor

#pragma mark - NSURLProtocol's methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![CNRSConfig isCacheEnable])
    {
        return NO;
    }
    
    // 不是 HTTP 或 FILE 请求，不处理
    if (![request.URL cnrs_isHttpOrHttps] && !request.URL.isFileURL) {
        return NO;
    }
    
    // 请求被忽略（被标记为忽略或者已经请求过），不处理
    if ([self isRequestIgnored:request]) {
        return NO;
    }
    //  // 请求不是来自浏览器，不处理
    //  if (![request.allHTTPHeaderFields[@"User-Agent"] hasPrefix:@"Mozilla"]) {
    //    return NO;
    //  }
    
//     // 如果请求不需要被拦截，不处理
//        if (![self shouldInterceptRequest:request]) {
//            return NO;
//        }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{    
    CNRSDebugLog(@"Intercept <%@> within <%@>", self.request.URL, self.request.mainDocumentURL);
    
    self.route = nil;
    NSMutableURLRequest *request = nil;
    if ([self.request isKindOfClass:[NSMutableURLRequest class]]) {
        request = (NSMutableURLRequest *)self.request;
    } else {
        request = [self.request mutableCopy];
    }
    
    NSURL *uri = [[self class] cnrs_uriForRequest:request];
    if (uri)
    {
        NSURL *baseUri = [NSURL URLWithString:uri.path];
        CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
        
        //拦截在路由表中的uri
        CNRSRoute *route = [routeManager routeForURI:baseUri];
        if (route)
        {
            self.route = route;
            NSURL *localHtmlURL = [routeManager localHtmlURLForRoute:route uri:uri];
            if (localHtmlURL) {
                request.URL = localHtmlURL;
            }
            else
            {
                NSURL *remoteHtmlURL = [routeManager remoteHtmlURLForRoute:route uri:uri];
                request.URL = remoteHtmlURL;
            }
        }
        //拦截在白名单中的uri
        else if ([routeManager isInWhiteList:baseUri])
        {
            NSString *urlString = [[CNRSRouteFileCache sharedInstance] resourceFilePathForUri:uri];
            request.URL = [NSURL fileURLWithPath:urlString];
        }
    }

    [[self class] markRequestAsIgnored:request];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.dataTask = [session dataTaskWithRequest:request];
    [self.dataTask resume];
    self.mutableData = [[NSMutableData alloc] init];
}

- (void)stopLoading
{
    [self.dataTask cancel];
    self.mutableData = nil;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.mutableData = [[NSMutableData alloc] init];
    completionHandler(NSURLSessionResponseAllow);
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.mutableData appendData:data];
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
        if (self.route && [task.currentRequest.URL isFileURL] == NO)
        {
            [[CNRSRouteFileCache sharedInstance] saveRouteFileData:self.mutableData withRoute:self.route];
        }
        [self.client URLProtocolDidFinishLoading:self];
    }
}

#pragma mark - Private methods

+ (NSURL *)cnrs_uriForRequest:(NSURLRequest *)request
{
    NSURL *uri = [[CNRSRouteManager sharedInstance] uriForUrl:request.URL];
    return uri;
}

@end
