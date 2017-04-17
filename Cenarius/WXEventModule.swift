//
//  WXEventModule.swift
//  Cenarius
//
//  Created by M on 2017/4/17.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation

public extension WXEventModule {
    
    public func printSome(someThing:String, callback:WXModuleCallback) {
        print(someThing)
        callback(someThing)
    }
    
    public func openURL(_ url:String) {
    }
}
