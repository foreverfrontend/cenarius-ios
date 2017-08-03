//
//  SendMessageModule.swift
//  CenariusExample
//
//  Created by Devin on 2017/8/3.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import MessageUI

//typealias messageController = (_ MFMessageComposeViewController:MFMessageComposeViewController)  -> Void

class SendMessageModule: NSObject, MFMessageComposeViewControllerDelegate {
    
    static let share = SendMessageModule()
    
    open static func sendMessage(_ phones:Array<String>,message:String?) {
        
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.recipients = phones
            controller.body = message
//            controller.messageComposeDelegate = self
//            UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
        }else {
            debugPrint("提示信息:该设备不支持短信功能")
        }
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

}
