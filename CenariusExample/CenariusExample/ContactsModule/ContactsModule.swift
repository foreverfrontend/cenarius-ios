//
//  ContactsModule.swift
//  CenariusExample
//
//  Created by Devin on 2017/8/7.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Contacts

typealias resultContacts = (Array<Dictionary<String, String>>?,String?) -> ()

@available (iOS 9.0 ,*)
class ContactsModule {
    
    /// 注册权限,并通讯录权限
    ///
    /// 返回结构：
    /// key:
    /// `lastName`  -> `姓`
    /// `firstName` -> `名`
    /// `fullName`  -> `姓名`
    /// `mobile`    -> `电话号码`
    ///
    /// - Returns:
    /// @parameter1 : `[Dictionary,Dictionary,Dictionary]`, 如果用户拒绝则为`nil`
    /// @parameter2 : `用户授权或已授权` 则为 `nil`
    static func getContacts(complete: @escaping resultContacts) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts, completionHandler: { (granted, error) in
                granted ? complete(self.readContacts(), nil) : complete(nil, "拒绝对应用程序的联系人数据的访问")
            })
        case .restricted, .denied:
            complete(nil, "拒绝对应用程序的联系人数据的访问")
        case .authorized:
            // 授权
            complete(readContacts(), nil)
        }
    }
    
    /// 在获取用户权限下,读取通讯录的信息
    ///
    /// 返回结构：
    /// key:
    /// `lastName`  -> `姓`
    /// `firstName` -> `名`
    /// `fullName`  -> `姓名`
    /// `mobile`    -> `电话号码`
    /// - Returns: `[Dictionary,Dictionary,Dictionary]`
    @discardableResult
    private static func readContacts() -> Array<Dictionary<String, String>>{
        
        var result = Array<Dictionary<String, String>>()
        var allPhonesArray = Array<Dictionary<String, String>>()
        
        // 获取联系人仓库
        let store = CNContactStore()
        // 创建联系人信息的请求对象
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        // 根据请求Key, 创建请求对象
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        // 发送请求
        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                
                var phoneArray = [String]()
                
                // 获取姓名
                let givenName = contact.givenName
                let familyName = contact.familyName
                
                // 拼接用户姓名
                let fullName = familyName + givenName
                
                //  获取电话
                let phones = contact.phoneNumbers
                
                for labelValue in phones {
                    let number = labelValue.value
                    var phoneStr = number.stringValue
                    
                    // 格式化
                    phoneStr = phoneStr.replacingOccurrences(of: " ", with: "")
                    phoneStr = phoneStr.replacingOccurrences(of: "(", with: "")
                    phoneStr = phoneStr.replacingOccurrences(of: ")", with: "")
                    phoneStr = phoneStr.replacingOccurrences(of: "-", with: "")
                    
                    // 当前联系人中的电话是否有重复
                    if !phoneArray.contains(phoneStr) {
                        phoneArray.append(phoneStr)
                        
                        let dictTemp = ["FullName":fullName,"Phone":phoneStr]
                        var isExistPhone = false
                        var isExistName = false
                        var sameNameCount = 0
                        
                        //判断和其它人的电话会不会重复
                        for userDict in allPhonesArray {
                            
                            if userDict["Phone"] == phoneStr {
                                isExistPhone = true
                            }
                            if userDict["FullName"] == fullName {
                                isExistName = true
                                sameNameCount += 1
                            }
                        }
                        
                        //判断有没电话重复
                        if !isExistPhone {
                            var isCanAdd = true
                            //判断有没联系人重复
                            if isExistName {
                                //寻找这个同名人有多少电话了，如果不够3个，则可以加入当前电话
                                if sameNameCount >= 3 {
                                    isCanAdd = false
                                }
                            }
                            
                            if isCanAdd {
                                allPhonesArray.append(dictTemp)
                                var tmpDict = Dictionary<String,String>()
                                tmpDict["fullName"] = fullName // 姓 + 名
                                tmpDict["lastName"] = familyName // 姓
                                tmpDict["firstName"] = givenName // 名
                                tmpDict["mobile"] = phoneStr
                                result.append(tmpDict)
                            }
                        }
                    }
                }
            }
        } catch  {
            debugPrint(error)
        }
        return result
    }
}
