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

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(nullable void (^)(BOOL success))completion;

NS_ASSUME_NONNULL_END

@end
