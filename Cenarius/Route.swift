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
    
    public static func open(_ url: URL, from: UIViewController? = nil) {
        if let toControllerType = sharedInstance.routes[url.path] {
            let queryParameters = url.parametersFromUrl()
            let params = url.getParams()
            let toController = toControllerType.instantiate(params: params)
            let fromViewController = from ?? UIApplication.topViewController()
            if let navigationController = fromViewController?.navigationController, queryParameters["present"] != "true" {
                navigationController.pushViewController(toController, animated: true)
            } else {
                fromViewController?.present(toController, animated: true, completion: nil)
            }
        }
    }
}
