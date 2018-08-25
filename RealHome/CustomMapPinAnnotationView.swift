//
//  CustomMapPinAnnotationView.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-06.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import MapKit

class CustomMapPinAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      //  fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView != nil {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect: CGRect = self.bounds
        var isInside: Bool = rect.contains(point)
        
        if !isInside {
            outLoop: for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside {
                    break outLoop
                }
            }
        }
        return isInside
    }
    
    
    public func setAnnotationLabel(annotationtext: String?) {
        
        let lbl = UILabel(frame: CGRect(x: 4, y: 5, width: 30, height: 25))
        lbl.textAlignment = .center
        lbl.textColor = UIColor.black
        lbl.font = UIFont.systemFont(ofSize: 8)
        lbl.text = annotationtext
        
        self.addSubview(lbl)
    }
    
    public func setCalloutBtn() {
        self.canShowCallout = true
      //  self.image = UIImage(named: "mappin")
        let btn = UIButton(type: .detailDisclosure)
        self.rightCalloutAccessoryView = btn
    }
}
