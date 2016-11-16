//
//  CNRSLoginWidget.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSWidget.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * `CNRSLoginWidget` 实现登录。
 */
@interface CNRSLoginWidget : NSObject<CNRSWidget>

/**
 登录
 
 @param username   用户名
 @param password   密码
 @param completion 登录后将执行这个 block
 */
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(nullable void (^)(BOOL success, NSString * _Nullable accessToken, NSString * _Nullable errorMessage))completion;

/**
 * 获取 AccessToken
 */
+ (NSString *)getAccessToken;

/**
 * 登出
 */
+ (void)logout;

/**
 * md5签名
 *
 * @param params 传给服务器的参数
 * @param secret 分配给你的APP_SECRET
 */
+(NSString *)md5Signature:(NSDictionary *)params secret:(NSString *)secret;

NS_ASSUME_NONNULL_END

@end
