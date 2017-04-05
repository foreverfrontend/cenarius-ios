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
    
    override static func primaryKey() -> String? {
        return "path"
    }
    
//    override func isEqual(_ object: Any?) -> Bool {
//        if let o = object as? FileRealm {
//            if o.path == self.path && o.md5 == self.md5 {
//                return true
//            }
//        }
//        return false
//    }
}

struct File: HandyJSON {
    var path: String!
    var md5: String!
    
    func toRealm() -> FileRealm {
        let fileRealm = FileRealm()
        fileRealm.path = self.path
        fileRealm.md5 = self.md5
        return fileRealm
    }
}
