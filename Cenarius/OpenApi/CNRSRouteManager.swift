//
//  CNRSRouteManager.swift
//  CenariusExample
//
//  Created by M on 2017/3/27.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import Alamofire
import Async

/// `CNRSRouteManager` 提供了对路由信息的管理和使用接口。
class CNRSRouteManager {
    
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
    
    
    // MARK: - Private
    
    private static let sharedInstance = CNRSRouteManager()
    /// www文件夹的url
    private var wwwUrl: URL!
    private var developMode = false
    typealias Completion = (State, Int) -> Void
    private var completion: Completion!
    private var routes: Array<Any>?
    private var config: String?
    private var progress: Int = 0
    
    
    private func update(completionHandler: @escaping Completion)  {
        completion = completionHandler
        // 开发模式，直接成功
        if developMode {
            complete(state: .UPDATE_SUCCESS, progress: 100)
            return
        }
        
        // 重置变量
        routes = nil;
        config = nil;
        progress = 0;
    }
    
    private func complete(state: State, progress: Int) {
        Async.main { [weak self] in
            self?.completion(state, progress)
        }
    }
    
    
}
