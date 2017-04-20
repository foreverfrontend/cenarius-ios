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
    
    static let defaultLog: XCGLogger = {
        let log = XCGLogger.default
        log.setup(level: .verbose, showLogIdentifier: false, showFunctionName: true, showThreadName: false, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: nil)
        return log
    }()
    
    // MARK: - instance method
    
    public func info(_ info: String) {
        super.info(CGPoint())
    }
    
    public func verbose(_ verbose: String) {
        super.verbose("🤐 " + verbose)
    }
    
    public func debug(_ debug: String) {
        super.debug("🐛 " + debug)
    }
    
    public func warning(_ warning: String) {
        super.warning("⚠️ " + warning)
    }
    
    public func error(_ error: String) {
        super.error("❌ " + error)
    }
    
    // MARK: - class method
    
    public static func info(_ info: String) {
        Log.defaultLog.info(info)
    }
    
    public static func verbose(_ verbose: String) {
        Log.defaultLog.verbose(verbose)
    }
    
    public static func debug(_ debug: String) {
        Log.defaultLog.debug(debug)
    }
    
    public static func warning(_ warning: String) {
        Log.defaultLog.warning(warning)
    }
    
    public static func error(_ error: String) {
        Log.defaultLog.error(error)
    }
    
}
