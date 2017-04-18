//
//  Interceptor.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation

public class Interceptor {
    
    private var interceptors = [InterceptorProtocol]()
    
    public static let sharedInstance = Interceptor()
    
    public static func register(_ interceptor: InterceptorProtocol) {
        sharedInstance.interceptors.append(interceptor)
    }
}

