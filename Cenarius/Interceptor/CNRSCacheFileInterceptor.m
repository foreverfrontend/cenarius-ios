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

@interface CNRSCacheFileInterceptor ()

@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) CNRSRoute *route;

@end

static NSMutableDictionary *routeDictionary;

@implementation CNRSCacheFileInterceptor

#pragma mark - NSURLProtocol's methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // 请求被忽略（被标记为忽略或者已经请求过），不处理
    if ([self isRequestIgnored:request])
    {
        return NO;
    }
    
    // 不是 HTTP 或 FILE 请求，不处理
    if (![request.URL isHttpOrHttps] && !request.URL.isFileURL) {
        return NO;
    }
    
    CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
    NSURL *uri = [routeManager uriForUrl:request.URL];
    if (uri)
    {
        if (routeDictionary == nil)
        {
            routeDictionary = [[NSMutableDictionary alloc] init];
        }
        NSURL *finalUrl = nil;
        NSURL *baseUri = [NSURL URLWithString:uri.path];
        //拦截在路由表中的uri
        CNRSRoute *route = [routeManager routeForURI:baseUri];
        if (route)
        {
            NSURL *localHtmlURL = [routeManager localHtmlURLForRoute:route uri:uri];
            if (localHtmlURL) {
                finalUrl = localHtmlURL;
            }
            else
            {
                NSURL *remoteHtmlURL = [routeManager remoteHtmlURLForRoute:route uri:uri];
                finalUrl = remoteHtmlURL;
            }
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:route, @"route", finalUrl, @"finalUrl",nil];
            [routeDictionary setObject:dic forKey:request.URL];
            
            return YES;
        }
        //拦截在白名单中的uri
        else if ([routeManager isInWhiteList:baseUri])
        {
            NSString *urlString = [[CNRSRouteFileCache sharedInstance] resourceFilePathForUri:uri];
            finalUrl = [NSURL fileURLWithPath:urlString];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:finalUrl, @"finalUrl",nil];
            [routeDictionary setObject:dic forKey:request.URL];
            
            return YES;
        }
    }
    
    return NO;
}

- (void)startLoading
{
    CNRSDebugLog(@"Intercept <%@> within <%@>", self.request.URL, self.request.mainDocumentURL);
    
    NSMutableURLRequest *request = nil;
    request = [self.request mutableCopy];
    
    NSDictionary *dic = [routeDictionary objectForKey:self.request.URL];
    self.route = [dic objectForKey:@"route"];
    request.URL = [dic objectForKey:@"finalUrl"];
    
    [[self class] markRequestAsIgnored:request];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.cnrsSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.cnrsDataTask = [self.cnrsSession dataTaskWithRequest:request];
    [self.cnrsDataTask resume];
    self.mutableData = [[NSMutableData alloc] init];
}

- (void)stopLoading
{
    [routeDictionary removeObjectForKey:self.request.URL];
    [self.cnrsDataTask cancel];
    [self.cnrsSession invalidateAndCancel];
    self.cnrsDataTask = nil;
    self.cnrsSession = nil;
    self.mutableData = nil;
    self.route = nil;
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

@end
