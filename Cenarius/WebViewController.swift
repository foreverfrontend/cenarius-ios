//
//  WebViewController.swift
//  Cenarius
//
//  Created by M on 2017/4/21.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON

open class WebViewController: UIViewController, UIWebViewDelegate, RouteProtocol {
    
    open var url: URL?
    private let webView = UIWebView()
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        webView.delegate = self
        if url != nil {
            webView.loadRequest(URLRequest(url: url!))
        }
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            return !Interceptor.perform(url: url, controller: self)
        }
        return true
    }
    
    open static func instantiate(params: JSON?) -> UIViewController {
        let controller = self.init()
        let urlString = params?["url"].stringValue
        if urlString != nil {
            controller.url = URL(string: urlString!)
        }
        return controller
    }

}
