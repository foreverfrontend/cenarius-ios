//
//  SendMessageModule.swift
//  CenariusExample
//
//  Created by Devin on 2017/8/3.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import MessageUI

class SendMessageModule {
    open static func sendMessage(_ phones:Array<String>,message:String?) {
        
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.recipients = phones
            controller.body = message
        }
        
    }

}
