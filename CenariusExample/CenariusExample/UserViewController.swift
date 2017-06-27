//
//  UserViewController.swift
//  CenariusExample
//
//  Created by M on 2017/4/18.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import Cenarius
import SwiftyJSON

class UserViewController: UIViewController, RouteProtocol {
    
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    var userId: String?
    var userName: String?
    
    
    static func instantiate(params: JSON?) -> UIViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        controller.userId = params?["id"].stringValue
        controller.userName = params?["name"].stringValue
        return controller
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userIdLabel.text = userId
        userNameLabel.text = userName
    }

}
