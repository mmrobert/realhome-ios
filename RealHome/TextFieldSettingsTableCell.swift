//
//  TextFieldSettingsTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-28.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol ChangeTextSettings: class {
    func toChangeText(_ cellView: TextFieldSettingsTableCell, _ newtxValue: String?, _ viewTag: Int) -> Void
}

class TextFieldSettingsTableCell: UITableViewCell {
    
    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    public weak var changeTextDelegate: ChangeTextSettings?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TextFieldSettingsTableCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textField{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //    self.scrollToCursorForInputView(inputView: textField)
        
        if let delegate = self.changeTextDelegate {
            delegate.toChangeText(self, textField.text, textField.tag)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldStr = textField.text! as NSString
        let newStr = oldStr.replacingCharacters(in: range, with: string)
        
        if let delegate = self.changeTextDelegate {
            delegate.toChangeText(self, newStr, textField.tag)
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
