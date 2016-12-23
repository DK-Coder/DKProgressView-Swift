//
//  DKExtension.swift
//  DKProgressView-Swift
//
//  Created by xuli on 2016/12/22.
//  Copyright © 2016年 dk-coder. All rights reserved.
//

import UIKit

extension UIImage {
    
    func changeColorTo(_ color: UIColor) -> UIImage {
        return imageWithTintColor(color, blendMode: .destinationIn)
    }
    
    func imageWithTintColor(_ color: UIColor, blendMode mode: CGBlendMode) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        
        draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        
        let changedColorImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return changedColorImage
    }
}
