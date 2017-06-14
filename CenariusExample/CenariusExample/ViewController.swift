//
//  ViewController.swift
//  CenariusExample
//
//  Created by M on 2017/3/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius
import MBProgressHUD
import Toaster

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func update(_ sender: UIButton) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "update"
        
        UpdateManager.update { (state, progress) in
            Log.debug(state)
            Log.debug(progress)
            switch state {
            case .UNZIP_WWW:
                hud.label.text = "unzip"
                hud.progress = Float(progress) / 100
            case .DOWNLOAD_FILES:
                hud.label.text = "download"
                hud.progress = Float(progress) / 100
            case .UPDATE_SUCCESS:
                hud.hide(animated: true)
                Toast(text: "success").show()
            case .DOWNLOAD_CONFIG_FILE_ERROR, .DOWNLOAD_FILES_ERROR, .DOWNLOAD_FILES_FILE_ERROR, .UNZIP_WWW_ERROR:
                hud.hide(animated: true)
                Toast(text: "error").show()
            default:
                break
            }
        }
    }
    
    @IBAction func weex(_ sender: UIButton) {
        let wxvc = WeexViewController()
        wxvc.url = UpdateManager.getCacheUrl().appendingPathComponent("weex/network.js")
        self.navigationController?.pushViewController(wxvc, animated: true)
    }

    @IBAction func webView(_ sender: UIButton) {
        let webViewController = WebViewController()
        webViewController.url = UpdateManager.getCacheUrl().appendingPathComponent("vux/index.html")
        self.navigationController?.pushViewController(webViewController, animated: true)
    }


}

