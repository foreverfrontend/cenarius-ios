//
//  CNRSHTTPRequestSerializer.h
//  Cenarius
//
//  Created by M on 2016/12/9.
//  Copyright © 2016年 M. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

extern NSString* const NSURLRequestParametersKey;

/**
 解决 HTTPBody 为 nil 的问题
 */
@interface CNRSHTTPRequestSerializer : AFHTTPRequestSerializer

@end
