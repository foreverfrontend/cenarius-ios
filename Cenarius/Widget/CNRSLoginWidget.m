//
//  CNRSLoginWidget.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSLoginWidget.h"
#import "CNRSViewController.h"
#import "CNRSOpenApi.h"
#import "CNRSHTTPSessionManager.h"

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
    _cnrsDictionary = [URL jsonDictionary];
    _username = _cnrsDictionary[@"username"];
    _password = _cnrsDictionary[@"password"];
}

- (void)performWithController:(CNRSViewController *)controller
{
    
}

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password captchaId:(NSString *)captchaId captcha:(NSString *)captcha  completion:(nullable void (^)(BOOL success, NSString * _Nullable accessToken, NSString * _Nullable errorMessage))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *service = [CNRSConfig loginService];
    NSString *appKey = [CNRSConfig loginAppKey];
    NSString *appSecret = [CNRSConfig loginAppSecret];
    if (service == nil || appKey == nil || appSecret == nil) {
        completion(NO, nil, @"先设置 service appKey appSecret");
        return;
    }
    parameters[@"app_key"]      = appKey;
    parameters[@"timestamp"]    = [NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970 * 1000];
    parameters[@"username"]     = username;
    parameters[@"password"]     = password;
    parameters[@"terminalType"] = @"mobile";
    parameters[@"rememberMe"]   = @"true";
    parameters[@"captchaId"]    = captchaId;
    parameters[@"captcha"]      = captcha;
    parameters[@"locale"]       = @"zh_CN";
    
    NSString *sign = [CNRSOpenApi md5Signature:parameters secret:appSecret];
    parameters[@"sign"] = sign;
    [manager POST:service parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *token = responseObject[@"access_token"];
        if (token.length > 0) {
            [self saveAccessToken:token];
            completion(YES, token, nil);
//            [self gw];
//            [self getProfile];
        }
        else{
            completion(NO, nil, responseObject[@"error_msg"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(NO, nil, @"系统错误");
    }];
}

+ (void)gw
{
    CNRSHTTPSessionManager *manager = [CNRSHTTPSessionManager sharedInstance];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:@"https://gateway-dev.infinitus.com.cn/api/gbss/dealer/dealers/161891690/sponsor" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

+ (void)getProfile
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",@"https://uim-test.infinitus.com.cn/oauth20/profile",[self getAccessToken]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    NSString *appKey = [CNRSConfig loginAppKey];
    parameters[@"app_key"] = appKey;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
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



@end
