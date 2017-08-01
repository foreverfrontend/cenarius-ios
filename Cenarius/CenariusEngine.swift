//
//  Cenarius.swift
//  Cenarius
//
//  Created by M on 2017/7/20.
//  Copyright © 2017年 M. All rights reserved.
//

import SVProgressHUD

public class CenariusEngine {
    
    public static func initCenarius() {
        Log.setDefaultLog()
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultStyle(.dark)
        registerInterceptor()
    }
    
    private static func registerInterceptor() {
        Interceptor.register(RouteInterceptor.self)
        Interceptor.register(ToastInterceptor.self)
    }
    
}
