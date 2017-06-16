//
//  WXNetworkModule.swift
//  Cenarius
//
//  Created by M on 2017/6/13.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public extension WXNetworkModule {
    
    public func request(_ options: [String: Any], callback: WXModuleCallback?) {
        Log.debug(options)
        
        let url = options["url"] as! String
        
        var method: HTTPMethod = .get
        if let m = options["method"] as! String? {
            if m == "POST" {
                method = .post
            }
        }
        
        var parameters: Parameters?
        if let body = options["body"] as! String? {
            parameters = JSON(body.data(using: .utf8)!).dictionaryObject
        }
        
        let headers = options["headers"] as! HTTPHeaders?
        
        let request = Network.request(url, method: method, parameters: parameters, headers: headers).validate().downloadProgress { (progress) in
            
        }
        
        var callbackResponse: [String: Any] = [:]
        if let responseType = options["type"] as! String?, (responseType == "json" || responseType == "jsonp") {
            request.responseJSON { response in
                if let statusCode = response.response?.statusCode {
                    callbackResponse["status"] = statusCode
                    callbackResponse["statusText"] = WXNetworkModule.getStatusText(code: statusCode)
                }
                if let responseHeaders = response.response?.allHeaderFields {
                    callbackResponse["headers"] = responseHeaders
                }
                
                switch response.result {
                case .success(let value):
                    callbackResponse["ok"] = true
                    let json = JSON(value)
                    if let dictionaryData = json.dictionaryObject {
                        callbackResponse["data"] = dictionaryData
                    } else if let arrayData = json.arrayObject {
                        callbackResponse["data"] = arrayData
                    }
                case .failure(let error):
                    callbackResponse["ok"] = false
                    Log.debug(error)
                }
                if callback != nil {
                    callback!(callbackResponse)
                }
            }
        } else {
            request.responseString() { response in
                if let statusCode = response.response?.statusCode {
                    callbackResponse["status"] = statusCode
                    callbackResponse["statusText"] = WXNetworkModule.getStatusText(code: statusCode)
                }
                if let responseHeaders = response.response?.allHeaderFields {
                    callbackResponse["headers"] = responseHeaders
                }
                
                switch response.result {
                case .success(let value):
                    callbackResponse["ok"] = true
                    callbackResponse["data"] = value
                case .failure(let error):
                    callbackResponse["ok"] = false
                    Log.debug(error)
                }
                if callback != nil {
                    callback!(callbackResponse)
                }
            }
        }
    }
    
    private static func getStatusText(code: Int) -> String
    {
        switch (code) {
        case -1:
            return "ERR_INVALID_REQUEST"
        case 100:
            return "Continue"
        case 101:
            return "Switching Protocol"
        case 102:
            return "Processing"
            
        case 200:
            return "OK"
        case 201:
            return "Created"
        case 202:
            return "Accepted"
        case 203:
            return "Non-Authoritative Information"
        case 204:
            return "No Content"
        case 205:
            return " Reset Content"
        case 206:
            return "Partial Content"
        case 207:
            return "Multi-Status"
        case 208:
            return "Already Reported"
        case 226:
            return "IM Used"
            
        case 300:
            return "Multiple Choices"
        case 301:
            return "Moved Permanently"
        case 302:
            return "Found"
        case 303:
            return "See Other"
        case 304:
            return "Not Modified"
        case 305:
            return "Use Proxy"
        case 306:
            return "Switch Proxy"
        case 307:
            return "Temporary Redirect"
        case 308:
            return "Permanent Redirect"
            
        case 400:
            return "Bad Request"
        case 401:
            return "Unauthorized"
        case 402:
            return "Payment Required"
        case 403:
            return "Forbidden"
        case 404:
            return "Not Found"
        case 405:
            return "Method Not Allowed"
        case 406:
            return "Not Acceptable"
        case 407:
            return "Proxy Authentication Required"
        case 408:
            return "Request Timeout"
        case 409:
            return "Conflict"
        case 410:
            return "Gone"
        case 411:
            return "Length Required"
        case 412:
            return "Precondition Failed"
        case 413:
            return "Payload Too Large"
        case 414:
            return "URI Too Long"
        case 415:
            return "Unsupported Media Type"
        case 416:
            return "Range Not Satisfiable"
        case 417:
            return "Expectation Failed"
        case 418:
            return "I'm a teapot"
        case 421:
            return "Misdirected Request"
        case 422:
            return "Unprocessable Entity"
        case 423:
            return "Locked"
        case 424:
            return "Failed Dependency"
        case 426:
            return "Upgrade Required"
        case 428:
            return "Precondition Required"
        case 429:
            return "Too Many Requests"
        case 431:
            return "Request Header Fields Too Large"
        case 451:
            return "Unavailable For Legal Reasons"
            
        case 500:
            return "Internal Server Error"
        case 501:
            return "Not Implemented"
        case 502:
            return "Bad Gateway"
        case 503:
            return "Service Unavailable"
        case 504:
            return "Gateway Timeout"
        case 505:
            return "HTTP Version Not Supported"
        case 506:
            return "Variant Also Negotiates"
        case 507:
            return "Insufficient Storage"
        case 508:
            return "Loop Detected"
        case 510:
            return "Not Extended"
        case 511:
            return "Network Authentication Required"
            
        case -1000, -1002, -1003:
            return "ERR_INVALID_REQUEST"
        default:
            return "Unknown"
        }
    }
    
}

