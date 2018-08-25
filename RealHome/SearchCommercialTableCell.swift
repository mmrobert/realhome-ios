//
//  SearchCommercialTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-16.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol SearchCommDelegate: class {
    func toAddCommFavorite(_ cellView: SearchCommercialTableCell) -> Void
}

class SearchCommercialTableCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var saleOrRentLabel: UILabel!
    @IBOutlet weak var photo1: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var listingIDLabel: UILabel!
    @IBOutlet weak var listingIDValueLabel: UILabel!
    @IBOutlet weak var propertyTypeLabel: UILabel!
    @IBOutlet weak var propertyTypeValueLabel: UILabel!
    @IBOutlet weak var heartImg: UIImageView!
    
    public weak var searchCommDelegate: SearchCommDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
        
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(SearchCommercialTableCell.heartTapped(regognizer:)))
        self.heartImg.addGestureRecognizer(heartTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func setCaptionsLabel() {
        self.listingIDLabel.text = LanguageProperty.listingIDStr
        self.propertyTypeLabel.text = LanguageProperty.propertyTypeStr
    }
    
    @objc fileprivate func heartTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.searchCommDelegate {
            self.heartImg.isUserInteractionEnabled = false
            self.heartImg.image = UIImage(named: "heartfull")
            delegate.toAddCommFavorite(self)
        }
    }
}
