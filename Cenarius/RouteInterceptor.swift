//
//  RouteInterceptor.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation

class RouteInterceptor: InterceptorProtocol {
    
    static func perform(url: URL, controller: UIViewController) -> Bool {
        if url.scheme == "cenarius", url.host == "route" {
            Route.open(url: url, from: controller)
            return true
        }
        return false
    }
}
