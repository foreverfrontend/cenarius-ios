//
//  DatePickerModule.swift
//  CenariusExample
//
//  Created by Devin on 2017/8/7.
//  Copyright © 2017年 M. All rights reserved.
//

/// 格式为：yyyy-MM-dd HH:mm:ss
/// 参数为空时默认时间为今日时间
/// 0:日期选择 1:时间选择
/// 1, "2015-5-29 09:14:00"
/// 0, "1989-2-2 00:00:00"
/// selectDate:"2016-11-11 21:19:00", MaxDate:"3000-11-11 21:19:00", MinDate:"2016-11-11 21:19:00"

import UIKit

enum datePickerMode {
    case date
    case dateAndTime
}

protocol DatePickerModuleDelegate : class {
    
    /// 选择的时间
    ///
    /// - Parameter dateStr: 返回格式："2015-5-29 09:14:00"
    func dateValueChange(_ dateStr:String)
}

class DatePickerModule : UIView {
    
    private lazy var backgroundView = UIView()
    private lazy var toolBarView = UIView()
    private lazy var finishButton = UIButton(type: .custom)
    private lazy var cancelButton = UIButton(type: .custom)
    private lazy var datePicker = UIDatePicker()
    private var dateString = DatePickerModule.formatter.string(from: Date())
    
    private let screenW = UIScreen.main.bounds.size.width
    private let screenH = UIScreen.main.bounds.size.height
    
    private static let formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    /// 选择时间,代理
    open weak var delegate:DatePickerModuleDelegate?
    
    /// 选择时间,闭包回调
    open var selectDate:((String) -> ())?
    
    /// 当前显示的时间
    ///
    /// 默认当前时间
    open var showDate:String = DatePickerModule.formatter.string(from: Date()) {
        didSet {
            datePicker.date = DatePickerModule.formatter.date(from: showDate)!
        }
    }
    
    /// 最大显示时间
    open var maximumDate:String? {
        didSet {
            if maximumDate != nil {
                datePicker.maximumDate = DatePickerModule.formatter.date(from: maximumDate!)
            }
        }
    }
    
    /// 最小显示时间
    ///
    /// 最小时间默认：`1800-1-1 00:00:00`
    open var minimumDate:String = "1800-1-1 00:00:00" {
        didSet {
            datePicker.minimumDate = DatePickerModule.formatter.date(from: minimumDate)
        }
    }
    
    /// 显示模式,默认显示日期和时间
    open var datePickerMode:datePickerMode = .dateAndTime {
        didSet {
            datePicker.datePickerMode = (datePickerMode == .date) ? .date : .dateAndTime
        }
    }
    
    static let share = DatePickerModule()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: screenW, height: screenH)
        initView()
    }
    
    private func initView() {
        
        // 透明背景层
        addSubview(backgroundView)
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.isUserInteractionEnabled = true
        backgroundView.frame = self.bounds
        let backgroundViewTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundView.addGestureRecognizer(backgroundViewTap)
        
        // toolbar
        addSubview(toolBarView)
        toolBarView.backgroundColor = rgbaColorFromHex(rgb: 0xf1f1f1)
        toolBarView.addSubview(finishButton)
        finishButton.setTitle("完成", for: .normal)
        finishButton.setTitleColor(rgbaColorFromHex(rgb: 0x2D8BFB), for: .normal)
        finishButton.frame = CGRect(x: screenW - 60, y: 0, width: 60, height: 40)
        finishButton.addTarget(self, action: #selector(finishButtonAction), for: .touchUpInside)
        toolBarView.addSubview(cancelButton)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(rgbaColorFromHex(rgb: 0x2D8BFB), for: .normal)
        cancelButton.frame = CGRect(x: screenW - 120, y: 0, width: 60, height: 40)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        // datePicker
        addSubview(datePicker)
        datePicker.locale = Locale(identifier: "zh_CN")
        datePicker.backgroundColor = UIColor.white
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(valueChange), for: .valueChanged)
        datePicker.minimumDate = DatePickerModule.formatter.date(from: minimumDate)
    }
    
    // MARK: - Action
    func valueChange() {
        dateString = DatePickerModule.formatter.string(from: datePicker.date)
    }
    
    @objc private func finishButtonAction() {
        if delegate != nil {
            delegate?.dateValueChange(dateString)
        }
        
        if selectDate != nil {
            selectDate!(dateString)
        }
        
        dismiss()
    }
    
    @objc private func cancelButtonAction() {
        dismiss()
    }
    
    // MARK: - Show
    open func show() {
        
        UIApplication.shared.keyWindow?.addSubview(self)
        
        toolBarView.frame = CGRect(x: 0, y: screenH, width: screenW, height: 40)
        datePicker.frame = CGRect(x: 0, y: toolBarView.frame.maxY, width: screenW, height: screenH/3*1)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.toolBarView.frame = CGRect(x: 0, y: self.screenH/3*2-40, width: self.screenW, height: 40)
            self.datePicker.frame = CGRect(x: 0, y: self.toolBarView.frame.maxY, width: self.screenW, height: self.screenH/3*1)
        }, completion: nil)
    }
    
    // MARK: - Dismiss
    open func dismiss() {
        
        dateString = DatePickerModule.formatter.string(from: Date())
        
        UIView.animate(withDuration: 0.25, animations: {
            self.toolBarView.frame = CGRect(x: 0, y: self.screenH, width: self.screenW, height: 40)
            self.datePicker.frame = CGRect(x: 0, y: self.toolBarView.frame.maxY, width: self.screenW, height: self.screenH/3*1)
        }) { (bool) in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func rgbaColorFromHex(rgb:Int, alpha: CGFloat = 1.0) -> UIColor {
        
        return UIColor(red: ((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(rgb & 0xFF)) / 255.0,
                       alpha: alpha)
    }
}
