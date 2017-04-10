//
//  OpenApi.swift
//  Cenarius
//
//  Created by M on 2017/4/10.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import SwiftyJSON

/// class for Signature
public class OpenApi {
    
    public enum HTTPMethod: String {
        case get     = "GET"
        case post    = "POST"
    }
    public typealias Parameters = [String: String]
    public typealias HTTPHeaders = [String: String]
    typealias CombinedParameters = [String: [String]]
    
    
    /// Sign for url
    ///
    /// - Parameters:
    ///   - url: The URL.
    ///   - method: The HTTP method.
    ///   - parameters: e parameters.
    ///   - headers: The HTTP headers.
    /// - Returns: The URL after signed
    public class func sign(url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?) -> String {
        var isOpenApi = false
        var isJson = false
        if headers != nil {
            for header in headers! {
                if header.key == "X-Requested-With" && header.value == "OpenAPIRequest" {
                    isOpenApi = true
                }
                if header.key == "Content-Type" && header.value.contains("application/json") {
                    isJson = true
                }
            }
        }
        
        if isOpenApi == false {
            return url
        }
        
        let query = queryFromUrl(url)
        
        if query != nil {
            Cenarius.logger.debug("query: \(query!)")
//            let queryParameters = parametersFromQuery(query!)
//            Cenarius.logger.debug("queryParameters: \(queryParameters)")
//            for parameter in queryParameters {
//                if parameter.key == "sign" {
//                    return url
//                }
//            }
//            if parameters != nil {
//                let combinedParameters = combineParameters(parameters, queryParameters)
//            }
        }
        var bodySting: String
        if parameters != nil {
            if isJson {
                bodySting = "openApiBodyString=" + JSON(parameters!).rawString()!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            } else {
                bodySting = queryFromParameters(parameters!)
            }
        }
        
        
        return query!
    }
    
    private class func queryFromUrl(_ url: String) -> String? {
        let range = url.range(of: "?")
        if range != nil {
            let query = url.substring(from: range!.upperBound)
            return query
        }
        return nil
    }
    
//    private class func parametersFromQuery(_ query: String) -> Parameters {
//        var results = Parameters()
//        let pairs = query.components(separatedBy: "&")
//        for pair in pairs {
//            let keyValue = pair.components(separatedBy: "=")
//            if(keyValue.count > 1) {
//                results.updateValue(keyValue[1].removingPercentEncoding!, forKey: keyValue[0].removingPercentEncoding!)
//            }
//        }
//        return results
//    }
    
    private class func queryFromParameters(_ parameters: Parameters) -> String {
        var pairs = [String]()
        for parameter in parameters {
            pairs.append(parameter.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "=" + parameter.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        let query = pairs.joined(separator: "&")
        return query
    }
}
