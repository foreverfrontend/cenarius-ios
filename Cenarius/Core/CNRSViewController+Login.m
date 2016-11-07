//
//  CNRSViewController+Router.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSViewController.h"
#import "CNRSLoginWidget.h"

@implementation CNRSViewController (Login)

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL success, NSString *accessToken))completion
{
    [CNRSLoginWidget loginWithUsername:username password:password completion:completion];
}

+ (NSString *)getAccessToken{
    return [CNRSLoginWidget getAccessToken];
}

+(void)logout
{
    [CNRSLoginWidget logout];
}
@end
