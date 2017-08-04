//
//  ModuleViewController.swift
//  CenariusExample
//
//  Created by Devin on 2017/7/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit
import SVProgressHUD

class ModuleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LocationModuleDelegate, ImagePickerControllerModuleDelegate {


    private var arrayM = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        arrayM = ["Location","openAlbum","openCamera","NetworkModule","DeviceInfo","openSystemSetting","callPhone","openWeChat","openQQ","UserDefault"]
        
        let mainTableView = UITableView(frame: view.bounds, style: .plain)
        mainTableView.tableFooterView = UIView()
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(mainTableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayM.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = arrayM[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            openLocation()
        case 1:
            openAlbum()
        case 2:
            openCamera()
        case 3:
            netWorkSatus()
        case 4:
            getDeviceInfo()
        case 5:
            openSystemSetting()
        case 6:
            callPhone()
        case 7:
            openWeChat()
        case 8:
            openQQ()
        case 9:
            userDefault()
        default:
            break
        }
    }

    // MARK: - Location Module
    private func openLocation() {
        SVProgressHUD.show()
        
        let locationModule = LocationModule.share
        locationModule.delegate = self
        locationModule.getLocation(.always)
    }
    
    func onGetLocation(_ location: LocationModuleModel) {
        
        SVProgressHUD.dismiss()
        
        debugPrint("经度:" + String(location.longitude!))
        debugPrint("纬度:" + String(location.latitude!))
        SVProgressHUD.showSuccess(withStatus: "经度:" + String(location.longitude!) + "\n" + "纬度:" + String(location.latitude!))
    }
    
    // MARK: - ImagePickerControllerModule
    private func openAlbum() {
        let module = ImagePickerControllerModule.share
        module.delegate = self
        module.chooseLocalPhotos(complete: { [weak self](imagePickerController) in
            DispatchQueue.main.async {
                self?.present(imagePickerController, animated: true, completion: nil)
            }
        }) { (errorStr) in
            debugPrint("错误信息:" + errorStr)
        }
    }
    
    private func openCamera() {
        let module = ImagePickerControllerModule.share
        module.delegate = self
        module.takePhotos(complete: { [weak self](imagePickerController) in
            DispatchQueue.main.async {
                self?.present(imagePickerController, animated: true, completion: nil)
            }
        }) { (errorStr) in
             debugPrint("错误信息:" + errorStr)
        }
    }
    
    func onShowUrl(_ url: NSURL) {
        SVProgressHUD.showInfo(withStatus: "图片路径：" + url.absoluteString!)
    }
    
    // MARK: - NetworkModule
    func netWorkSatus() {
       let type = NetworkModule.checkNetworkStatus()
        SVProgressHUD.showInfo(withStatus: "当前网络类型:\(type)")
    }
    
    // MARK: - DeviceInfoModule
    func getDeviceInfo() {
        
        SVProgressHUD.showInfo(withStatus: "app版本号: " + DeviceInfoModule.appVerion() + "\n" + "当前系统: " + DeviceInfoModule.systemName() + "\n" + "系统版本号: " + DeviceInfoModule.systemVersion() + "\n" + "设备的惟一标识号: " + "\n" + DeviceInfoModule.uuid() + "\n" + "设备: " + DeviceInfoModule.model() + "\n" + "设备型号: " +  DeviceInfoModule.deviceName())
    }
    
    // MARK: - OpenSystemSettingModule
    func openSystemSetting() {
        OpenSystemSettingModule.openSystemSetting()
        //        OpenSystemSettingModule.openSystemWifi()
        //        OpenSystemSettingModule.openSystemPhotos()
        //        OpenSystemSettingModule.openSystemCamera()
        //        OpenSystemSettingModule.openSystemContacts()
        //        OpenSystemSettingModule.openSystemGeneral()
        //        OpenSystemSettingModule.openSystemPrivacy()
        //        OpenSystemSettingModule.openSystemLocation()
        //        OpenSystemSettingModule.openSystemMobileData()
        //        OpenSystemSettingModule.openSystemNotification()
    }
    
    // MARK: - CommonModule
    func callPhone() {
        CommonModule.callTel("1008611")
    }
    
    func openWeChat() {
        CommonModule.openWeChat("打开了微信")
    }
    
    func openQQ() {
        CommonModule.openQQ("打开了QQ")
    }
    
    func userDefault() {
        let alertC = UIAlertController(title: "UserDefault", message: nil, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { (alertAction) in
            CommonModule.saveUserDefault("UserDefault", forKey: "UserDefault")
            SVProgressHUD.showSuccess(withStatus: "保存成功")
        }
        
        let redAction = UIAlertAction(title: "读取保存信息", style: .default) { (alertAction) in
            
            let saveInfo = CommonModule.getUserDefault("UserDefault")
            
            if saveInfo != nil {
                let saveStr = saveInfo! as! String
                 SVProgressHUD.showSuccess(withStatus: "保存信息:" + saveStr)
            }else {
                SVProgressHUD.showError(withStatus: "为找到key所对应的信息,请先点击保存")
            }
        }
        
        let removeAction = UIAlertAction(title: "删除", style: .destructive) { (alertAction) in
            
            let saveInfo = CommonModule.getUserDefault("UserDefault")
            if saveInfo != nil {
                CommonModule.removeUserDefault("UserDefault")
                 SVProgressHUD.showSuccess(withStatus: "已删除")
            }else {
                SVProgressHUD.showError(withStatus: "为找到key所对应的信息,请先点击保存")
            }
        }
        
        alertC.addAction(saveAction)
        alertC.addAction(redAction)
        alertC.addAction(removeAction)
        
        present(alertC, animated: true, completion: nil)
    }
}
