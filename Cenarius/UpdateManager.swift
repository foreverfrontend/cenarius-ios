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
import Alamofire_Synchronous
import Async
import RealmSwift
import HandyJSON
import SwiftyVersion
import Zip

/// `UpdateManager` 提供更新能力。
public class UpdateManager {
    
    public enum State {
        case UNZIP_WWW//解压www
        case UNZIP_WWW_ERROR//解压www出错
        case DOWNLOAD_CONFIG_FILE//下载配置文件
        case DOWNLOAD_CONFIG_FILE_ERROR//下载配置文件出错
        case DOWNLOAD_FILES_FILE//下载路由表
        case DOWNLOAD_FILES_FILE_ERROR//下载路由表出错
        case DOWNLOAD_FILES//下载文件
        case DOWNLOAD_FILES_ERROR//下载文件出错
        case UPDATE_SUCCESS//更新文件成功
    }
    public typealias Completion = (State, Int) -> Void
    
    /// 设置远程资源地址。
    ///
    /// - Parameter url: www文件夹的url
    public class func setServerUrl(_ url:URL) {
        UpdateManager.serverUrl = url
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
    private static let retry = 5
    private static let maxConcurrentOperationCount = 2
    
    private static let resourceUrl = Bundle.main.bundleURL.appendingPathComponent(wwwName)
    private static let resourceConfigUrl = resourceUrl.appendingPathComponent(configName)
    private static let resourceFilesUrl = resourceUrl.appendingPathComponent(filesName)
    private static let resourceZipUrl = resourceUrl.appendingPathComponent(zipName)
    private static let cacheUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!).appendingPathComponent(wwwName)
    private static let cacheConfigUrl = cacheUrl.appendingPathComponent(configName)
    private static var serverUrl: URL!
    private static let serverConfigUrl = serverUrl.appendingPathComponent(configName)
    private static let serverFilesUrl = serverUrl.appendingPathComponent(filesName)
    
    private var developMode = false
    private var completion: Completion!
    private var progress: Int = 0
    private var isDownloadFileError = false
    private var downloadFilesCount = 0
    
    private lazy var mainRealm: Realm = {
        var realmConfig = Realm.Configuration()
        realmConfig.fileURL = realmConfig.fileURL!.deletingLastPathComponent().appendingPathComponent(UpdateManager.dbName)
        return try! Realm(configuration: realmConfig)
    }()
    
    private var resourceConfig: Config!
    private var resourceFiles: [File?]!
    private var cacheConfig: Config?
    private var cacheFiles: Results<FileRealm>!
    private var serverConfig: Config!
    private var serverConfigData: Data!
    private var serverFiles: [File?]!
    private var downloadFiles: [File?]!
    
    private func update(completionHandler: @escaping Completion)  {
        completion = completionHandler
        // 开发模式，直接成功
        if developMode {
            complete(state: .UPDATE_SUCCESS)
            return
        }
        
        // 重置变量
        progress = 0;
        
        loadLocalConfig()
        loadLocalFiles()
        downloadConfig()
    }
    
    /// 加载本地的config
    private func loadLocalConfig() {
        do {
            let cacheData = try Data(contentsOf: UpdateManager.cacheConfigUrl)
            let cacheString = String(data: cacheData, encoding: .utf8)
            cacheConfig = Config.deserialize(from: cacheString)
        } catch {
            cacheConfig = nil
        }
        
        let resourceData = try! Data(contentsOf: UpdateManager.resourceConfigUrl)
        let resourceString = String(data: resourceData, encoding: .utf8)
        resourceConfig = Config.deserialize(from: resourceString)!
    }
    
    /// 加载本地的路由表
    private func loadLocalFiles() {
        cacheFiles = mainRealm.objects(FileRealm)
        let resourceData = try! Data(contentsOf: UpdateManager.resourceFilesUrl)
        let resourceString = String(data: resourceData, encoding: .utf8)
        resourceFiles = [File].deserialize(from: resourceString)!
    }
    
    private func downloadConfig() {
        complete(state: .DOWNLOAD_CONFIG_FILE)
        Cenarius.alamofire.request(UpdateManager.serverConfigUrl).validate().responseData { [weak self] response in
            switch response.result {
            case .success(let value):
                self!.serverConfigData = value
                self!.serverConfig = Config.deserialize(from: String(data: self!.serverConfigData, encoding: .utf8))
                if self!.isWwwFolderNeedsToBeInstalled() {
                    // 需要解压www
                    self!.unzipWww()
                } else if self!.shouldDownloadWww {
                    // 下载路由表
                    self!.downloadFilesFile()
                }
                else {
                    // 不需要更新www
                    self!.complete(state: .UPDATE_SUCCESS)
                }
            case .failure(let error):
                Cenarius.logger.error(error)
                self!.complete(state: .DOWNLOAD_CONFIG_FILE_ERROR)
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
        try? FileManager.default.removeItem(at: UpdateManager.cacheUrl)
        try! mainRealm.write {
            mainRealm.deleteAll()
        }
        Async.utility { [weak self] in
            do {
                try Zip.unzipFile(UpdateManager.resourceZipUrl, destination: UpdateManager.cacheUrl, overwrite: true, password: nil, progress: { (unzipProgress) in
                    var progress = Int(unzipProgress * 100)
                    if self!.shouldDownloadWww {
                        progress /= 2
                    }
                    if self!.progress != progress {
                        self!.progress = progress
                        self!.complete(state: .UNZIP_WWW)
                    }
                })
                self!.unzipSuccess()
            } catch {
                Cenarius.logger.error(error)
                self!.complete(state: .UNZIP_WWW_ERROR)
            }
        }
    }
    
    private func unzipSuccess() {
        Async.main { [weak self] in
            // 解压www成功
            try! FileManager.default.copyItem(at: UpdateManager.resourceConfigUrl, to: UpdateManager.cacheConfigUrl)
            // 保存路由表到数据库中
            self!.saveFiles(self!.resourceFiles)
            if self!.shouldDownloadWww {
                self!.downloadFilesFile()
            } else {
                self!.complete(state: .UPDATE_SUCCESS)
            }
        }
    }
    
    private func downloadFilesFile() {
        complete(state: .DOWNLOAD_FILES_FILE)
        loadLocalConfig()
        loadLocalFiles()
        Cenarius.alamofire.request(UpdateManager.serverFilesUrl).validate().responseString { [weak self] response in
            switch response.result {
            case .success(let value):
                self!.serverFiles = [File].deserialize(from: value)!
                self!.downloadFiles = self!.getDownloadFiles(self!.serverFiles)
                if self!.downloadFiles.count > 0 {
                    self!.downloadFiles(self!.downloadFiles)
                } else {
                    self!.saveConfig()
                    self!.complete(state: .UPDATE_SUCCESS)
                }
            case .failure(let error):
                Cenarius.logger.error(error)
                self!.complete(state: .DOWNLOAD_FILES_FILE_ERROR)
            }
        }
    }
    
    private func getDownloadFiles(_ serverFiles: [File?]) -> [File?] {
        var downloadFiles = [File?]()
        for file in serverFiles {
            if shouldDownload(serverFile: file) {
                downloadFiles.append(file)
            }
        }
        return downloadFiles
    }
    
    private func shouldDownload(serverFile: File?) -> Bool {
        for cacheFile in cacheFiles {
            if cacheFile.path == serverFile!.path && cacheFile.md5 == serverFile!.md5 {
                return false
            }
        }
        return true
    }
    
    private func downloadFiles(_ files: [File?]) {
        downloadFilesCount = 0
        isDownloadFileError = false
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = UpdateManager.maxConcurrentOperationCount
        for file in files {
            queue.addOperation { [weak self, weak queue] in
                if self!.downloadFile(file!, retry: UpdateManager.retry) == false {
                    queue?.cancelAllOperations()
                }
            }
        }
    }
    
    private func downloadFile(_ file: File, retry: Int) -> Bool {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = UpdateManager.cacheUrl.appendingPathComponent(file.path)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let response = Cenarius.alamofire.download(UpdateManager.serverUrl.appendingPathComponent(file.path), to: destination).response()
        if let error = response.error {
            Cenarius.logger.debug(error)
            return downloadFileRetry(file, retry: retry)
        } else {
            downloadFileSuccess(file)
            return true
        }
    }
    
    private func downloadFileRetry(_ file: File, retry: Int) -> Bool {
        if retry > 0 {
            return downloadFile(file, retry: retry - 1)
        } else {
            downloadFileError()
            return false
        }
    }
    
    private func downloadFileError() {
        Async.main { [weak self] in
            if self!.isDownloadFileError == false {
                self!.isDownloadFileError == true
                self!.complete(state: .DOWNLOAD_FILES_ERROR)
            }
        }
    }
    
    private func downloadFileSuccess(_ file: File) {
        Async.main { [weak self] in
            if self!.isDownloadFileError {
                return
            }
            try! self!.mainRealm.write {
                self!.mainRealm.add(file.toRealm(), update: true)
            }
            self!.downloadFilesCount += 1
            let unzipProgress = self!.progress
            let downloadProgress = self!.downloadFilesCount * (100 - unzipProgress) / self!.downloadFiles.count
            let progress = unzipProgress + downloadProgress
            if self!.progress != progress {
                self!.progress = progress
                self!.complete(state: .DOWNLOAD_FILES)
            }
            if self!.downloadFilesCount == self!.downloadFiles.count {
                // 所有下载成功
                self!.saveConfig()
                self!.saveFiles(self!.serverFiles)
                self!.complete(state: .UPDATE_SUCCESS)
            }
        }
    }
    
    private func complete(state: State) {
        Async.main { [weak self] in
            self!.completion(state, self!.progress)
        }
    }
    
    private func saveConfig() {
        try! serverConfigData.write(to: UpdateManager.cacheConfigUrl, options: .atomic)
    }
    
    private func saveFiles(_ files: [File?]) {
        try! mainRealm.write {
            mainRealm.deleteAll()
            for file in files {
                mainRealm.add(file!.toRealm())
            }
        }
    }
    
}
