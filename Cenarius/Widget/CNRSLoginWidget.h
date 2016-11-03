//
//  CNRSLoginWidget.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSWidget.h"

/**
 * `CNRSLoginWidget` 实现登录。
 */
@interface CNRSLoginWidget : NSObject<CNRSWidget>
+ (void)createAccessTokenWithUsername:(NSString *)username password:(NSString *)password;
@end
