//
//  OpenApi.swift
//  Cenarius
//
//  Created by M on 2017/4/10.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import SwiftyJSON
import CryptoSwift
import Alamofire

/// class for Signature
public class OpenApi {
    
    public typealias Parameters = [String: String]
    public typealias HTTPHeaders = [String: String]
    typealias ParametersCombined = [String: [String]]
    
    private static let sharedInstance = OpenApi()
    private var accessToken: String? = UserDefaults.standard.string(forKey: accessTokenKey)
    private var appKey: String?
    private var appSecret: String?
    
    private static let accessTokenKey = "CenariusAccessToken"
    
    /// Set the accessToken for request
    ///
    /// - Parameter token: accessToken
    public class func setAccessToken(_ token: String?) {
        sharedInstance.accessToken = token
        UserDefaults.standard.setValue(token, forKey: accessTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    public class func getAccessToken() -> String? {
        return sharedInstance.accessToken
    }
    
    /// Set the appKey for request
    ///
    /// - Parameter key: appKey
    public class func setAppKey(_ key: String?) {
        sharedInstance.appKey = key
    }
    
    /// Set the appSecret for request
    ///
    /// - Parameter secret: appSecret
    public class func setAppSecret(_ secret: String?) {
        sharedInstance.appSecret = secret
    }
    
    /// Sign for url
    ///
    /// - Parameters:
    ///   - url: The URL.
    ///   - method: The HTTP method.
    ///   - parameters: The HTTP parameters.
    ///   - headers: The HTTP headers.
    /// - Returns: The URL after signed
    public class func sign(url: String, parameters: Parameters?, headers: HTTPHeaders?) -> String {
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
        var queryCombined = query
        var bodySting: String?
        if parameters != nil, parameters!.count > 0 {
            if isJson {
                bodySting = "openApiBodyString=" + JSON(parameters!).rawString()!.encodeURIComponent()
            } else {
                bodySting = queryFromParameters(parameters!)
            }
            if queryCombined != nil {
                queryCombined! += "&" + bodySting!
            } else {
                queryCombined = bodySting!
            }
        }
        
        var parametersSigned = Parameters()
        if queryCombined != nil {
            parametersSigned = parametersFromQuery(queryCombined!)
        }
        let token = sharedInstance.accessToken ?? getAnonymousToken()
        let appKey = sharedInstance.appKey
        let appSecret = sharedInstance.appSecret
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        
        var urlSigned = url
        if urlSigned.contains("?") == false {
            urlSigned += "?"
        } else if query != nil {
            urlSigned += "&"
        }
        urlSigned += "access_token=" + token.encodeURIComponent()
        urlSigned += "&timestamp=" + timestamp
        if appKey != nil {
            urlSigned += "&app_key=" + appKey!.encodeURIComponent()
            
        }
        
        parametersSigned["access_token"] = token
        parametersSigned["timestamp"] = timestamp
        parametersSigned["app_key"] = appKey
        if appSecret != nil {
            let sign = md5Signature(parameters: parametersSigned, secret: appSecret!)
            urlSigned += "&sign=" + sign.encodeURIComponent()
        }
        return urlSigned
    }
    
    private class func queryFromUrl(_ url: String) -> String? {
        let range = url.range(of: "?")
        if range != nil {
            let query = url.substring(from: range!.upperBound)
            if query.isEmpty == false {
                return query
            }
        }
        return nil
    }
    
    private class func parametersFromQuery(_ query: String) -> Parameters {
        var parametersCombined = ParametersCombined()
        let pairs = query.components(separatedBy: "&")
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
        var results = Parameters()
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
    
    private class func queryFromParameters(_ parameters: Parameters) -> String {
        var pairs = [String]()
        for parameter in parameters {
            pairs.append(parameter.key.encodeURIComponent() + "=" + parameter.value.encodeURIComponent())
        }
        let query = pairs.joined(separator: "&")
        return query
    }
    
    private class func getAnonymousToken() -> String {
        var token = UUID.init().uuidString + "##ANONYMOUS"
        token = token.data(using: .utf8)!.base64EncodedString()
        return token
    }
    
    private class func md5Signature(parameters: Parameters, secret: String) -> String {
        var result = secret
        let keys = parameters.keys.sorted()
        for key in keys {
            result += key + parameters[key]!
        }
        result += secret
        result = result.md5()
        return result
    }
    
    
}
