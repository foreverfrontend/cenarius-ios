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
@property (nonatomic, strong) NSString *url;

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
    _cnrsDictionary = [URL jsonDictionary];
    _uri = _cnrsDictionary[@"uri"];
    _url = _cnrsDictionary[@"url"];
}

- (void)performWithController:(CNRSViewController *)controller
{
    if (_url)
    {
        [controller openLightApp:_url parameters:_cnrsDictionary];
    }
    else if (_uri)
    {
        [controller openWebPage:_uri parameters:_cnrsDictionary];
    }
}


@end
