//
//  OpenSystemSettingModule.swift
//  CenariusExample
//
//  Created by Devin on 2017/8/3.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit

class OpenSystemSettingModule {
    
    /// 已经真机测试过下列方法
    ///
    /// 测试iOS版本: iOS9.1、iOS10.3.1
    /// iOS7 不考虑适配
    
    private static let application = UIApplication.shared
    
    private static func openUrl(_ str:String) -> URL{
        return URL(string: str)!
    }
    
    /// 跳转自己应用`设置`
    ///
    /// 注意！！！新项目，需要请求一下位置权限或者通知权限，才可以跳进自己的app设置里面，如果没有任何权限请求，则不能跳转
    open static func openSystemSetting() {
        
        if #available(iOS 10.0, *), application.canOpenURL(openUrl(UIApplicationOpenSettingsURLString)){
            application.open(openUrl(UIApplicationOpenSettingsURLString), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl(UIApplicationOpenSettingsURLString)) {
            application.openURL(openUrl(UIApplicationOpenSettingsURLString))
        }
    }
    
    /// 跳转`通用`
    open static func openSystemGeneral() {
        
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=General")) {
            application.open(openUrl("App-Prefs:root=General"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=General")) {
            application.openURL(openUrl("prefs:root=General"))
        }
    }
    
    /// 跳转`通知`
    open  static func openSystemNotification() {
        
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=NOTIFICATIONS_ID")) {
            application.open(openUrl("App-Prefs:root=NOTIFICATIONS_ID"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=NOTIFICATIONS_ID")) {
            application.openURL(openUrl("prefs:root=NOTIFICATIONS_ID"))
        }
    }
    
    /// 跳转`隐私`
    open static func openSystemPrivacy() {
        
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=Privacy")) {
            application.open(openUrl("App-Prefs:root=Privacy"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=Privacy")) {
            application.openURL(openUrl("prefs:root=Privacy"))
        }
    }
    
    /// 跳转隐私->`照片`
    open static func openSystemPhotos() {
        
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=Privacy&path=PHOTOS")) {
            application.open(openUrl("App-Prefs:root=Privacy&path=PHOTOS"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=Privacy&path=PHOTOS")) {
            application.openURL(openUrl("prefs:root=Privacy&path=PHOTOS"))
        }
    }
    
    /// 跳转隐私->`相机`
    open static func openSystemCamera() {
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=Privacy&path=CAMERA")) {
            application.open(openUrl("App-Prefs:root=Privacy&path=CAMERA"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=Privacy&path=CAMERA")) {
            application.openURL(openUrl("prefs:root=Privacy&path=CAMERA"))
        }
    }
    
    /// 跳转隐私->`通讯录`
    open static func openSystemContacts() {
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=Privacy&path=CONTACTS")) {
            application.open(openUrl("App-Prefs:root=Privacy&path=CONTACTS"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=Privacy&path=CONTACTS")) {
            application.openURL(openUrl("prefs:root=Privacy&path=CONTACTS"))
        }
    }
    
    /// 跳转隐私->`定位`
    ///
    /// NOTE: `App-Prefs:root=LOCATION_SERVICES` 在iOS10以后已经失效
    open static func openSystemLocation() {
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=Privacy&path=LOCATION")) {
            application.open(openUrl("App-Prefs:root=Privacy&path=LOCATION"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=LOCATION_SERVICES")) {
            application.openURL(openUrl("prefs:root=LOCATION_SERVICES"))
        }
    }
    
    /// 跳转`蜂窝移动网络`
    open static func openSystemMobileData() {
        
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=MOBILE_DATA_SETTINGS_ID")) {
            application.open(openUrl("App-Prefs:root=MOBILE_DATA_SETTINGS_ID"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=MOBILE_DATA_SETTINGS_ID")) {
            application.openURL(openUrl("prefs:root=MOBILE_DATA_SETTINGS_ID"))
        }
    }
    
    /// 跳转`Wifi`
    open static func openSystemWifi () {
        if #available(iOS 10.0, *), application.canOpenURL(openUrl("App-Prefs:root=WIFI")) {
            application.open(openUrl("App-Prefs:root=WIFI"), options: [:], completionHandler: nil)
        }else if application.canOpenURL(openUrl("prefs:root=WIFI")) {
            application.openURL(openUrl("prefs:root=WIFI"))
        }
    }
}
