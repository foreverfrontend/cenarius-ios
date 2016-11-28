//
//  CNRSOpenApi.h
//  Cenarius
//
//  Created by M on 2016/11/22.
//  Copyright © 2016年 M. All rights reserved.
//

@import Foundation;

@interface CNRSOpenApi : NSObject

/**
 * md5签名
 *
 * @param params 传给服务器的参数
 * @param secret 分配给你的APP_SECRET
 */
+(NSString *)md5Signature:(NSDictionary *)params secret:(NSString *)secret;


/**
 返回签名之后的 Query
 
 @param request 原 request
 */
+ (NSString *)openApiQuery:(NSURLRequest *)request;

@end
