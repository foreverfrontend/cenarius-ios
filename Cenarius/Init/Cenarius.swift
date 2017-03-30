//
//  Cenarius.swift
//  CenariusExample
//
//  Created by M on 2017/3/30.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import XCGLogger
import WeexSDK

var logger: XCGLogger {
    let logger = XCGLogger.default
    logger.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: false, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: nil)
    return logger
}

class Cenarius {
    
    init() {
        initWeexSDK()
    }
    
    // MARK: - Weex
    func initWeexSDK() {
        //business configuration
        WXAppConfiguration.setAppGroup("Cenarius")
        WXAppConfiguration.setAppName("CenariusExample")
        WXAppConfiguration.setAppVersion("0.0.1")
        
        //init sdk enviroment
        WXSDKEngine.initSDKEnvironment()
        
        //register custom module and component，optional
        
        //register the implementation of protocol, optional
        
        //set the log level
        WXLog.setLogLevel(.warning)
    }

}
