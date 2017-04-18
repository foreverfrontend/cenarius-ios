//
//  RouteInterceptor.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation

class RouteInterceptor: InterceptorProtocol {
    
    func canPerform(url: URL) -> Bool {
        return true
    }

    
    func perform(controller: UIViewController) {
        
    }
}
