//
//  InterceptorProtocol.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation

public protocol InterceptorProtocol {
    
    static func perform(url: URL, controller: UIViewController) -> Bool
}
