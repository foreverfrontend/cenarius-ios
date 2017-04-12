//
//  WXSelectComponent.swift
//  Cenarius
//
//  Created by M on 2017/4/12.
//  Copyright © 2017年 M. All rights reserved.
//

import WeexSDK

public class WXSelectComponent: WXComponent, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
    
    var tap: UITapGestureRecognizer!
    var pickerView: UIPickerView!
    var options: Array<String>?
    var selectIndex = 0
    var disabled = false
    
    public override init(ref: String, type: String, styles: [AnyHashable : Any]?, attributes: [AnyHashable : Any]? = nil, events: [Any]?, weexInstance: WXSDKInstance) {
        super.init(ref: ref, type: type, styles: styles, attributes: attributes, events: events, weexInstance: weexInstance)
        tap = UITapGestureRecognizer.init(target: self, action: #selector(popupPicker))
        tap.delegate = self
        if attributes != nil {
            updateAttributes(attributes!)
        }
        if let styles = styles?[""] {
            // setting style when init
        }
        
        let window = UIApplication.shared.keyWindow
        let windowSize = window?.rootViewController?.view.frame.size
        let pickerViewHeight = 200.0
        pickerView = UIPickerView.init(frame: CGRect(x: 0.0, y: 0.0, width: Double(windowSize!.width), height: pickerViewHeight))
        pickerView.backgroundColor = .red
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    public override func viewDidLoad() {
        pickerView.selectRow(selectIndex, inComponent: 0, animated: true)
        pickerView.showsSelectionIndicator = true
    }
    
    public override func viewWillUnload() {
        
    }
    
    public override func loadView() -> UIView {
        return pickerView
    }
    
    public override func updateAttributes(_ attributes: [AnyHashable : Any] = [:]) {
        if let options = attributes["options"] {
            self.options = (options as! String).components(separatedBy: ",")
        }
        if let selectIndex = attributes["selectIndex"] {
            self.selectIndex = Int(selectIndex as! String)!
        }
        if let disabled = attributes["disabled"] {
            self.disabled = Bool(disabled as! String)!
        }
        pickerView.reloadAllComponents()
    }
    
    public override func updateStyles(_ styles: [AnyHashable : Any]) {
        
    }
    
    // MARK: - action
    @objc private func popupPicker() {
        if disabled {
            return
        }
        self.fireEvent("focus", params: nil)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tap || otherGestureRecognizer == tap {
            return true
        }
//        super.gestureRecognizer
        return true
    }
    
    // MARK: - pickerView delegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options?.count ?? 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return calculatedFrame.size.width
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.fireEvent("change", params: ["index": NSNumber(value: row), "value": options![row]])
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options![row]
    }
}
