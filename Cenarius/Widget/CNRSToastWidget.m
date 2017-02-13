//
//  CNRSToastWidget.m
//  Cenarius
//
//  Created by M on 2016/10/17.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSToastWidget.h"
#import "CNRSWebViewController.h"
#import "MBProgressHUD.h"

@interface CNRSToastWidget()

@property (nonatomic, strong) NSDictionary *cnrsDictionary;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *url;

@end

@implementation CNRSToastWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
//    NSString *path = URL.path;
//    if (path && [path isEqualToString:@"/widget/web"]) {
//        return YES;
//    }
    return NO;
}

- (void)prepareWithURL:(NSURL *)URL
{
//    _cnrsDictionary = [URL jsonDictionary];
//    _uri = _cnrsDictionary[@"uri"];
//    _url = _cnrsDictionary[@"url"];
}

- (void)performWithController:(CNRSViewController *)controller
{
//    if (_url)
//    {
//        [controller openLightApp:_url parameters:_cnrsDictionary];
//    }
//    else if (_uri)
//    {
//        [controller openWebPage:_uri parameters:_cnrsDictionary];
//    }
}

+ (void)showToast:(NSString *)text withView:(UIView *)view
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.color = [UIColor blackColor];
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = text;
    [view addSubview:hud];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:3];
}

@end
