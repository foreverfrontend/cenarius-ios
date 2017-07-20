//
//  Cenarius.swift
//  Cenarius
//
//  Created by M on 2017/7/20.
//  Copyright © 2017年 M. All rights reserved.
//

import SVProgressHUD
import WeexSDK

public class Cenarius {
    
    public static func initCenarius() {
        Log.setDefaultLog()
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultStyle(.dark)
        registerInterceptor()
        initWeex()
    }
    
    private static func registerInterceptor() {
        Interceptor.register(RouteInterceptor.self)
        Interceptor.register(ToastInterceptor.self)
    }
    
    private static func initWeex() {
        //init SDK environment
        WXSDKEngine.initSDKEnvironment()
        
        WXSDKEngine.registerModule("event", with: WXEventModule.self)
        WXSDKEngine.registerModule("network", with: WXNetworkModule.self)
        WXSDKEngine.registerModule("route", with: WXRouteModule.self)
        WXSDKEngine.registerModule("progressHUD", with: WXProgressHUDModule.self)
        
        WXSDKEngine.registerHandler(WXImgLoaderDefaultImpl(), with: WXImgLoaderProtocol.self)
        
        WXSDKEngine.registerComponent("select", with: WXSelectComponent.self)
    }
}
