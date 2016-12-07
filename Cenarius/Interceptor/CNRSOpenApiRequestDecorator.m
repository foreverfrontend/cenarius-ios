//
//  CNRSOpenApiRequestDecorator.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSOpenApiRequestDecorator.h"
#import "NSURL+Cenarius.h"
#import "CNRSOpenApi.h"
#import "NSDictionary+CNRSMultipleItems.h"

@implementation CNRSOpenApiRequestDecorator

- (instancetype)initWithHeaders:(NSDictionary *)headers
                     parameters:(NSDictionary *)parameters
{
    self = [super init];
    if (self) {
        _headers = headers;
        _parameters = parameters;
    }
    return self;
}

- (BOOL)shouldInterceptRequest:(NSURLRequest *)request
{
    if ([request.URL cnrs_isHttpOrHttps])
    {
        if ([request.allHTTPHeaderFields[@"X-Requested-With"] isEqualToString:@"OpenAPIRequest"] && [request.URL.cnrs_queryDictionary cnrs_itemForKey:@"sign"] == nil)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)decorateRequest:(NSMutableURLRequest *)request
{
    NSString *query = [CNRSOpenApi openApiQuery:request];
    if (query) {
        NSURLComponents *urlComps = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
        urlComps.query = query;
        request.URL = urlComps.URL;
    }
}



@end
