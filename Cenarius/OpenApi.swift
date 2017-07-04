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
    
    public static let xRequestKey = "X-Requested-With"
    public static let xRequestValue = "OpenAPIRequest"
    public static let contentTypeKey = "Content-Type"
    public static let contentTypeValue = "application/json"
    
    private static let accessTokenKey = "CenariusAccessToken"
    private typealias ParametersCombined = [String: [String]]
    
    private static let sharedInstance = OpenApi()
    private var accessToken: String? = UserDefaults.standard.string(forKey: accessTokenKey)
    private var appKey: String!
    private var appSecret: String!
    
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
    
    public static func getAppKey() -> String {
        return sharedInstance.appKey
    }

    public static func getAppSecret() -> String {
        return sharedInstance.appSecret
    }
    
    /// Set the appKey appSecret for request
    public static func set(appKey: String, appSecret: String) {
        sharedInstance.appKey = appKey
        sharedInstance.appSecret = appSecret
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
                if header.key == xRequestKey && header.value == xRequestValue {
                    isOpenApi = true
                }
                if header.key == contentTypeKey && header.value.contains(contentTypeValue) {
                    isJson = true
                }
            }
        }
        
        if isOpenApi == false {
            return url
        }

        let queryString = url.getQuery()
        var queryCombined = queryString
        var bodyString: String?
        if parameters != nil, parameters!.count > 0 {
            if isJson {
                bodyString = "openApiBodyString=" + JSON(parameters!).rawString(options: .init(rawValue: 0))!.encodeURIComponent()
            } else {
                bodyString = parameters!.toQuery()
            }
            if queryCombined != nil {
                queryCombined! += "&" + bodyString!
            } else {
                queryCombined = bodyString!
            }
        }
        
        var parametersSigned = [String: String]()
        if queryCombined != nil {
            parametersSigned = queryCombined!.queryToParameters()
        }
        let token = sharedInstance.accessToken ?? getAnonymousToken()
        let appKey = sharedInstance.appKey!
        let appSecret = sharedInstance.appSecret!
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        
        var urlSigned = url
        if urlSigned.contains("?") == false {
            urlSigned += "?"
        } else if queryString != nil {
            urlSigned += "&"
        }
        urlSigned += "access_token=" + token.encodeURIComponent()
        urlSigned += "&timestamp=" + timestamp
        urlSigned += "&app_key=" + appKey.encodeURIComponent()
        
        parametersSigned["access_token"] = token
        parametersSigned["timestamp"] = timestamp
        parametersSigned["app_key"] = appKey
        let sign = md5Signature(parameters: parametersSigned, secret: appSecret)
        urlSigned += "&sign=" + sign.encodeURIComponent()
        return urlSigned
    }
    
    private static func getAnonymousToken() -> String {
        var token = UUID.init().uuidString + "##ANONYMOUS"
        token = token.data(using: .utf8)!.base64EncodedString()
        return token
    }
    
    public static func md5Signature(parameters: [String: String], secret: String) -> String {
        var result = secret
        let keys = parameters.keys.sorted()
        for key in keys {
            result += key + parameters[key]!
        }
        result += secret
        result = result.md5().uppercased()
        return result
    }
    
    
}
