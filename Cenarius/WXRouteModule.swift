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
    
    public func open(_ url: String) {
        Route.open(url: URL(string: url)!, from: weexInstance.viewController)
    }
}
