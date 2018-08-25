//
//  PriceRangeTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-18.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol PriceChangeSearch: class {
    func toChangePrice(_ cellView: PriceRangeTableCell, _ newtxValue: Double, _ viewTag: Int) -> Void
}

class PriceRangeTableCell: UITableViewCell {
    
    @IBOutlet weak var priceRangeLabel: UILabel!
    @IBOutlet weak var priceUnitLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    @IBOutlet weak var minInput: UITextField!
    @IBOutlet weak var maxInput: UITextField!
    
    fileprivate var lowVal: Double = Double(minPriceInit)
    fileprivate var upVal: Double = Double(maxPriceInit)
    
    public weak var changePriceDelegate: PriceChangeSearch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.minInput.delegate = self
        self.maxInput.delegate = self
        
        self.minInput.tag = 1
        self.maxInput.tag = 2
        
        self.minInput.text = String(format: "%.0f", self.lowVal)
        self.maxInput.text = String(format: "%.0f", self.upVal)
        
        self.setKBToolBar()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setCaptionsLabel() {
        self.priceRangeLabel.text = LanguageProperty.priceRangeStr
        self.priceUnitLabel.text = LanguageProperty.priceUnitStr
        self.minLabel.text = LanguageProperty.minStr + ":"
        self.maxLabel.text = LanguageProperty.maxStr + ":"
    }
    
    fileprivate func setKBToolBar() {
        let width = UIScreen.main.bounds.size.width
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: width, height: 30.0))
        let extraSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(PriceRangeTableCell.donePressed(_:)))
        
        keyboardToolbar.setItems([extraSpace, done], animated: false)
        keyboardToolbar.sizeToFit()
        
        self.minInput.inputAccessoryView = keyboardToolbar
        self.maxInput.inputAccessoryView = keyboardToolbar
    }
  /*
    public func setKBDoneLabel() {
        let kbDone = self.minInput.inputAccessoryView as! UIToolbar
        kbDone.items?[0].title = LanguageGeneral.doneStr
    }
  */  
    @objc fileprivate func donePressed(_ sender: Any) {
        self.minInput.resignFirstResponder()
        self.maxInput.resignFirstResponder()
    }
    
    public func setLowerUpperValue(lowerV: Double, upperV: Double) {
        self.lowVal = lowerV
        self.upVal = upperV
        self.minInput.text = String(format: "%.0f", self.lowVal)
        self.maxInput.text = String(format: "%.0f", self.upVal)
    }
}

extension PriceRangeTableCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.minInput || textField == self.maxInput {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //    self.scrollToCursorForInputView(inputView: textField)
        
        if let delegate = self.changePriceDelegate {
            let valStr = textField.text
            if let _valStr = valStr, _valStr.count > 0 {
                if let dVal = Double(_valStr) {
                    delegate.toChangePrice(self, dVal, textField.tag)
                } else {
                    var iniVal: Double = 0
                    if (textField.tag == 1) {
                        iniVal = lowVal
                    } else {
                        iniVal = upVal
                    }
                    delegate.toChangePrice(self, iniVal, textField.tag)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldStr = textField.text! as NSString
        let newStr = oldStr.replacingCharacters(in: range, with: string)
        
        if let delegate = self.changePriceDelegate {
            if newStr.count > 0 {
                if let dVal = Double(newStr) {
                    delegate.toChangePrice(self, dVal, textField.tag)
                } else {
                    var iniVal: Double = 0
                    if (textField.tag == 1) {
                        iniVal = lowVal
                    } else {
                        iniVal = upVal
                    }
                    delegate.toChangePrice(self, iniVal, textField.tag)
                }
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //  textField.isUserInteractionEnabled = false
        // workaround for jumping text bug
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
}
