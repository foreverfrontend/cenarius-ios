//
//  NetworkModule.swift
//  CenariusExample
//
//  Created by Devin on 2017/8/2.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import SystemConfiguration

enum NetWorkType {
    case NotReachable
    case TYPE_2G
    case TYPE_3G
    case TYPE_4G
    case LTE
    case Wifi
    case Reachable(ConnectionType)
}

enum ConnectionType {
    case ethernetOrWiFi
    case wwan
    case unknown
}

class NetworkModule {
    
    /// 检查网络状态
    /// 根据手机状态栏显示的网络类型
    ///
    /// - Returns: 当前网络状态
    open static func checkNetworkStatus() -> NetWorkType {
        
        let networkConnected = connectedToNetwork()
        
        if !networkConnected.connected {
            return .NotReachable
        }
        
        let application = UIApplication.shared
        
        if application.isStatusBarHidden {
            debugPrint("当前页面状态栏被隐藏,无法准确的获取网络状态类型")
            return NetWorkType.Reachable(networkConnected.connectionType)
        }
        
        let statusBar = application.value(forKeyPath: "statusBar") as! UIView
        let foregroundView = statusBar.value(forKeyPath: "foregroundView") as! UIView
        var networkView:UIView?
        for childView in foregroundView.subviews {
            if childView.isKind(of: NSClassFromString("UIStatusBarDataNetworkItemView")!) {
                networkView = childView
                break
            }
        }
        
        if networkView != nil {
            let num = networkView!.value(forKeyPath: "dataNetworkType")! as! Int
            switch num {
            case 0:
                return .NotReachable
            case 1:
                return .TYPE_2G
            case 2:
                return .TYPE_3G
            case 3:
                return .TYPE_4G
            case 4:
                return .LTE
            case 5:
                return .Wifi
            default:
                return .Reachable(.ethernetOrWiFi)
            }
        }
        return .NotReachable
    }
    
    /// 网络链接情况
    ///
    /// - Returns: 是否有网络 / 网络链接类型
    open static func connectedToNetwork() -> (connected:Bool,connectionType:ConnectionType) {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return (false,.unknown)
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return (false,.unknown)
        }
        
        let conType = flags.contains(.isWWAN) ?  ConnectionType.wwan : ConnectionType.ethernetOrWiFi
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return ((isReachable && !needsConnection),conType)
    }
}
