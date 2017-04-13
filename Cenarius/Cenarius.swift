//
//  Cenarius.swift
//  Cenarius
//
//  Created by M on 2017/3/30.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import XCGLogger
import Alamofire

public class Cenarius {
    
    public static var logger: XCGLogger = {
        let logger = XCGLogger.default
        logger.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: false, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: nil)
        return logger
    }()
    
    public static var alamofire: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 60
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager
    }()
}
