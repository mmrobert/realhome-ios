//
//  SaleRentChooseTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-17.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import DLRadioButton

protocol SaleRentChoiceSearch: class {
    func toChangeSaleRent(_ cellView: SaleRentChooseTableCell, saleOrRent: String) -> Void
}

class SaleRentChooseTableCell: UITableViewCell {

    @IBOutlet weak var forSaleBtn: DLRadioButton!
    @IBOutlet weak var forRentBtn: DLRadioButton!
    
    public weak var saleRentChoiceDelegate: SaleRentChoiceSearch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.forSaleBtn.isMultipleSelectionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func forSaleTap(_ sender: Any) {
        if let delegate = self.saleRentChoiceDelegate {
            delegate.toChangeSaleRent(self, saleOrRent: "for sale")
        }
    }
    
    @IBAction func forRentTap(_ sender: Any) {
        // let chosed = radioBtn.selected()?.titleLabel?.text
        if let delegate = self.saleRentChoiceDelegate {
            delegate.toChangeSaleRent(self, saleOrRent: "for rent")
        }
    }

}
