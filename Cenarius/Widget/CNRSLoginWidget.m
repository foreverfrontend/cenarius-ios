//
//  CNRSLoginWidget.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSLoginWidget.h"
#import "CNRSViewController.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>

#define kAccessTokenKey @"CNRSAccessToken"

@interface CNRSLoginWidget ()

@property (nonatomic, strong) NSDictionary *cnrsDictionary;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end


@implementation CNRSLoginWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
  NSString *path = URL.path;
  if (path && [path isEqualToString:@"/widget/login"]) {
    return YES;
  }
  return NO;
}

- (void)prepareWithURL:(NSURL *)URL
{
    _cnrsDictionary = [URL cnrs_jsonDictionary];
    _username = _cnrsDictionary[@"username"];
    _password = _cnrsDictionary[@"password"];
}

- (void)performWithController:(CNRSViewController *)controller
{
    
}

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL success, NSString *accessToken, NSString *errorMessage))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *service = [CNRSConfig loginService];
    NSString *appKey = [CNRSConfig loginAppKey];
    NSString *appSecret = [CNRSConfig loginAppSecret];
    if (service == nil || appKey == nil || appSecret == nil) {
        completion(NO, nil, @"先设置 service appKey appSecret");
        return;
    }
    parameters[@"app_key"] = appKey;
    parameters[@"timestamp"] = [NSNumber numberWithInteger:[NSDate date].timeIntervalSince1970 * 1000];
    parameters[@"username"] = username;
    parameters[@"password"] = password;
    parameters[@"terminalType"] = @"mobile";
    parameters[@"rememberMe"] = @"true";
    
    NSString *sign = [self md5Signature:parameters secret:appSecret];
    parameters[@"sign"] = sign;
    [manager POST:service parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSString *token = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",token);
        NSString *token = responseObject[@"access_token"];
        if (token.length > 0) {
            [self saveAccessToken:token];
            completion(YES, token, nil);
        }
        else{
            completion(NO, nil, responseObject[@"error_msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(NO, nil, @"系统错误");
    }];

}

+ (void)logout
{
    [self deleteAccessToken];
}

+ (NSString *)getAccessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kAccessTokenKey];
}

+(void)saveAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:accessToken forKey:kAccessTokenKey];
    [userDefaults synchronize];
}

+(void)deleteAccessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kAccessTokenKey];
    [userDefaults synchronize];
}

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

@end
