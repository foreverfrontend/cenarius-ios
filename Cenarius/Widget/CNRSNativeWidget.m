//
//  CNRSNativeWidget.m
//  Cenarius
//
//  Created by M on 2016/10/17.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSNativeWidget.h"
#import "CNRSViewController.h"

@interface CNRSNativeWidget()

@property (nonatomic, strong) NSDictionary *cnrsDictionary;
@property (nonatomic, strong) NSString *className;

@end

@implementation CNRSNativeWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
    NSString *path = URL.path;
    if (path && [path isEqualToString:@"/widget/native"]) {
        return YES;
    }
    return NO;
}

- (void)prepareWithURL:(NSURL *)URL
{
    _cnrsDictionary = [URL jsonDictionary];
    _className = _cnrsDictionary[@"className"];
}

- (void)performWithController:(CNRSViewController *)controller
{
    [controller openNativePage:_className parameters:self.cnrsDictionary];
}


@end
