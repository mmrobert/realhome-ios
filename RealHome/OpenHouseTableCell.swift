//
//  OpenHouseTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-19.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol OpenHouseChoiceSearch: class {
    func toChangeOpenHouse(_ cellView: OpenHouseTableCell, openHouse: Bool) -> Void
}

class OpenHouseTableCell: UITableViewCell {

    @IBOutlet weak var openHouseLabel: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    public weak var openHouseChoiceDelegate: OpenHouseChoiceSearch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.switch.addTarget(self, action: #selector(OpenHouseTableCell.stateChanged(switchState:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc fileprivate func stateChanged(switchState: UISwitch) {
        if switchState.isOn {
            if let delegate = self.openHouseChoiceDelegate {
                delegate.toChangeOpenHouse(self, openHouse: true)
            }
        } else {
            if let delegate = self.openHouseChoiceDelegate {
                delegate.toChangeOpenHouse(self, openHouse: false)
            }
        }
    }

}
