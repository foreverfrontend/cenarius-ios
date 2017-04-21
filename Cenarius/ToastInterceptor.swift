//
//  RouteInterceptor.swift
//  Cenarius
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import Toaster

public class ToastInterceptor: InterceptorProtocol {
    
    public static func perform(url: URL, controller: UIViewController) -> Bool {
        if url.scheme == "cenarius", url.host == "toast" {
            Toast(text: url.getParams()?["text"].stringValue).show()
            return true
        }
        return false
    }
}
