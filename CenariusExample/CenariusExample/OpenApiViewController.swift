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

        let url = "y.com?a=中文&b=+ +&c=%26"
        Cenarius.logger.debug(url)
//
//        let urlEncode = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//        Cenarius.logger.debug(urlEncode)
//        
//        let u = URL(string: urlEncode)!
//        Cenarius.logger.debug("u: \(u)")
//        
//        let u2 =  url.removingPercentEncoding
//        Cenarius.logger.debug("u2: \(u2)")
        
        let headers = ["X-Requested-With": "OpenAPIRequest", "Content-Type": "application/json"]
        let urlSign = OpenApi.sign(url: url, method: .get, parameters: ["p":"&"], headers: headers)
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
