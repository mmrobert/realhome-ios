//
//  GeneralTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-07.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class GeneralTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
