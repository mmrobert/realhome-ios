//
//  HelpFunctions.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-30.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox

class HelpFunctions: NSObject {
    
    class public func randomColor() -> UIColor {
        let hue = Double(arc4random() % 256) / 256.0
        let saturation = Double(arc4random() % 128) / 256.0 + 0.4
        let brightness = Double(arc4random() % 128) / 256.0 + 0.7
        
        return UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1.0)
    }
    
    class public func isNumeric(_ checkText: String) -> Bool {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        let number = formatter.number(from: checkText)
        if number != nil {
            return true
        } else {
            return false
        }
    }
    
    static public func playSysSound(filename: String) {
        let ext = "wav"
        
        if let soundUrl = Bundle.main.url(forResource: filename, withExtension: ext) {
            var soundId: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            
            AudioServicesPlaySystemSound(soundId)
        }
    }
    
    class public func compressAndResizeImage(imageIn: UIImage, maxWidth: CGFloat, maxHeight: CGFloat, compressionQuality: CGFloat) -> UIImage? {
        
        var actualHeight: CGFloat = imageIn.size.height
        var actualWidth: CGFloat = imageIn.size.width
        let imgRatio: CGFloat = actualWidth/actualHeight
        let maxRatio: CGFloat = maxWidth/maxHeight
        
        if (actualHeight > maxHeight || actualWidth > maxWidth) {
            if imgRatio < maxRatio {
                // adjust width according to maxHeight
                let reducedRatio: CGFloat = maxHeight/actualHeight
                //  imgRatio = maxHeight/actualHeight
                actualWidth = reducedRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                // adjust width according to maxWidth
                let reducedRatio2: CGFloat = maxWidth/actualWidth
                // imgRatio = maxWidth/actualWidth
                actualHeight = reducedRatio2 * actualHeight
                actualWidth = maxWidth
            } else {
                actualWidth = maxWidth
                actualHeight = maxHeight
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        imageIn.draw(in: rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        var imgData: Data?
        if let _img = img {
            imgData = UIImageJPEGRepresentation(_img, compressionQuality)
           // print(imgData?.count ?? "no image data")
        }
        UIGraphicsEndImageContext()
        if let _imgData = imgData {
            return UIImage(data: _imgData)
        } else {
            return nil
        }
    }
    
    static public func photoToStringBase64(imgData: Data) -> String {
        
        let photoStr = imgData.base64EncodedString(options: .lineLength64Characters)
        return photoStr
    }
    
    static public func stringBase64ToPhoto(imgString: String) -> Data? {
        
        let photoData = Data(base64Encoded: imgString, options: .ignoreUnknownCharacters)
        return photoData
    }
    
 // the returned height "is not right" if including "emoji", but simple
    static public func heightForText(text: String, constraintedWidth: CGFloat, font: UIFont) -> CGFloat {
        
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: constraintedWidth, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = text
        label.font = font
        label.sizeToFit()
        
        return label.frame.height
    }
    
 // the returned height "is right" if including "emoji"
    static public func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        let attributes = [NSFontAttributeName: font]
        let attString = NSAttributedString(string: string, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attString)
        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: 0), nil, CGSize(width: width, height: .greatestFiniteMagnitude), nil)
    }
    
}
