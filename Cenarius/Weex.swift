//
//  Weex.swift
//  Cenarius
//
//  Created by M on 2017/6/16.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import WeexSDK

public class Weex {
    
    public static func initWeex() {
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

