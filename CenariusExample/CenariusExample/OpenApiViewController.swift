//
//  OpenApiViewController.swift
//  CenariusExample
//
//  Created by M on 2017/4/10.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius

class OpenApiViewController: UIViewController {

    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var jsonSwitch: UISwitch!
    @IBOutlet weak var signTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OpenApi.setAppKey("APPKEY")
        OpenApi.setAppSecret("APPSECRET")

    }

    @IBAction func sign(_ sender: UIButton) {
        let url = urlTextView.text!
        Log.debug("url: \(url)")
        
        var headers = ["X-Requested-With": "OpenAPIRequest"]
        if jsonSwitch.isOn {
            headers["Content-Type"] = "application/json"
        }
        let parameters = ["pa": "A&A", "c": 0] as [String : Any]
        
        Network.request(url, parameters: parameters, headers: headers)
        
        
        
        let urlSign = OpenApi.sign(url: url, parameters: parameters, headers: headers)
        Log.debug(urlSign)
        signTextView.text = urlSign
    }
    
}
