//
//  FavoritesCommercialTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-04.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol DeleteCommercialFavorites: class {
    func toDeleteCommFavorite(_ cellView: FavoritesCommercialTableCell) -> Void
}

class FavoritesCommercialTableCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteCross: UIImageView!
    @IBOutlet weak var saleRentLabel: UILabel!
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var listingIDLabel: UILabel!
    @IBOutlet weak var listingIDValueLabel: UILabel!
    @IBOutlet weak var propertyTypeLabel: UILabel!
    @IBOutlet weak var propertyValueLabel: UILabel!
    
    public weak var deleteFavoritesDelegate: DeleteCommercialFavorites?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
        
        let crossTap = UITapGestureRecognizer(target: self, action: #selector(FavoritesCommercialTableCell.crossTapped(regognizer:)))
        self.deleteCross.isUserInteractionEnabled = true
        self.deleteCross.addGestureRecognizer(crossTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setCaptionsLabel() {
        self.listingIDLabel.text = LanguageProperty.listingIDStr
        self.propertyTypeLabel.text = LanguageProperty.propertyTypeStr
    }

    @objc fileprivate func crossTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.deleteFavoritesDelegate {
            delegate.toDeleteCommFavorite(self)
        }
    }
}
