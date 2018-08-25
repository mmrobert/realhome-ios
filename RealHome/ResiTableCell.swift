//
//  ResiTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-01.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit

@objc protocol ResiTableCellDelegate: class {
    @objc optional func toDeleteItemResi(_ cellView: ResiTableCell) -> Void
    @objc optional func toAddFavoriteResi(_ cellView: ResiTableCell) -> Void
}

class ResiTableCell: UITableViewCell {

    @IBOutlet weak var containerV: UIView!
    
    @IBOutlet weak var deleteCrossImg: UIImageView!
    @IBOutlet weak var bldgTypeLabel: UILabel!
    @IBOutlet weak var saleRentLabel: UILabel!
    @IBOutlet weak var photoImg: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var listIDLabel: UILabel!
    @IBOutlet weak var listIDValueLabel: UILabel!
    @IBOutlet weak var bedRoomLabel: UILabel!
    @IBOutlet weak var bedRoomValueLabel: UILabel!
    @IBOutlet weak var bathRoomLabel: UILabel!
    @IBOutlet weak var bathRoomValueLabel: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    
    public weak var resiTableCellDelegate: ResiTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerV.layer.cornerRadius = 10.0
        self.containerV.layer.masksToBounds = true
        
        let crossTap = UITapGestureRecognizer(target: self, action: #selector(ResiTableCell.crossTapped(regognizer:)))
        self.deleteCrossImg.addGestureRecognizer(crossTap)
        
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(ResiTableCell.heartTapped(regognizer:)))
        self.heartImg.addGestureRecognizer(heartTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setCaptionsLabel() {
        self.listIDLabel.text = LanguageProperty.listingIDStr
        self.bedRoomLabel.text = LanguageProperty.bedsStr
        self.bathRoomLabel.text = LanguageProperty.bathsStr
    }
    
    public func setDeleteCross(enableIt: Bool) {
        if enableIt {
            self.deleteCrossImg.isHidden = false
            self.deleteCrossImg.isUserInteractionEnabled = true
        } else {
            self.deleteCrossImg.isUserInteractionEnabled = false
            self.deleteCrossImg.isHidden = true
        }
    }
    
    public func setHeart(showIt: Bool, withTapAction: Bool) {
        if showIt {
            self.heartImg.isHidden = false
            
            if withTapAction {
                self.heartImg.isUserInteractionEnabled = true
                self.heartImg.image = UIImage(named: "heartempty")
            } else {
                self.heartImg.isUserInteractionEnabled = false
                self.heartImg.image = UIImage(named: "heartfull")
            }
        } else {
            self.heartImg.isUserInteractionEnabled = false
            self.heartImg.isHidden = true
        }
    }
    
    @objc fileprivate func crossTapped(regognizer: UITapGestureRecognizer) {
        self.resiTableCellDelegate?.toDeleteItemResi?(self)
    }
    
    @objc fileprivate func heartTapped(regognizer: UITapGestureRecognizer) {
        self.heartImg.isUserInteractionEnabled = false
        self.heartImg.image = UIImage(named: "heartfull")
        self.resiTableCellDelegate?.toAddFavoriteResi?(self)
    }
}
