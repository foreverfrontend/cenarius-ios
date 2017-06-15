//
//  WeexViewController.swift
//  Cenarius
//
//  Created by M on 2017/3/13.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import WeexSDK
import SwiftyJSON

public class WeexViewController: UIViewController, RouteProtocol {
    
    public var url: URL?
    private var instance: WXSDKInstance!
    private var weexView: UIView?
    
    public static func instantiate(params: JSON?) -> UIViewController {
        let controller = WeexViewController()
        if let file = params?["file"].stringValue {
            controller.url = UpdateManager.getCacheUrl(file: file)
        }
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        render()
    }
    
    deinit {
        instance.destroy()
    }
    
    private func render() {
        instance = WXSDKInstance.init()
        instance.viewController = self
        var navBarHeight: CGFloat = 0
        if let nav = navigationController {
            if nav.navigationBar.isHidden == false && nav.isNavigationBarHidden == false {
                navBarHeight = nav.navigationBar.bounds.size.height
            }
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        instance.frame = CGRect(x: 0, y: statusBarHeight + navBarHeight, width: view.frame.size.width, height: view.frame.size.height - statusBarHeight - navBarHeight)
      
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
