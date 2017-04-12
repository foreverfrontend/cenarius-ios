//
//  WXImgLoaderDefaultImpl.swift
//  Cenarius
//
//  Created by M on 2017/4/12.
//  Copyright © 2017年 M. All rights reserved.
//

import Foundation
import WeexSDK
import Kingfisher

public class WXImgLoaderDefaultImpl: NSObject, WXImgLoaderProtocol, WXModuleProtocol {
    
    public func downloadImage(withURL url: String!, imageFrame: CGRect, userInfo options: [AnyHashable : Any]! = [:], completed completedBlock: ((UIImage?, Error?, Bool) -> Void)!) -> WXImageOperationProtocol! {
        return ImageDownloader.default.downloadImage(with: URL(string: url)!, options: nil, progressBlock: nil, completionHandler: { (image, error, url, data) in
            if completedBlock != nil {
                completedBlock(image, error, error == nil)
            }
        }) as? WXImageOperationProtocol
    }

    
    
}
