//
//  Route.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Route {
    
    private static let sharedInstance = Route()
    private var routes = [String: RouteProtocol.Type]()
    
    public static func register(path: String, controller: RouteProtocol.Type) {
        sharedInstance.routes[path] = controller
    }
    
    public static func open(url: URL, from: UIViewController? = nil) {
        let path = url.path
        let params = url.getParams()
        let present = url.getParameters()["present"] == "true"
        
        open(path: path, params: params, from: from, present: present)
    }
    
    public static func open(path: String, params: JSON? = nil, from: UIViewController? = UIApplication.topViewController(), present: Bool = false) {
        if let toControllerType = sharedInstance.routes[path] {
            let toController = toControllerType.instantiate(params: params)
            if present {
                from?.present(toController, animated: true, completion: nil)
            } else if let navigationController = from?.navigationController {
                navigationController.pushViewController(toController, animated: true)
            }
        }
    }
}
