//
//  CNRSRouteManager.swift
//  CenariusExample
//
//  Created by M on 2017/3/27.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import Alamofire

/// `CNRSRouteManager` 提供了对路由信息的管理和使用接口。
class CNRSRouteManager {
    
    private static let sharedInstance = CNRSRouteManager()
    /// www文件夹的url
    private var wwwUrl: URL!
    private var developMode = true
    typealias Completion = (State, Int) -> Void
    private var completion: Completion!
    
    enum State {
        case UNZIP_WWW//解压www
        case UNZIP_WWW_ERROR//解压www出错
        case DOWNLOAD_CONFIG//下载配置文件
        case DOWNLOAD_CONFIG_ERROR//下载配置文件出错
        case DOWNLOAD_ROUTES//下载路由表
        case DOWNLOAD_ROUTES_ERROR//下载路由表出错
        case DOWNLOAD_FILES//下载文件
        case DOWNLOAD_FILES_ERROR//下载文件出错
        case UPDATE_SUCCESS//更新文件成功
    }
    
    /// 设置远程资源地址。
    ///
    /// - Parameter url: www文件夹的url
    class func setWwwUrl(_ url:URL) {
        sharedInstance.wwwUrl = url
    }
    
    class func setDevelopMode(_ mode: Bool) {
        sharedInstance.developMode = mode
    }
    
    /// 更新
    ///
    /// - Parameter completionHandler: 回调
    class func update(completionHandler: @escaping Completion)  {
        sharedInstance.update(completionHandler: completionHandler)
    }
    
    func update(completionHandler: @escaping Completion)  {
        completion = completionHandler
        // 开发模式，直接成功
        if developMode {
            completion(.UPDATE_SUCCESS, 100)
        }
    }
    
}
