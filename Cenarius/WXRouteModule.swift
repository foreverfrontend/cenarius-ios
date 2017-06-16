//
//  WXRouteModule.swift
//  Cenarius
//
//  Created by M on 2017/6/16.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension WXRouteModule {
    
//    public func open(_ options: [String: Any]) {
//        let path = options["path"] as! String
//        var params: JSON?
//        if let paramsString = options["params"] as! String? {
//            params = JSON(paramsString.data(using: .utf8)!)
//        }
//        let present = options["present"] as! Bool? ?? false
//        Route.open(path: path, params: params, from: weexInstance.viewController, present: present)
//    }
    
    public func open(_ url: String) {
        Route.open(url: URL(string: url)!, from: weexInstance.viewController)
    }
}
