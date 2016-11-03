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

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(nullable void (^)(BOOL success))completion
{
    [CNRSLoginWidget loginWithUsername:username password:password completion:completion];
}


@end
