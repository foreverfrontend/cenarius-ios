//
//  Config.swift
//  CenariusExample
//
//  Created by M on 2017/3/29.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import HandyJSON

struct Config: HandyJSON {
    
    var name: String!
    var ios_min_version: String!
    var android_min_version: String!
    var release: String!
}
