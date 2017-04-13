//
//  ViewController.swift
//  CenariusExample
//
//  Created by M on 2017/3/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius
import WeexSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func update(_ sender: UIButton) {
        let url = URL(string: "http://172.20.70.80/www")!
        UpdateManager.setServerUrl(url)
        UpdateManager.update { (state, progress) in
            Cenarius.logger.debug(state)
            Cenarius.logger.debug(progress)
        }
    }
    
    @IBAction func weex(_ sender: UIButton) {
        let wxvc = WXViewController()
        wxvc.url = UpdateManager.getCacheUrl().appendingPathComponent("index.js")
//        let wxrcvc = WXRootViewController(rootViewController: wxvc)
//        UIApplication.shared.keyWindow?.rootViewController = wxrcvc
        self.navigationController?.pushViewController(wxvc, animated: true)
    }


}

