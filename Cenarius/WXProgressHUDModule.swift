//
//  WXProgressHUDModule.swift
//  Cenarius
//
//  Created by M on 2017/6/23.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import SVProgressHUD

public extension WXRouteModule {
    
    public func show() {
        SVProgressHUD.show()
    }
    
    public func dismiss() {
        SVProgressHUD.dismiss()
    }
}
