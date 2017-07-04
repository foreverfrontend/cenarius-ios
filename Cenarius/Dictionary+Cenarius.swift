//
//  Dictionary+Cenarius.swift
//  Cenarius
//
//  Created by M on 2017/7/4.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import Alamofire

public extension Dictionary where Key == String {
    
    func toQuery() -> String {
        var components: [(String, String)] = []
        for key in self.keys.sorted(by: <) {
            let value = self[key]!
            components += URLEncoding.default.queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
}
