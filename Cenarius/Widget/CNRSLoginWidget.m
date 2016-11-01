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

- (void)createAccessTokenWithUsername:(NSString *)username password:(NSString *)password
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"username"] = username;
    parameters[@"password"] = password;
    parameters[@"terminalType"] = @"terminalType";
    parameters[@"remenberMe"] = @"remenberMe";

    [manager POST:@"https://uim-test.infinitus.com.cn/oauth20/accessToken" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

@end
