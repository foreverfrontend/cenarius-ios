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
    
//    private typealias Parameters = [String: String]
//    private typealias HTTPHeaders = [String: String]
    private typealias ParametersCombined = [String: [String]]
    
    private static let sharedInstance = OpenApi()
    private var accessToken: String? = UserDefaults.standard.string(forKey: accessTokenKey)
    private var appKey: String?
    private var appSecret: String?
    
    private static let accessTokenKey = "CenariusAccessToken"
    
    /// Set the accessToken for request
    ///
    /// - Parameter token: accessToken
    public static func setAccessToken(_ token: String?) {
        sharedInstance.accessToken = token
        UserDefaults.standard.setValue(token, forKey: accessTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    public static func getAccessToken() -> String? {
        return sharedInstance.accessToken
    }
    
    /// Set the appKey for request
    ///
    /// - Parameter key: appKey
    public static func setAppKey(_ key: String?) {
        sharedInstance.appKey = key
    }
    
    /// Set the appSecret for request
    ///
    /// - Parameter secret: appSecret
    public static func setAppSecret(_ secret: String?) {
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
    public static func sign(url: String, parameters: Parameters?, headers: HTTPHeaders?) -> String {
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

        let querySting = url.queryFromUrl()
        var queryCombined = querySting
        var bodySting: String?
        if parameters != nil, parameters!.count > 0 {
            if isJson {
                bodySting = "openApiBodyString=" + JSON(parameters!).rawString()!.encodeURIComponent()
            } else {
                bodySting = query(parameters!)
            }
            if queryCombined != nil {
                queryCombined! += "&" + bodySting!
            } else {
                queryCombined = bodySting!
            }
        }
        
        var parametersSigned = [String: String]()
        if queryCombined != nil {
            parametersSigned = queryCombined!.parametersFromQuery()
        }
        let token = sharedInstance.accessToken ?? getAnonymousToken()
        let appKey = sharedInstance.appKey
        let appSecret = sharedInstance.appSecret
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        
        var urlSigned = url
        if urlSigned.contains("?") == false {
            urlSigned += "?"
        } else if querySting != nil {
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
    
    private static func queryFromParameters(_ parameters: [String: String]) -> String {
        var pairs = [String]()
        for parameter in parameters {
            pairs.append(parameter.key.encodeURIComponent() + "=" + parameter.value.encodeURIComponent())
        }
        let query = pairs.joined(separator: "&")
        return query
    }
    
    private static func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += URLEncoding.default.queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    private static func getAnonymousToken() -> String {
        var token = UUID.init().uuidString + "##ANONYMOUS"
        token = token.data(using: .utf8)!.base64EncodedString()
        return token
    }
    
    private static func md5Signature(parameters: [String: String], secret: String) -> String {
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
