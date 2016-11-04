//
//  ViewController.m
//  CenariusDemo
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "ViewController.h"
#import "CNRSWebViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.93 green:0.29 blue:0.30 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
}

- (IBAction)openLight:(id)sender
{
    [super openLightApp:@"https://www.baidu.com/" parameters:nil];
}

- (IBAction)openNative:(id)sender
{
    [super openNativePage:@"NativeView" parameters:nil];
}

- (IBAction)openWeb:(id)sender
{
    [super openWebPage:@"build/index.html;param=value?query=value#ref" parameters:nil];
}

- (IBAction)openCordova:(id)sender {
    [super openCordovaPage:@"build/index.html" parameters:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
