//
//  CNRSOpenApi.m
//  Cenarius
//
//  Created by M on 2016/11/22.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSOpenApi.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+CNRSURLEscape.h"
#import "CNRSLoginWidget.h"
#import "CNRSHTTPRequestSerializer.h"

@implementation CNRSOpenApi

/**
 * 新的md5签名，首尾放secret。
 *
 * @param params 传给服务器的参数
 * @param secret 分配给您的APP_SECRET
 */
+(NSString *)md5Signature:(NSDictionary *)params secret:(NSString *)secret
{
    NSString *result = nil;
    NSString *orgin = [self getBeforeSign:params orgin:secret];
    if (orgin == nil)
    {
        return nil;
    }
    // secret last
    orgin = [orgin stringByAppendingString:secret];
    result = [self md5:orgin];
    
    return result;
}

/**
 * 添加参数的封装方法
 */
+(NSString *)getBeforeSign:(NSDictionary *)params orgin:(NSString *)orgin
{
    NSArray *keys = params.allKeys;
    NSArray *newKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in newKeys)
    {
        orgin = [orgin stringByAppendingFormat:@"%@%@",key,params[key]];
    }
    
    return orgin;
}

/**
 *  生成字符串的Md5值
 */
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)openApiQuery:(NSMutableURLRequest *)request
{
    NSString *query = request.URL.query ? request.URL.query : @"";
    NSString *parameterString = [[NSString alloc] initWithString:query];
    
    if ([request.HTTPMethod isEqualToString:@"GET"] == NO && [request.HTTPMethod isEqualToString:@"HEAD"] == NO && [request.HTTPMethod isEqualToString:@"DELETE"] == NO )
    {
        // 参数会在 body 里
        NSString *bodyString = nil;
        NSData *bodyData = request.HTTPBody; // H5 的 body
        NSDictionary *bodyDic = [NSURLProtocol propertyForKey:NSURLRequestParametersKey inRequest:request]; // AF 的 body
        if (bodyData)
        {
            bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        }
        else if (bodyDic)
        {
            bodyString = [bodyDic queryString];
        }
        // 把 body 的字符串加到 query 中
        if (query.length > 0)
        {
            parameterString = [NSString stringWithFormat:@"%@&%@",query,bodyString];
        }
        else
        {
            parameterString = bodyString;
        }
    }
    
    // 多值合并
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSDictionary *oldParameters = [parameterString queryDictionary];
    for (NSString *key in oldParameters)
    {
        NSArray *array = oldParameters[key];
        array = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSComparisonResult result = [obj1 compare:obj2];
            return result;
        }];
        NSString *value = array[0];
        for (NSInteger i = 1; i < array.count; i++) {
            value = [[value stringByAppendingString:key] stringByAppendingString:array[i]];
        }
        parameters[key] = value;
    }
    
    // 加入系统级参数
    NSString *token = [CNRSLoginWidget getAccessToken];
    NSString *appKey = [CNRSConfig loginAppKey];
    NSString *appSecret = [CNRSConfig loginAppSecret];
    NSString *timestamp = [NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970 * 1000];
    if (token && [request.allHTTPHeaderFields[@"Without-Access-Token"] isEqualToString:@"True"] == NO)
    {
        parameters[@"access_token"] = token;
    }
    parameters[@"app_key"] = appKey;
    parameters[@"timestamp"] = timestamp;
    
    // 签名
    NSString *sign = [self md5Signature:parameters secret:appSecret];
    query = [[parameters queryString] stringByAppendingFormat:@"&sign=%@",sign];
   
    return query;
}

@end
