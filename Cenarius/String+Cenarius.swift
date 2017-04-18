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
    
    func parameters() -> OpenApi.Parameters {
        var parametersCombined = OpenApi.ParametersCombined()
        let pairs = self.components(separatedBy: "&")
        for pair in pairs {
            let keyValue = pair.components(separatedBy: "=")
            if(keyValue.count > 1) {
                let key = keyValue[0].decodeURIComponent()
                let value = keyValue[1].decodeURIComponent()
                if parametersCombined[key] != nil {
                    parametersCombined[key]!.append(value)
                } else {
                    parametersCombined[key] = [value]
                }
            }
        }
        var results = OpenApi.Parameters()
        for parametersCombined in parametersCombined {
            let key = parametersCombined.key
            let values = parametersCombined.value
            let sortedValues = values.sorted()
            var valueString = sortedValues[0]
            for index in 1..<sortedValues.count {
                valueString += key + sortedValues[index]
            }
            results[key] = valueString
        }
        return results
    }
}
