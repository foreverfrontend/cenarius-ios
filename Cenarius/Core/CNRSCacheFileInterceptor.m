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

    // 如果缓存启用，尝试读取本地文件。如果没有本地文件（本地文件包括缓存，和资源文件夹），则从服务器读取。
    NSURL *uri = [[self class] cnrs_uriForRequest:request];
    NSURL *localHtmlURL = [[CNRSRouteManager sharedInstance] localHtmlURLForURI:uri];
    if (localHtmlURL) {
        request.URL = localHtmlURL;
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

//  if (![request.URL isFileURL] &&
//      [[self class] shouldInterceptRequest:request] &&
//      [[self class] cnrs_isCacheableResponse:response])
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
    //拦截包含uri的request
    NSURL *uri = [self cnrs_uriForRequest:request];
    CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
    NSURL *remoteHtmlURL = [routeManager remoteHtmlURLForURI:uri];
    if (remoteHtmlURL)
    {
        //uri 在路由表中
        return YES;
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
    CNRSRouteManager *routeManager = [CNRSRouteManager sharedInstance];
    NSURL *uri = [routeManager uriForUrl:request.URL];
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
