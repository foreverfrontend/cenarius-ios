//
//  CNRSJSONRequestSerializer.m
//  CenariusDemo
//
//  Created by M on 2016/12/26.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSJSONRequestSerializer.h"

@implementation CNRSJSONRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(nullable id)parameters
                                     error:(NSError * _Nullable __autoreleasing *)error
{
    NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    [NSURLProtocol setProperty:parameters forKey:NSURLRequestParametersKey inRequest:request];
    
    return request;
}

@end
