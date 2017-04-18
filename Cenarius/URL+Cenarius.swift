//
//  URL+Cenarius.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation

extension URL {
    
    func parameters() -> OpenApi.Parameters {
        if let query = self.query {
            return query.parameters()
        }
        return OpenApi.Parameters()
    }
}
