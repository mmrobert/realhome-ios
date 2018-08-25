//
//  Extensions.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-11.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func filled(with color: UIColor) -> UIImage {
      // here the size is "self.size", the same as scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let mask = self.cgImage else { return self }
        context.clip(to: rect, mask: mask)
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

