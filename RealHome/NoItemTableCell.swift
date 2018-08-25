//
//  NoItemTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-01.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit

class NoItemTableCell: UITableViewCell {

    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var noItemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerV.layer.cornerRadius = 10.0
        self.containerV.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
