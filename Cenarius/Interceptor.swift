//
//  Interceptor.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation

public class Interceptor {
    
    public static let scheme = "cenarius"
    private var interceptors = [InterceptorProtocol.Type]()
    
    private static let sharedInstance = Interceptor()
    
    public static func register(_ interceptor: InterceptorProtocol.Type) {
        sharedInstance.interceptors.append(interceptor)
    }
    
    public static func perform(url: URL, controller: UIViewController) -> Bool {
        for interceptor in sharedInstance.interceptors {
            if interceptor.perform(url: url, controller: controller) {
                return true
            }
        }
        return false
    }
}

