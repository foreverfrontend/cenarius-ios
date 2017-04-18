//
//  WebViewController.swift
//  CenariusExample
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        
        let params = "{\"id\":123,\"name\":\"二哈\"}".encodeURIComponent()
        let url = URL(string: "cenarius://route/user?params=" + params)!
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            return !Interceptor.perform(url: url, controller: self)
        }
        return true
    }

}
