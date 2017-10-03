//
//  GenderChoiceTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-29.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import DLRadioButton

protocol GenderChoiceSettings: class {
    func toChangeGender(_ cellView: GenderChoiceTableCell, gender: String) -> Void
}

class GenderChoiceTableCell: UITableViewCell {

    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var containerV: UIView!
    
    @IBOutlet weak var maleBtn: DLRadioButton!
    @IBOutlet weak var femaleBtn: DLRadioButton!
    
    public weak var genderChoiceDelegate: GenderChoiceSettings?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.maleBtn.isMultipleSelectionEnabled = false
      //  self.femaleBtn.isSelected = true
        self.maleBtn.setTitle(maleStr, for: .normal)
        self.femaleBtn.setTitle(femaleStr, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // also for female pressed
    @IBAction func malePressed(_ radioBtn: DLRadioButton) {
       // print(radioBtn.selected()?.title(for: .normal) ?? "ch")
      // let chosed = radioBtn.selected()?.titleLabel?.text
        if let delegate = self.genderChoiceDelegate {
            delegate.toChangeGender(self, gender: "male")
        }
    }
    
    @IBAction func femalePressed(_ radioBtn: DLRadioButton) {
      // let chosed = radioBtn.selected()?.titleLabel?.text
        if let delegate = self.genderChoiceDelegate {
            delegate.toChangeGender(self, gender: "female")
        }
    }

}
