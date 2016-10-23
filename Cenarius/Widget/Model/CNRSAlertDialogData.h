//
//  CNRSAlertDialogData.h
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSModel.h"

/**
 * `CNRSAlertDialogButton` 对话框上按钮的数据对象。
 */
@interface CNRSAlertDialogButton : CNRSModel

/**
 * 按钮的标题文字。
 */
@property (nonatomic, copy, readonly) NSString *text;

/**
 * 按按钮后将执行的动作。
 */
@property (nonatomic, copy, readonly) NSString *action;

@end

/**
 * `CNRSAlertDialogData` 对话框的数据对象。
 */
@interface CNRSAlertDialogData : CNRSModel

/**
 * 对话框的标题。
 */
@property (nonatomic, copy, readonly) NSString *title;

/**
 * 对话框的消息。
 */
@property (nonatomic, copy, readonly) NSString *message;

/**
 * 对话框的按钮。
 */
@property (nonatomic, readonly) NSArray<CNRSAlertDialogButton *> *buttons;

@end
