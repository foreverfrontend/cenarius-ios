//
//  LocationModule.swift
//  RXSwiftDemo
//
//  Created by Devin on 2017/7/31.
//  Copyright © 2017年 silence. All rights reserved.
//

import UIKit
import CoreLocation

class LocationModuleModel: NSObject {
    
    /// 经度
    var longitude:Double?
    
    /// 纬度
    var latitude:Double?
    
    /// 国家
    var country:String?
    
    /// 省 直辖市
    var administrativeArea:String?
    
    /// 地级市 直辖市区
    var locality:String?
    
    /// 县 区
    var subLocality:String?
    
    /// 街道
    var thoroughfare:String?
    
    /// 子街道
    var subThoroughfare:String?
}

/// 注册定位方式
///
/// - always: 在前台和后台都可以访问位置
/// - whenInUse: 仅在前台访问位置
enum LocationModuleType : Int {
    case always
    case whenInUse
}

protocol LocationModuleDelegate : class {
    
    /// 获取当前定位的位置信息
    ///
    /// - Parameter location: 回调定位数据模型
    func onGetLocation(_ location:LocationModuleModel)
}

class LocationModule: NSObject, CLLocationManagerDelegate {
    
    private lazy var manager:CLLocationManager = {
        var manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.distanceFilter = 100
        return manager
    }()
    
    private let model = LocationModuleModel()
    
    override init() {
        super.init()
    }
    
    static let share = LocationModule()
    
    weak var delegate:LocationModuleDelegate?
    
    // MARK: - open Location
    
    /// 开启定位
    /// 如果已经注册过权限,则无法重新注册,需手动去隐私里面去修改
    ///
    /// - Parameter type: 默认requestWhenInUseAuthorization
    open func getLocation(_ type:LocationModuleType = .whenInUse) {
        if CLLocationManager.locationServicesEnabled() { // 已开启定位功能
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined: // 用户还没有选择这个应用程序
                type == .always ? manager.requestAlwaysAuthorization() : manager.requestWhenInUseAuthorization()
          
            case .authorizedAlways,.authorizedWhenInUse:
                // 开始定位
                openLocation()
            default:
                debugPrint("拒绝定位")
            }
        }
    }
    
    /// 开启定位服务
    private func openLocation() {
        manager.requestLocation()
    }
    
    /// 设置后台模式下获取定位
    /// 默认情况下，与iOS 9.0或更高版本的应用程序为NO
    /// !!! 选择project --> 到 Capabilities  ——>找到Background Modes 将off改成on 并且勾选 Location updates
    func setAllowsBackgroundLocationUpdates () {
        let backgroundModes = Bundle.main.infoDictionary!["UIBackgroundModes"] as? Array<Any>
        
        if backgroundModes != nil , backgroundModes!.count > 0 {
            let allowsBackgroundLocationUpdates = backgroundModes!.contains(where: { (element) -> Bool in
                if element is String {
                    return (element as! String) == "location"
                }
                return false
            })
            
            if allowsBackgroundLocationUpdates {
                manager.allowsBackgroundLocationUpdates = true
            }else {
                debugPrint("warning: you must set UIBackgroundModes")
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            setAllowsBackgroundLocationUpdates()
            openLocation()
        }else if status == .authorizedWhenInUse {
            openLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingHeading()
        
        // 经纬度
        let location = locations.last!
        let coordinate = location.coordinate
        
        model.latitude = coordinate.latitude
        model.longitude = coordinate.longitude
        
        // 根据经纬度反向地理编译出地址信息
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { [weak self](placemarks, error) in
            if  placemarks != nil, placemarks!.count > 0 {
                let placeMark = placemarks!.first
                
                if placeMark != nil {
                    self?.model.country = placeMark!.country
                    self?.model.administrativeArea = placeMark!.administrativeArea
                    self?.model.locality = placeMark!.locality
                    self?.model.subLocality = placeMark!.subLocality
                    self?.model.thoroughfare = placeMark!.thoroughfare
                    self?.model.subThoroughfare = placeMark!.subThoroughfare
                }
            }
            
            if self?.delegate != nil {
                self?.delegate?.onGetLocation((self?.model)!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let nserror = error as NSError
        debugPrint(nserror.domain)
    }
}
