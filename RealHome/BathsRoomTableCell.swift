//
//  BathsRoomTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-18.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import NHRangeSlider

protocol BathsRoomChangeSearch: class {
    func toChangeBathsRoom(_ cellView: BathsRoomTableCell, minRooms: Int, maxRooms: Int) -> Void
}

class BathsRoomTableCell: UITableViewCell, NHRangeSliderViewDelegate {
    
    @IBOutlet weak var bathsRoomLabel: UILabel!
    @IBOutlet weak var rangeSlider: NHRangeSliderView!
    
    fileprivate var lowVal: Double = 1
    fileprivate var upVal: Double = 3
    
    public weak var bathsRoomChoiceDelegate: BathsRoomChangeSearch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.rangeSlider.minimumValue = 0
        self.rangeSlider.maximumValue = 12
        self.rangeSlider.lowerValue = self.lowVal
        self.rangeSlider.upperValue = self.upVal
        self.rangeSlider.stepValue = 1.0
        self.rangeSlider.trackTintColor = UIColor.lightGray
        self.rangeSlider.thumbTintColor = UIColor(red: 252/255, green: 124/255, blue: 52/255, alpha: 1.0)
        //  self.rangeSlider.trackHighlightTintColor = UIColor.brown
        self.rangeSlider.thumbSize = 28
        self.rangeSlider.thumbLabelStyle = .STICKY
        self.rangeSlider.gapBetweenThumbs = 1.0
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
        
        if let delegate = self.bathsRoomChoiceDelegate {
            delegate.toChangeBathsRoom(self, minRooms: Int(self.lowVal), maxRooms: Int(self.upVal))
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
