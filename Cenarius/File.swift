//
//  File.swift
//  Cenarius
//
//  Created by M on 2017/3/29.
//  Copyright © 2017年 M. All rights reserved.
//

import RealmSwift

class File: Object {
    
    dynamic var path = ""
    dynamic var md5 = ""
}

class RouteList: Object {
    
    let files = List<File>()
}
