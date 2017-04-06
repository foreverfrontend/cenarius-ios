//
//  ViewController.swift
//  CenariusExample
//
//  Created by M on 2017/3/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius

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
    


}

