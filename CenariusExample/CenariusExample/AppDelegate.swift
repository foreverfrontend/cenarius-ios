//
//  AppDelegate.swift
//  CenariusExample
//
//  Created by M on 2017/3/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius
import Alamofire
import WeexSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        initCenarius()
        registerRoute()
        registerInterceptor()
        initWeexSDK()
        listenNetwork()
        
        return true
    }
    
    func initCenarius() {
        CenariusEngine.initCenarius()
        let url = URL(string: "https://emcs-dev.infinitus.com.cn/h5/www3.0")!
        UpdateManager.setServerUrl(url)
        OpenApi.set(appKey: "a", appSecret: "b")
    }
    
    func registerRoute() {
        Route.register(path: "/user", controller: UserViewController.self)
    }
    
    func registerInterceptor() {
//        Interceptor.register(RouteInterceptor.self)
//        Interceptor.register(ToastInterceptor.self)
    }
    
    // MARK: - Weex
    func initWeexSDK() {
        //set log
        WXLog.setLogLevel(.log)
    }
    
    func listenNetwork() {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        manager?.listener = { status in
            Log.info("Network Status Changed: \(status)")
        }
        manager?.startListening()
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

