//
//  CNRSToastWidget.h
//  Cenarius
//
//  Created by M on 2016/10/17.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSWidget.h"

/**
 弹toast
 */
@interface CNRSToastWidget : NSObject<CNRSWidget>

+ (void)showToast:(NSString *)text withView:(UIView *)view;

@end
