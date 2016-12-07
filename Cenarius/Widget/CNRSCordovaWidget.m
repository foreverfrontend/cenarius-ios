//
//  CNRSCordovaWidget.m
//  Cenarius
//
//  Created by M on 2016/10/16.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSCordovaWidget.h"
#import "CDVViewController.h"

@interface CNRSCordovaWidget()

@property (nonatomic, strong) NSDictionary *cnrsDictionary;
@property (nonatomic, strong) NSString *uri;

@end

@implementation CNRSCordovaWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
    NSString *path = URL.path;
    if (path && [path isEqualToString:@"/widget/cordova"]) {
        return YES;
    }
    return NO;
}

- (void)prepareWithURL:(NSURL *)URL
{
    _cnrsDictionary = [URL jsonDictionary];
    _uri = _cnrsDictionary[@"uri"];
}

- (void)performWithController:(CNRSViewController *)controller
{
    [controller openCordovaPage:_uri parameters:_cnrsDictionary];
}

@end
