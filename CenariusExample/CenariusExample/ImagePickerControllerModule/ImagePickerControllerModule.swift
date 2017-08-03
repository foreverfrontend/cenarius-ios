//
//  ImagePickerControllerModule.swift
//  Module
//
//  Created by silence on 2017/7/28.
//  Copyright © 2017年 silence. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol ImagePickerControllerModuleDelegate : class {
    
    /// 获取图片回调
    ///
    /// - Parameter image: 返回获取图片本机的实际路径
    func onShowUrl(_ url : NSURL)
}

typealias imagePicker = (_ imagePickerController:UIImagePickerController)  -> Void

/// document 路径
private let documentPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

/// 拍照的缓存路径
private let imageSavePath = documentPath + "/IPCMImageCaches"

class ImagePickerControllerModule : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate:ImagePickerControllerModuleDelegate?
    
    private var imagePickerController:UIImagePickerController!
    
    // 拍照的图片标识符
    open var identifier = "IPCMImage"
    
    deinit { }
    
    override init() {
        imagePickerController = UIImagePickerController()
        super.init()
        imagePickerController.delegate = self
    }
    
    static let share = ImagePickerControllerModule()
    
    /// 打开相册
    ///
    /// - Parameters:
    ///   - complete: 返回imagePickerController
    ///   - failClosure: 拒绝授权、没有权限会显示错误信息
    open func chooseLocalPhotos(complete:@escaping imagePicker,error failClosure:((String) -> Void)? = nil) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ [weak self](authorizationStatus) in
                guard let strongSelf = self else { return }
                if authorizationStatus == .authorized {
                    strongSelf.imagePickerController.sourceType = .photoLibrary
                    complete(strongSelf.imagePickerController)
                }else {
                    failClosure!("User has explicitly denied this application access to photos data")
                }
            })
        case .authorized:
            imagePickerController.sourceType = .photoLibrary
            complete(imagePickerController)
        default:
            failClosure!("This application is not authorized to access photo data")
            break
        }
    }
    
    /// 打开相机,缓存的是`JPEG`格式的原图
    ///
    /// - Parameters:
    ///   - complete: imagePickerController
    ///   - failClosure: 拒绝授权、没有权限会显示错误信息
    open func takePhotos(complete:@escaping imagePicker,error failClosure:((String) -> Void)? = nil) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            failClosure!("The camera is not available ")
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .notDetermined: // 未授权
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [weak self] (granted) in
                if granted { // 授权成功
                    guard let strongSelf = self else { return }
                    strongSelf.imagePickerController.sourceType = .camera
                    complete(strongSelf.imagePickerController)
                }else { // 拒绝授权
                    failClosure!("User has explicitly denied this application access to camera")
                }
            })
        case .authorized:
            imagePickerController.sourceType = .camera
            complete(imagePickerController)
        default:
            failClosure!("This application is not authorized to access camera")
            break
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        /// xcode报错： [Generic] Creating an image format with an unknown type is an error
        /// 占时无解决办法
        /// 没任何影响
        
        if delegate != nil {
            if info[UIImagePickerControllerReferenceURL] != nil {
                // 相册
                let url = info[UIImagePickerControllerReferenceURL] as! NSURL
                
                let result = PHAsset.fetchAssets(withALAssetURLs: [url as URL], options: nil)
                let asset = result.firstObject!
                
                PHImageManager.default().requestImageData(for: asset, options: nil, resultHandler: { [weak self](imageData, dataUTI, orientation, info) in
                    //获取实际路径
                    let imageNSURL: NSURL = info!["PHImageFileURLKey"] as! NSURL
                    self?.delegate!.onShowUrl(imageNSURL)
                })
            }else {
                // 相机
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                saveImageToCaches(image, identifier : identifier)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 保存图片
    private func saveImageToCaches(_ image:UIImage, identifier:String) {
        let imageData = UIImageJPEGRepresentation(image,1.0)
        if imageData != nil {
            // 创建文件夹
            if !FileManager.default.fileExists(atPath: imageSavePath) {
                do {
                    try FileManager.default.createDirectory(atPath: imageSavePath, withIntermediateDirectories: true, attributes: nil)
                }catch {
                    return
                }
            }
            
            let imagePath = imageSavePath + "/" + identifier
            
            // 保存图片
            let saveSuccess = FileManager.default.createFile(atPath: imagePath, contents: imageData, attributes: nil)
            
            if saveSuccess,delegate != nil {
                delegate!.onShowUrl(NSURL(string: imagePath)!)
            }
        }
    }
    
    // MARK: - 清空所以缓存图片
    /// 清空所以缓存图片
    open func removeAllCaches() {
        if FileManager.default.fileExists(atPath: imageSavePath) {
            do {
                try FileManager.default.removeItem(atPath: imageSavePath)
                
            }catch {
                debugPrint("\(self) remove pictures for path:\(imageSavePath) failure")
                return
            }
        }
    }
}
