//
//  CommonModule.swift
//  CenariusExample
//
//  Created by Devin on 2017/8/3.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit

enum AppName {
    case wechat
    case qq
}

class CommonModule {
    
    /// 打电话
    ///
    /// - Parameter phone: 电话号码
    open static func callTel(_ phone:String) {
        guard let url = URL(string: "tel://\(phone)") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            
            let message = "确认呼叫: \(phone) ?" as NSString
            let alertC = UIAlertController(title: "呼叫", message: message as String, preferredStyle: .alert)
            
            // 修改message文字颜色
            let messageAttr = NSMutableAttributedString(string: message as String)
            let range = message.range(of: "\(phone)")
            messageAttr.addAttribute(NSForegroundColorAttributeName, value: rgbaColorFromHex(rgb: 0x2D8BFB), range: range)
            alertC.setValue(messageAttr, forKey: "attributedMessage")
            
            let confirmAction = UIAlertAction(title: "确认", style: .destructive, handler: { (alertAction) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }else {
                    UIApplication.shared.openURL(url)
                }
            })
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alertC.addAction(cancelAction)
            alertC.addAction(confirmAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertC, animated: true, completion: nil)
        }
    }
    
    /// 打开微信,并复制内容到剪贴板
    ///
    ///  需要在info.plist添加对应的Scheme白名单
    ///  否则无法判断手机是否安装微信
    /// - Parameter copyStr: 需要复制内容,默认为空
    open static func openWeChat(_ copyStr:String? = nil) {
        openThirdApp(.wechat, copyStr: copyStr)
    }
    
    /// 打开QQ,并复制内容到剪贴板
    ///
    ///  需要在info.plist添加对应的Scheme白名单
    ///  否则无法判断手机是否安装QQ
    /// - Parameter copyStr: 需要复制内容,默认为空
    open static func openQQ(_ copyStr:String? = nil) {
        openThirdApp(.qq, copyStr: copyStr)
    }
    
    private static func openThirdApp(_ name:AppName, copyStr:String? = nil) {
        let url = (name == .wechat) ? URL(string: "weixin://")! : URL(string: "mqq://")!
        
        if UIApplication.shared.canOpenURL(url) {
            
            if copyStr != nil {
                UIPasteboard.general.string = copyStr
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    /// 保存信息到UserDefault
    ///
    /// - Parameters:
    ///   - value: value
    ///   - forKey: key
    open static func saveUserDefault(_ value:Any?, forKey:String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }

    /// 从UserDefault获取信息
    ///
    /// - Parameter forKey: key
    open static func getUserDefault(_ forKey:String) -> Any? {
         return UserDefaults.standard.object(forKey: forKey)
    }
    
    /// 删除UserDefault中信息
    ///
    /// - Parameter forKey: key
    open static func removeUserDefault(_ forKey:String) {
        UserDefaults.standard.removeObject(forKey: forKey)
    }
    
    /// 16进制创建对应rbg颜色
    ///
    /// - Parameters:
    ///   - rgb: example:0xFFFFFF
    ///   - alpha: 透明度 0~1.0
    /// - Returns: UIColor
    open static func rgbaColorFromHex(rgb:Int, alpha: CGFloat = 1.0) -> UIColor {
        
        return UIColor(red: ((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(rgb & 0xFF)) / 255.0,
                       alpha: alpha)
    }
}
