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

    @IBAction func webView(_ sender: UIButton) {
        let webViewController = WebViewController()
        //webViewController.url = UpdateManager.getCacheUrl().appendingPathComponent("vux/index.html")
        self.navigationController?.pushViewController(webViewController, animated: true)
    }


}

