//
//  CommTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-01.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit

@objc protocol CommTableCellDelegate: class {
    @objc optional func toDeleteItemComm(_ cellView: CommTableCell) -> Void
    @objc optional func toAddFavoriteComm(_ cellView: CommTableCell) -> Void
}

class CommTableCell: UITableViewCell {
    
    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var deleteCrossImg: UIImageView!
    @IBOutlet weak var saleRentLabel: UILabel!
    @IBOutlet weak var photoImg: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var listIDLabel: UILabel!
    @IBOutlet weak var listIDValueLabel: UILabel!
    @IBOutlet weak var propTypeLabel: UILabel!
    @IBOutlet weak var propTypeValueLabel: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    
    public weak var commTableCellDelegate: CommTableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerV.layer.cornerRadius = 10.0
        self.containerV.layer.masksToBounds = true
        
        let crossTap = UITapGestureRecognizer(target: self, action: #selector(CommTableCell.crossTapped(regognizer:)))
        self.deleteCrossImg.addGestureRecognizer(crossTap)
        
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(CommTableCell.heartTapped(regognizer:)))
        self.heartImg.addGestureRecognizer(heartTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setCaptionsLabel() {
        self.listIDLabel.text = LanguageProperty.listingIDStr
        self.propTypeLabel.text = LanguageProperty.propertyTypeStr
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
        self.commTableCellDelegate?.toDeleteItemComm?(self)
    }
    
    @objc fileprivate func heartTapped(regognizer: UITapGestureRecognizer) {
        self.heartImg.isUserInteractionEnabled = false
        self.heartImg.image = UIImage(named: "heartfull")
        self.commTableCellDelegate?.toAddFavoriteComm?(self)
    }
}
