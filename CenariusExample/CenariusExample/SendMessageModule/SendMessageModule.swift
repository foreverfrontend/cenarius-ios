//
//  SendMessageModule.swift
//  CenariusExample
//
//  Created by Devin on 2017/8/3.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import MessageUI

typealias messageController = (_ MFMessageComposeViewController:MFMessageComposeViewController)  -> Void

class SendMessageModule: NSObject, MFMessageComposeViewControllerDelegate {
    
    private let controller:MFMessageComposeViewController!
    
    override init() {
        controller = MFMessageComposeViewController()
        super.init()
        controller.messageComposeDelegate = self
    }
    
    static let share = SendMessageModule()
    
    open func sendMessage(_ phones:Array<String>,message:String?,complete:@escaping messageController) {
        
        if MFMessageComposeViewController.canSendText() {
            controller.recipients = phones
            controller.body = message
            debugPrint(controller)
            complete(controller)
        }else {
            debugPrint("提示信息:该设备不支持短信功能")
        }
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        
        switch result {
        case .cancelled:
            debugPrint("取消")
        case .failed:
            debugPrint("错误")
        case .sent:
            debugPrint("发送")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }

}
