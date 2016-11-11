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

static NSString * const CNRSCacheFileInterceptorHandledKey = @"CNRSCacheFileInterceptorHandledKey";

@interface CNRSCacheFileInterceptor ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSString *responseDataFilePath;

@end


@implementation CNRSCacheFileInterceptor

#pragma mark - NSURLProtocol's methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![CNRSConfig isCacheEnable])
    {
        return NO;
    }
//  // 不是 HTTP 或 FILE 请求，不处理
//  if (![request.URL cnrs_isHttpOrHttps] && !request.URL.isFileURL) {
//    return NO;
//  }
  // 请求被忽略（被标记为忽略或者已经请求过），不处理
  if ([self isRequestIgnored:request]) {
    return NO;
  }
//  // 请求不是来自浏览器，不处理
//  if (![request.allHTTPHeaderFields[@"User-Agent"] hasPrefix:@"Mozilla"]) {
//    return NO;
//  }

  // 如果请求不需要被拦截，不处理
  if (![self shouldInterceptRequest:request]) {
    return NO;
  }

  return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}

- (void)startLoading
{
  NSParameterAssert(self.connection == nil);
  NSParameterAssert([[self class] canInitWithRequest:self.request]);

  CNRSDebugLog(@"Intercept <%@> within <%@>", self.request.URL, self.request.mainDocumentURL);

  __block NSMutableURLRequest *request = nil;
  if ([self.request isKindOfClass:[NSMutableURLRequest class]]) {
    request = (NSMutableURLRequest *)self.request;
  } else {
    request = [self.request mutableCopy];
  }

    CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
    NSURL *uri = [[self class] cnrs_uriForRequest:request];
    //路由表
    if ([routeManager isInRoutes:uri])
    {
        NSURL *localHtmlURL = [routeManager localHtmlURLForURI:uri];
        if (localHtmlURL) {
            request.URL = localHtmlURL;
        }
        else
        {
            NSURL *remoteHtmlURL = [routeManager remoteHtmlURLForURI:uri];
            request.URL = remoteHtmlURL;
        }
    }
    else if ([routeManager isInWhiteList:uri])
    {
        NSString *urlString = [[CNRSRouteFileCache sharedInstance] resourceFilePathForUri:uri];
        request.URL = [NSURL URLWithString:urlString];
    }
    
    
    
//  NSURL *localURL = [self cnrs_localFileURL:request.URL];
//  if (localURL) {
//    request.URL = localURL;
//  }
  
  [[self class] markRequestAsIgnored:request];
  self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)stopLoading
{
  [self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate' methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSURLRequest *request = connection.currentRequest;

    if (![request.URL isFileURL] && [[self class] shouldInterceptRequest:request])
  {
      self.responseDataFilePath = [self cnrs_temporaryFilePath];
      [[NSFileManager defaultManager] createFileAtPath:self.responseDataFilePath contents:nil attributes:nil];
      self.fileHandle = nil;
      self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.responseDataFilePath];
  }
  
  [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  if ([[self class] shouldInterceptRequest:connection.currentRequest] && self.fileHandle)
  {
    [self.fileHandle writeData:data];
  }
 [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  if ([[self class] shouldInterceptRequest:connection.currentRequest] && self.fileHandle)
  {
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    NSData *data = [NSData dataWithContentsOfFile:self.responseDataFilePath];
      CNRSRoute *route = [[CNRSRouteManager sharedInstance] routeForRemoteURL:connection.currentRequest.URL];
    [[CNRSRouteFileCache sharedInstance] saveRouteFileData:data withRoute:route];
  }
  [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  if ([[self class] shouldInterceptRequest:connection.currentRequest] && self.fileHandle) {
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.responseDataFilePath error:nil];
  }
  [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark - Public methods

+ (BOOL)shouldInterceptRequest:(NSURLRequest *)request
{
    NSURL *uri = [self cnrs_uriForRequest:request];
    if (uri)
    {
        NSURL *baseUri = [NSURL URLWithString:uri.path];
        CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
        
        //拦截在路由表中的uri
        if ([routeManager isInRoutes:baseUri])
        {
            return YES;
        }
        
        //拦截在白名单中的uri
        if ([routeManager isInWhiteList:baseUri])
        {
            return YES;
        }
    }
    
    return NO;
}

+ (void)markRequestAsIgnored:(NSMutableURLRequest *)request
{
  [NSURLProtocol setProperty:@YES forKey:CNRSCacheFileInterceptorHandledKey inRequest:request];
}

+ (BOOL)isRequestIgnored:(NSURLRequest *)request
{
  if ([NSURLProtocol propertyForKey:CNRSCacheFileInterceptorHandledKey inRequest:request]) {
    return YES;
  }
  return NO;
}

#pragma mark - Private methods

+ (NSURL *)cnrs_uriForRequest:(NSURLRequest *)request
{
    NSURL *uri = [[CNRSRouteManager sharedInstance] uriForUrl:request.URL];
    return uri;
}

//+ (BOOL)cnrs_isCacheableResponse:(NSURLResponse *)response
//{
//  NSSet *cacheableTypes = [NSSet setWithObjects:@"application/javascript", @"application/x-javascript",
//                          @"text/javascript", @"text/css", nil];
//  return [cacheableTypes containsObject:response.MIMEType];
//}

- (NSString *)cnrs_temporaryFilePath
{
  NSString *fileName = [[NSUUID UUID] UUIDString];
  return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

@end
