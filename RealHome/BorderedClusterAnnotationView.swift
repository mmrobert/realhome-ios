//
//  BorderedClusterAnnotationView.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-11.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import MapKit
import Cluster

class BorderedClusterAnnotationView: ClusterAnnotationView {

    let borderColor: UIColor
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, style: ClusterAnnotationStyle, borderColor: UIColor) {
        self.borderColor = borderColor
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, style: style)
    }
    
    override func configure() {
        super.configure()
        
        switch style {
        case .image:
            layer.borderWidth = 0
        case .color:
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 2
        }
    }
}
