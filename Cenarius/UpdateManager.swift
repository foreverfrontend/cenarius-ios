//
//  UpdateManager.swift
//  Cenarius
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
//import SwiftyJSON
import SwiftyVersion
import Zip

/// `UpdateManager` 提供更新能力。
public class UpdateManager {
    
    public enum State {
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
    public typealias Completion = (State, Int) -> Void
    
    /// 设置远程资源地址。
    ///
    /// - Parameter url: www文件夹的url
    public class func setServerUrl(_ url:URL) {
        sharedInstance.serverUrl = url
    }
    
    public class func setDevelopMode(_ mode: Bool) {
        sharedInstance.developMode = mode
    }
    
    /// 更新
    ///
    /// - Parameter completionHandler: 回调
    public class func update(completionHandler: @escaping Completion)  {
        sharedInstance.update(completionHandler: completionHandler)
    }
    
    
    // MARK: - Private
    
    private static let sharedInstance = UpdateManager()
    private static let wwwName = "www"
    private static let zipName = "www.zip"
    private static let filesName = "cenarius-files.json"
    private static let configName = "cenarius-config.json"
    private static let dbName = "cenarius-files.realm"
    
    
    /// www文件夹的url
    private var serverUrl: URL!
    private var developMode = false
    private var completion: Completion!
    private var progress: Int = 0
    
    private lazy var realm: Realm = {
        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = realmConfig.fileURL!.deletingLastPathComponent().appendingPathComponent(UpdateManager.dbName)
        return try! Realm(configuration: realmConfig)
    }()
    
    private let resourceUrl = Bundle.main.bundleURL.appendingPathComponent(UpdateManager.wwwName)
    private var resourceConfigUrl:URL {
        return resourceUrl.appendingPathComponent(UpdateManager.configName)
    }
    private var resourceFilesUrl: URL {
        return resourceUrl.appendingPathComponent(UpdateManager.filesName)
    }
    private var resourceZipUrl: URL {
        return resourceUrl.appendingPathComponent(UpdateManager.zipName)
    }
    
    private let cacheUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!).appendingPathComponent(UpdateManager.wwwName)
    //        let cacheUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!).appendingPathComponent(UpdateManager.wwwName)
    //        var cacheFileUrl = URL.init(fileURLWithPath: cacheUrl.absoluteString)
    //        try! FileManager.default.createDirectory(at: cacheFileUrl, withIntermediateDirectories: true, attributes: nil)
    //        var resourceValues = URLResourceValues()
    //        resourceValues.isExcludedFromBackup = true
    //        try! cacheFileUrl.setResourceValues(resourceValues)
    private var cacheConfigUrl: URL {
        return cacheUrl.appendingPathComponent(UpdateManager.configName)
    }
    
    private var serverConfigUrl: URL {
        return serverUrl.appendingPathComponent(UpdateManager.configName)
    }
    private var serverFilesUrl: URL {
        return serverUrl.appendingPathComponent(UpdateManager.filesName)
    }
    private var serverConfig: Config!
    
    private var config: Config?
    private var files: Array<File>?
    
    
    
    
    
    private var resourceFiles: [File?]!
    private var cacheFiles: Results<FileRealm>!
    private var cacheConfig: Config?
    private var resourceConfig: Config!
    
    
    private func update(completionHandler: @escaping Completion)  {
        completion = completionHandler
        // 开发模式，直接成功
        if developMode {
            complete(state: .UPDATE_SUCCESS, progress: 100)
            return
        }
        
        // 重置变量
        files = nil;
        config = nil;
        progress = 0;
        
        loadLocalConfig()
        loadLocalFiles()
        downloadConfig()
    }
    
    
    /// 加载本地的config
    private func loadLocalConfig() {
        do {
            let cacheData = try Data(contentsOf: cacheConfigUrl)
            let cacheString = String(data: cacheData, encoding: .utf8)
            cacheConfig = Config.deserialize(from: cacheString)
        } catch {
            cacheConfig = nil
        }
        
        let resourceData = try! Data(contentsOf: resourceConfigUrl)
        let resourceString = String(data: resourceData, encoding: .utf8)
        resourceConfig = Config.deserialize(from: resourceString)!
    }
    
    /// 加载本地的路由表
    private func loadLocalFiles() {
        cacheFiles = realm.objects(FileRealm)
        let resourceData = try! Data(contentsOf: resourceFilesUrl)
        let resourceString = String(data: resourceData, encoding: .utf8)
        resourceFiles = [File].deserialize(from: resourceString)!
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
                        self!.unzipWww()
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
    
    private func unzipWww() {
        Async.background { [weak self] in
            try? FileManager.default.removeItem(at: self!.cacheUrl)
            do {
                try Zip.unzipFile(self!.resourceZipUrl, destination: self!.cacheUrl, overwrite: true, password: nil, progress: { (unzipProgress) in
                    var progress = Int(unzipProgress * 100)
                    if self!.shouldDownloadWww {
                        progress /= 2
                    }
                    self!.complete(state: .UNZIP_WWW, progress: progress)
                })
                self!.unzipSuccess()
            } catch {
                Cenarius.logger.error(error)
                self!.complete(state: .UNZIP_WWW_ERROR, progress: 0)
            }
        }
    }
    
    private func unzipSuccess() {
        // 解压www成功
        // 保存路由表到数据库中
        
    }
    
    private func complete(state: State, progress: Int) {
        Async.main { [weak self] in
            self!.completion(state, progress)
        }
    }
    
}
