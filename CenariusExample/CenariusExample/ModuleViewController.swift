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
        
        arrayM = ["Location","openAlbum","openCamera"]
        
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
}
