//
//  URL+Cenarius.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import SwiftyJSON

extension URL {
    
    func getParameters() -> [String: String] {
        if let query = self.query {
            return query.queryToParameters()
        }
        return [String: String]()
    }
    
    func getParams() -> JSON? {
        let queryParameters = getParameters()
        var params: JSON?
        if let paramsString = queryParameters["params"] {
            params = JSON(data: paramsString.data(using: .utf8)!)
        }
        return params
    }
}
