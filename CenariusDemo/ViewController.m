//
//  ViewController.m
//  CenariusDemo
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "ViewController.h"
#import "CNRSWebViewController.h"
#import "CNRSLoginWidget.h"
#import "CNRSHTTPSessionManager.h"
#import "CNRSHTTPRequestSerializer.h"
#import "CNRSJSONRequestSerializer.h"

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
    [super openWebPage:@"///build///////index.html?query=value#ref" parameters:nil];
}

- (IBAction)openCordova:(id)sender {
    [super openCordovaPage:@"sign/sign.html" parameters:nil];
}

- (IBAction)login:(id)sender {
    [CNRSLoginWidget loginWithUsername:@"337304000"  password:@"123444" completion:^(BOOL success, NSString * _Nullable accessToken, NSString * _Nullable errorMessage) {
        
    }];
}

- (IBAction)aF:(id)sender {
    CNRSHTTPSessionManager *manager = [CNRSHTTPSessionManager sharedInstance];
    // 相对 AFHTTPRequestSerializer
//    manager.requestSerializer = [CNRSHTTPRequestSerializer serializer];
    // 相对 JSONRequestSerializer
    manager.requestSerializer = [CNRSJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"OpenAPIRequest" forHTTPHeaderField:@"X-Requested-With"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"http://10.86.21.66:6089/api/gbss/dealer/promotions/join" parameters:@{@"A":@"B"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",errResponse);
            
            
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
