//
//  ViewController.swift
//  CenariusExample
//
//  Created by M on 2017/3/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius
import SwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .red
    }

    @IBAction func webView(_ sender: UIButton) {
        Route.open(path: "/web", params: JSON(["url": "https://emcs-dev.infinitus.com.cn/h5/www3.0/vux"]), from: self, present: false)
    }


}

