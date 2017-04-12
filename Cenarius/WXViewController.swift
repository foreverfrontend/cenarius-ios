//
//  WeexController.swift
//  Cenarius
//
//  Created by M on 2017/3/13.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import WeexSDK

public class WXViewController: UIViewController {
    
    public var url: URL?
    private var instance: WXSDKInstance!
    private var weexView: UIView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        render()
    }
    
    deinit {
        instance.destroy()
        print("销毁")
    }
    
    func render() {
        print("创建")
        instance = WXSDKInstance.init()
        instance.viewController = self
        instance.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + 64, width: view.frame.size.width, height: view.frame.size.height - 64)
      
        instance.onCreate = { [weak self] (view) in
            self?.weexView?.removeFromSuperview()
            self?.weexView = view
            self?.view.addSubview((self?.weexView)!)
        }
        
        instance.onFailed = {(error) in
            //process failure
        }
        
        instance.renderFinish = {(view) in
            //process renderFinish
        }
        
        if let url = self.url {
            print("渲染")
            instance.render(with: url, options: ["bundleUrl": url.absoluteString], data: nil)
        } else {
            print("error: render url is nil")
        }
    }
    
    func refreshWeex() {
        render()
    }
}
