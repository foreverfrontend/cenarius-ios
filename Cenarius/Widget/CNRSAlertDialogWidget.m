//
//  CNRSAlertDialogWidget.m
//  Cenarius
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSAlertDialogWidget.h"
#import "CNRSAlertDialogData.h"
#import "CNRSWebViewController.h"
#import "CDVViewController.h"

@interface CNRSAlertDialogWidget ()

@property (nonatomic, weak) CNRSViewController *controller;
@property (nonatomic, strong) CNRSAlertDialogData *alertDialogData;

@end


@implementation CNRSAlertDialogWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
  NSString *path = URL.path;
  if (path && [path isEqualToString:@"/widget/alert_dialog"]) {
    return YES;
  }
  return NO;
}

- (void)prepareWithURL:(NSURL *)URL
{
  NSString *string = [[URL queryDictionary] itemForKey:@"data"];
  self.alertDialogData = [[CNRSAlertDialogData alloc] initWithString:string];
}

- (void)performWithController:(CNRSViewController *)controller
{

  _controller = controller;

  if (!self.alertDialogData) {
    return;
  }

  NSString *title = self.alertDialogData.title;
  NSString *message = self.alertDialogData.message;
  NSArray<CNRSAlertDialogButton *> *buttons = self.alertDialogData.buttons;

  [self cnrs_alertWithTitle:title message:message buttons:buttons];
}

#pragma mark - Private methods

- (void)cnrs_alertWithTitle:(NSString *)title
                    message:(NSString *)message
                    buttons:(NSArray<CNRSAlertDialogButton *> *)buttons
{
  UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];

  for (CNRSAlertDialogButton *button in buttons) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:button.text
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *alertAction)
                             {
                                 if ([_controller isKindOfClass:[CNRSWebViewController class]])
                                 {
                                     [((CNRSWebViewController *)_controller).webView stringByEvaluatingJavaScriptFromString:button.action];
                                 }
                                 else if ([_controller isKindOfClass:[CDVViewController class]])
                                 {
                                     [(UIWebView *)((CDVViewController *)_controller).webView stringByEvaluatingJavaScriptFromString:button.action];
                                 }
                             }];

    [alertView addAction:action];
  }

  [_controller presentViewController:alertView animated:YES completion:nil];
}

@end
