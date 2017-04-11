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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        OpenApi.setAppKey("APPKEY")
        OpenApi.setAppSecret("APPSECRET")

        let url = "y.com?a=中文&b=+ +&c=%26&p=z"
//        let url = "y.com?q=c&q=a&q=z"

        Cenarius.logger.debug(url)
        
        let headers = ["X-Requested-With": "OpenAPIRequest"]
//        let headers = ["X-Requested-With": "OpenAPIRequest", "Content-Type": "application/json"]
        let urlSign = OpenApi.sign(url: url, method: .get, parameters: ["p":"b"], headers: headers)
        Cenarius.logger.debug(urlSign)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
