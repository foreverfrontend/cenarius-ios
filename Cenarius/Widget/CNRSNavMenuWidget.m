//
//  CNRSNavMenuWidget.m
//  Cenarius
//
//  Created by M on 2016/10/18.
//  Copyright © 2016年 M. All rights reserved.
//

#import "CNRSNavMenuWidget.h"
#import "CNRSMenuItem.h"
#import "CNRSWebViewController.h"
#import "CDVViewController.h"

@interface CNRSNavMenuWidget()

@property (nonatomic, weak) CNRSViewController *controller;
@property (nonatomic, strong) NSDictionary *cnrsDictionary;
@property (nonatomic, copy) NSArray<CNRSMenuItem *> *menuItems;

@end

@implementation CNRSNavMenuWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
    NSString *path = URL.path;
    if (path && [path isEqualToString:@"/widget/nav_menu"]) {
        return true;
    }
    return false;
}

- (void)prepareWithURL:(NSURL *)URL
{
    _cnrsDictionary = [URL jsonDictionary];
    NSArray *menuArray = _cnrsDictionary[@"menuItems"];
    NSMutableArray *menuMutableArray = [NSMutableArray array];
    for (NSDictionary *itemDic in menuArray)
    {
        if ([itemDic isKindOfClass:[NSDictionary class]])
        {
            [menuMutableArray addObject:[[CNRSMenuItem alloc] initWithDictionary:itemDic]];
        }
    }
    self.menuItems = [menuMutableArray copy];
}

- (void)performWithController:(CNRSViewController *)controller
{
    _controller = controller;
    
    if (!self.menuItems || self.menuItems.count == 0) {
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    [self.menuItems enumerateObjectsUsingBlock:^(CNRSMenuItem *menu, NSUInteger idx, BOOL *stop) {
        UIBarButtonItem *item = [self _frd_buildMenuItem:menu];
        item.tag = idx;
        [items addObject:item];
    }];
    controller.navigationItem.rightBarButtonItems = items;
}


#pragma mark - Private methods

- (void)_frd_buttonItemAction:(UIBarButtonItem *)item
{
    CNRSMenuItem *menu = self.menuItems[item.tag];
    if ([_controller isKindOfClass:[CNRSWebViewController class]])
    {
        [((CNRSWebViewController *)_controller).webView stringByEvaluatingJavaScriptFromString:menu.action];
    }
    else if ([_controller isKindOfClass:[CDVViewController class]])
    {
        [(UIWebView *)((CDVViewController *)_controller).webView stringByEvaluatingJavaScriptFromString:menu.action];
    }
}

- (UIBarButtonItem *)_frd_buildMenuItem:(CNRSMenuItem *)menu
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:menu.title
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(_frd_buttonItemAction:)];
    return item;
}


@end
