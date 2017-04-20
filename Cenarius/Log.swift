//
//  Log.swift
//  Cenarius
//
//  Created by M on 2017/4/20.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import XCGLogger

public class Log: XCGLogger {
    
    public static func setDefaultLog(_ log: XCGLogger = XCGLogger.default) {
        log.setup(level: .verbose, showLogIdentifier: false, showFunctionName: true, showThreadName: false, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: nil)
        log.levelDescriptions = [.info: "ℹ️", .verbose: "🤐", .debug: "🐛", .warning: "⚠️", .error: "‼️", .severe: "❌"]
        XCGLogger.default = log
    }
    
    
}
