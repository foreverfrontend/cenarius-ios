//
//  Cenarius.swift
//  Cenarius
//
//  Created by M on 2017/7/20.
//  Copyright © 2017年 M. All rights reserved.
//

import SVProgressHUD

@objc public class CenariusEngine: NSObject {
    
    public static func initCenarius() {
        Log.setDefaultLog()
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultStyle(.dark)
        registerInterceptor()
        registerRoute()
    }
    
    private static func registerInterceptor() {
        Interceptor.register(RouteInterceptor.self)
        Interceptor.register(ToastInterceptor.self)
    }
    
    private static func registerRoute() {
        Route.register(path: "/web", controller: WebViewController.self)
    }
    
}
