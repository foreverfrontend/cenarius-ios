//
//  AppDelegate.m
//  CenariusDemo
//
//  Created by M on 2016/10/13.
//  Copyright © 2016年 M. All rights reserved.
//

#import "AppDelegate.h"
#import "Cenarius.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//  Config Cenarius
//    [CNRSConfig setDevelopModeEnable:YES];
//    [CNRSConfig setRemoteFolderUrl:[NSURL URLWithString:@"https://emcsdev.infinitus.com.cn/h5/www"]];
    [CNRSConfig setRemoteFolderUrl:[NSURL URLWithString:@"http://172.20.70.80/hybrid"]];
    [CNRSConfig setRoutesResourcePath:@"www"];
    [CNRSConfig setRoutesWhiteList:@[@"cordova",@"sign"]];
//    [CNRSConfig setDownloadFirstList:@[@"activity/assets/fonts/e-webfont.eot"]];
    [CNRSConfig setCNRSProtocolScheme:@"cenarius"];
    [CNRSConfig setMaxConcurrentOperationCount:2];
    [CNRSConfig setCNRSProtocolHost:@"cenarius-container"];
    [CNRSConfig setBackButtonImage:[UIImage imageNamed:@"common_btn_arrowback.png"] edgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [CNRSConfig setLoginWithService:@"https://uim-test.infinitus.com.cn/oauth20/accessToken" appKey:@"gbss-bupm" appSecret:@"rfGd23Yhjd92JkpWe"];
    [CNRSConfig updateConfig];
    // 先注册 H5 拦截
    [CNRSCacheFileInterceptor registerInterceptor];
    // 再注册 OpenApi 拦截
    [CNRSOpenApiRequestInterceptor registerInterceptor];
    // 获取最新路由表
    [CNRSRouteManager updateRouteFilesWithCompletion:^(BOOL success) {
        
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
