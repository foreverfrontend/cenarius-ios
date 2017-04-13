//
//  String+Encode.swift
//  Cenarius
//
//  Created by M on 2017/4/11.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import Alamofire

public extension String {
    func encodeURIComponent() -> String {
        return URLEncoding.default.escape(self)
    }
    
    func decodeURIComponent() -> String {
        return self.removingPercentEncoding!
    }
}
