//
//  AreaSizeTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-19.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import NHRangeSlider

protocol AreaSizeChangeSearch: class {
    func toChangeAreaSize(_ cellView: AreaSizeTableCell, minArea: Double, maxArea: Double) -> Void
}

class AreaSizeTableCell: UITableViewCell, NHRangeSliderViewDelegate {

    @IBOutlet weak var areaSizeLabel: UILabel!
    @IBOutlet weak var areaUnitLabel: UILabel!
    @IBOutlet weak var rangeSlider: NHRangeSliderView!
    
    fileprivate var lowVal: Double = 10
    fileprivate var upVal: Double = 300000
    
    public weak var areaSizeChoiceDelegate: AreaSizeChangeSearch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.rangeSlider.minimumValue = 1
        self.rangeSlider.maximumValue = 500000
        self.rangeSlider.lowerValue = self.lowVal
        self.rangeSlider.upperValue = self.upVal
        self.rangeSlider.stepValue = 10.0
        self.rangeSlider.trackTintColor = UIColor.lightGray
        self.rangeSlider.thumbTintColor = UIColor(red: 252/255, green: 124/255, blue: 52/255, alpha: 1.0)
        //  self.rangeSlider.trackHighlightTintColor = UIColor.brown
        self.rangeSlider.thumbSize = 28
        self.rangeSlider.thumbLabelStyle = .STICKY
        self.rangeSlider.gapBetweenThumbs = 10.0
        //   self.rangeSlider.lowerLabel?.isHidden = true
        self.rangeSlider.lowerDisplayStringFormat = String(format: "Min: %.0f", self.lowVal)
        self.rangeSlider.upperDisplayStringFormat = String(format: "Max: %.0f", self.upVal)
        self.rangeSlider.sizeToFit()
        
        self.rangeSlider.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func sliderValueChanged(slider: NHRangeSlider?) {
        self.lowVal = (slider?.lowerValue)!
        self.rangeSlider.lowerDisplayStringFormat = String(format: "Min: %.0f", self.lowVal)
        // print(yyyy ?? "cheng oct 18")
        self.upVal = (slider?.upperValue)!
        self.rangeSlider.upperDisplayStringFormat = String(format: "Max: %.0f", self.upVal)
        
        if let delegate = self.areaSizeChoiceDelegate {
            delegate.toChangeAreaSize(self, minArea: self.lowVal, maxArea: self.upVal)
        }
    }
    
    public func setLowerUpperValue(lowerV: Double, upperV: Double) {
        self.lowVal = lowerV
        self.upVal = upperV
        self.rangeSlider.lowerValue = lowerV
        self.rangeSlider.upperValue = upperV
        self.rangeSlider.lowerDisplayStringFormat = String(format: "Min: %.0f", self.lowVal)
        self.rangeSlider.upperDisplayStringFormat = String(format: "Max: %.0f", self.upVal)
    }
}
