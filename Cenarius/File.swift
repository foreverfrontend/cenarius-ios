//
//  File.swift
//  Cenarius
//
//  Created by M on 2017/3/29.
//  Copyright © 2017年 M. All rights reserved.
//

import RealmSwift
import HandyJSON

class FileRealm: Object {
    
    dynamic var path = ""
    dynamic var md5 = ""
}

struct File: HandyJSON {
    var path: String!
    var md5: String!
}
