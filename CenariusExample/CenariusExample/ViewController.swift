//
//  ViewController.swift
//  CenariusExample
//
//  Created by M on 2017/3/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius
import SVProgressHUD
import Toaster

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .red
    }

    @IBAction func update(_ sender: UIButton) {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.showProgress(0, status: "update")
        
        UpdateManager.update { (state, progress) in
            Log.debug(state)
            Log.debug(progress)
            switch state {
            case .UNZIP_WWW:
                SVProgressHUD.showProgress(Float(progress) / 100, status: "unzip")
            case .DOWNLOAD_FILES:
                SVProgressHUD.showProgress(Float(progress) / 100, status: "download")
            case .UPDATE_SUCCESS:
                SVProgressHUD.showSuccess(withStatus: "success")
            case .DOWNLOAD_CONFIG_FILE_ERROR, .DOWNLOAD_FILES_ERROR, .DOWNLOAD_FILES_FILE_ERROR, .UNZIP_WWW_ERROR:
                SVProgressHUD.showError(withStatus: "error")
            default:
                break
            }
        }
    }
    
    @IBAction func weex(_ sender: UIButton) {
        let wxvc = WeexViewController()
        wxvc.url = UpdateManager.getCacheUrl().appendingPathComponent("weex/product.js")
        self.navigationController?.pushViewController(wxvc, animated: true)
    }

    @IBAction func webView(_ sender: UIButton) {
        let webViewController = WebViewController()
        webViewController.url = UpdateManager.getCacheUrl().appendingPathComponent("vux/index.html")
        self.navigationController?.pushViewController(webViewController, animated: true)
    }


}

