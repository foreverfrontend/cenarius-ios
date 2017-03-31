//
//  CNRSRouteManager.swift
//  CenariusExample
//
//  Created by M on 2017/3/27.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import XCGLogger
import Alamofire
import Async
import RealmSwift
import HandyJSON
import SwiftyJSON
import SwiftyVersion

/// `RouteManager` 提供了对路由信息的管理和使用接口。
class RouteManager {
    
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
    class func setServerUrl(_ url:URL) {
        sharedInstance.serverUrl = url
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
    
    private static let sharedInstance = RouteManager()
    private static let wwwName = "www"
    private static let routesName = "cenarius-routes.json"
    private static let configName = "cenarius-config.json"
    private static let dbName = "cenarius-routes.realm"
    
    
    /// www文件夹的url
    private var serverUrl: URL!
    private var developMode = false
    typealias Completion = (State, Int) -> Void
    private var completion: Completion!
    private var progress: Int = 0
    
    private lazy var realm: Realm = {
        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = realmConfig.fileURL!.deletingLastPathComponent().appendingPathComponent(RouteManager.dbName)
        return try! Realm(configuration: realmConfig)
    }()
    
    private let resourceUrl = URL(string: Bundle.main.bundlePath)!.appendingPathComponent(RouteManager.wwwName)
    private var resourceConfigUrl:URL {
        return resourceUrl.appendingPathComponent(RouteManager.configName)
    }
    private var resourceRoutesUrl: URL {
        return resourceUrl.appendingPathComponent(RouteManager.routesName)
    }
    
    

    private lazy var cacheUrl: URL = {
        let cacheUrl = URL(string: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!)!.appendingPathComponent(RouteManager.wwwName)
        var cacheFileUrl = URL.init(fileURLWithPath: cacheUrl.absoluteString)
        try! FileManager.default.createDirectory(at: cacheFileUrl, withIntermediateDirectories: true, attributes: nil)
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try! cacheFileUrl.setResourceValues(resourceValues)
        return cacheUrl
    }()
    private var cacheConfigUrl: URL {
        return cacheUrl.appendingPathComponent(RouteManager.configName)
    }
    
    private var serverConfigUrl: URL {
        return serverUrl.appendingPathComponent(RouteManager.configName)
    }
    private var serverRoutesUrl: URL {
        return serverUrl.appendingPathComponent(RouteManager.routesName)
    }
    private var serverConfig: Config!
    
    private var config: Config?
    private var routes: Array<Route>?
    
    
    
    
    
    private var resourceRoutes: Array<Route>?
    private var cacheRoutes: Results<Route>?
    private var cacheConfig: Config?
    private var resourceConfig: Config!
    
    private var shouldDownloadWww: Bool {
        if (hasMinVersion(serverConfig: serverConfig)) {
            // 满足最小版本要求
            if (isWwwFolderNeedsToBeInstalled()) {
                return Version(serverConfig.release) > Version(resourceConfig.release)
            } else {
                return Version(serverConfig.release) > Version(cacheConfig!.release)
            }
        }
        return false;
    }
    
    
    
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
        
        loadLocalConfig()
        downloadConfig()
    }
    
    
    /// 加载本地的config
    private func loadLocalConfig() {
        do {
            let cacheData = try Data(contentsOf: URL(fileURLWithPath: cacheConfigUrl.absoluteString))
            let cacheString = String(data: cacheData, encoding: .utf8)
            cacheConfig = Config.deserialize(from: cacheString)
        } catch {
            cacheConfig = nil
        }
        
        let resourceData = try! Data(contentsOf: URL(fileURLWithPath: resourceConfigUrl.absoluteString))
        let resourceString = String(data: resourceData, encoding: .utf8)
        resourceConfig = Config.deserialize(from: resourceString)
    }
    
    private func downloadConfig() {
        complete(state: .DOWNLOAD_CONFIG, progress: 0)
        Cenarius.alamofire.request(serverConfigUrl).validate().responseString { [weak self] response in
            switch response.result {
            case .success(let value):
                if let config = Config.deserialize(from: value) {
                    self!.serverConfig = config
                    if self!.isWwwFolderNeedsToBeInstalled() {
                        // 需要解压www
                        
                    } else if self!.shouldDownloadWww {
                        // 下载路由表
                    }
                    else {
                        // 不需要更新www
                        self!.complete(state: .UPDATE_SUCCESS, progress: 100)
                    }
                }
                
            case .failure(let error):
                Cenarius.logger.error(error)
                self!.complete(state: .DOWNLOAD_CONFIG_ERROR, progress: 0)
            }
        }
    }
    
    private func hasMinVersion(serverConfig: Config) -> Bool {
        let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        if Version(appBuild) >= Version(serverConfig.ios_min_version) {
            return true
        }
        return false
    }
    
    private func isWwwFolderNeedsToBeInstalled() -> Bool {
        if cacheConfig == nil || Version(resourceConfig.release) > Version(cacheConfig!.release) {
            return true
        }
        return false
    }
    
    private func complete(state: State, progress: Int) {
        Async.main { [weak self] in
            self!.completion(state, progress)
        }
    }

}
