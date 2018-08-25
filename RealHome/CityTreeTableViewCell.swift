//
//  CityTreeTableViewCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-13.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

let level0Color = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
let level1Color = UIColor(red: 209.0/255.0, green: 238.0/255.0, blue: 252.0/255.0, alpha: 1.0)
let level2UpColor = UIColor(red: 224.0/255.0, green: 248.0/255.0, blue: 216.0/255.0, alpha: 1.0)
let colorForSelected = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)

class CityTreeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var spaceAhead: NSLayoutConstraint!
    @IBOutlet weak var updownImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectedBackgroundView? = UIView()
        selectedBackgroundView?.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(withTitle title: String, level : Int) {
        
        self.nameLabel.text = title
        
        let backgroundColor: UIColor
        let nameFont: UIFont
        if level == 0 {
            backgroundColor = level0Color
            nameFont = UIFont.boldSystemFont(ofSize: 20)
            self.updownImg.alpha = 1.0
        } else if level == 1 {
            backgroundColor = level1Color
            nameFont = UIFont.systemFont(ofSize: 17)
            self.updownImg.alpha = 0.0
        } else {
            backgroundColor = level2UpColor
            nameFont = UIFont.systemFont(ofSize: 15)
            self.updownImg.alpha = 0.0
        }
        
        self.backgroundColor = backgroundColor
        self.contentView.backgroundColor = backgroundColor
        self.nameLabel.font = nameFont
        
        let left = 11.0 + 20.0 * CGFloat(level)
        self.spaceAhead.constant = left
    }
}
