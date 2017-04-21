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

public class WebViewController: UIViewController, UIWebViewDelegate, RouteProtocol {
    
    public var url: URL?
    private let webView = UIWebView()
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        webView.delegate = self
        if url != nil {
            webView.loadRequest(URLRequest(url: url!))
        }
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            return !Interceptor.perform(url: url, controller: self)
        }
        return true
    }
    
    public static func instantiate(params: JSON?) -> UIViewController {
        let controller = WebViewController()
        let urlString = params?["url"].stringValue
        if urlString != nil {
            controller.url = URL(string: urlString!)
        }
        return controller
    }

}
