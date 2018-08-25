//
//  MsgBoxTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-11.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit

class MsgBoxTableCell: UITableViewCell {
    
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.photoImgView.layer.cornerRadius = 25.0
        self.photoImgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
