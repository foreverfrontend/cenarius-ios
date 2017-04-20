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
    private var weexHeight: CGFloat!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        weexHeight = view.frame.size.height - 20
        navigationController?.navigationBar.isHidden = true
        
        render()
    }
    
    deinit {
        instance.destroy()
    }
    
    private func render() {
        instance = WXSDKInstance.init()
        instance.viewController = self
        instance.frame = CGRect(x: 0, y: 20, width: view.frame.size.width, height: weexHeight)
      
        instance.onCreate = { [weak self] (view) in
            self?.weexView?.removeFromSuperview()
            self?.weexView = view
            self?.view.addSubview((self?.weexView)!)
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self?.weexView)
        }
        
        instance.onFailed = { (error) in
            Log.error(error)
        }
        
        instance.renderFinish = { (view) in
            
        }
        
        instance.updateFinish = { (view) in
            
        }
        
        if url != nil {
            instance.render(with: url!, options: ["bundleUrl": url!.absoluteString], data: nil)
        } else {
            Log.error("render url is nil")
        }
    }
    
    private func refreshWeex() {
        render()
    }
}
