//
//  RouteProtocol.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol RouteProtocol {
        
    static func instantiate(params: JSON?) -> UIViewController
}
