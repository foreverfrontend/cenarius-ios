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
        
        navigationController?.navigationBar.barTintColor = .yellow
        
        OpenApi.set(appKey: "APPKEY", appSecret: "APPSECRET")
    }

    @IBAction func sign(_ sender: UIButton) {
        let url = urlTextView.text!
        Log.debug("url: \(url)")
        
        var headers = [OpenApi.xRequestKey: OpenApi.xRequestValue]
        if jsonSwitch.isOn {
            headers[OpenApi.contentTypeKey] = OpenApi.contentTypeValue
        }
        let parameters = ["pa": "A&A", "c": 0] as [String : Any]
        
        
        let urlSign = OpenApi.sign(url: url, parameters: parameters, headers: headers)
        Log.debug(urlSign)
        signTextView.text = urlSign
    }
    
}
