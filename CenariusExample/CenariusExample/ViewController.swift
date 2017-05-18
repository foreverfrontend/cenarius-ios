//
//  ViewController.swift
//  CenariusExample
//
//  Created by M on 2017/3/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius
import NVActivityIndicatorView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func update(_ sender: UIButton) {
        
        let activityData = ActivityData(size: CGSize(width: 120, height: 120), message: nil, messageFont: nil, type: .ballClipRotateMultiple, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        UpdateManager.update { (state, progress) in
            Log.debug(state)
            Log.debug(progress)
            switch state {
            case .UNZIP_WWW:
                NVActivityIndicatorPresenter.sharedInstance.setMessage("unzip \(progress)%")
            case .DOWNLOAD_FILES:
                NVActivityIndicatorPresenter.sharedInstance.setMessage("download \(progress)%")
            case .UPDATE_SUCCESS:
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            case .DOWNLOAD_CONFIG_FILE_ERROR, .DOWNLOAD_FILES_ERROR, .DOWNLOAD_FILES_FILE_ERROR, .UNZIP_WWW_ERROR:
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            default:
                break
            }
        }
    }
    
    @IBAction func weex(_ sender: UIButton) {
        let wxvc = WXViewController()
        wxvc.url = UpdateManager.getCacheUrl().appendingPathComponent("weex/index.js")
//        let wxrcvc = WXRootViewController(rootViewController: wxvc)
//        UIApplication.shared.keyWindow?.rootViewController = wxrcvc
        self.navigationController?.pushViewController(wxvc, animated: true)
    }

    @IBAction func webView(_ sender: UIButton) {
        let webViewController = WebViewController()
        webViewController.url = UpdateManager.getCacheUrl().appendingPathComponent("vux/index.html")
        self.navigationController?.pushViewController(webViewController, animated: true)
    }


}

