//
//  Route.swift
//  CenariusExample
//
//  Created by M on 2017/3/29.
//  Copyright © 2017年 M. All rights reserved.
//

import RealmSwift

class Route: Object {
    
    dynamic var file = ""
    dynamic var md = ""
}

class RouteList: Object {
    
    let routes = List<Route>()
}
