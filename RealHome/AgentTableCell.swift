//
//  AgentTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2018-07-28.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit

class AgentTableCell: UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var code: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
