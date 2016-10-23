//
//  CNRSWebWidget.m
//  Cenarius
//
//  Created by M on 2016/10/17.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSWebWidget.h"
#import "CNRSWebViewController.h"

@interface CNRSWebWidget()

@property (nonatomic, strong) NSDictionary *cnrsDictionary;
@property (nonatomic, strong) NSString *uri;

@end

@implementation CNRSWebWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
    NSString *path = URL.path;
    if (path && [path isEqualToString:@"/widget/web"]) {
        return YES;
    }
    return NO;
}

- (void)prepareWithURL:(NSURL *)URL
{
    _cnrsDictionary = [URL cnrs_jsonDictionary];
    _uri = _cnrsDictionary[@"uri"];
}

- (void)performWithController:(CNRSViewController *)controller
{
    [controller openWebPage:_uri parameters:_cnrsDictionary];
}


@end
