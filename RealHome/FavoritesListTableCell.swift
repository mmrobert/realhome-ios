//
//  FavoritesListTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-02.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol DeleteFavorites: class {
    func toDeleteFavorite(_ cellView: FavoritesListTableCell) -> Void
}

class FavoritesListTableCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
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
    
    public weak var deleteFavoritesDelegate: DeleteFavorites?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
        
        let crossTap = UITapGestureRecognizer(target: self, action: #selector(FavoritesListTableCell.crossTapped(regognizer:)))
        self.deleteCrossImg.isUserInteractionEnabled = true
        self.deleteCrossImg.addGestureRecognizer(crossTap)
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
    
    @objc fileprivate func crossTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.deleteFavoritesDelegate {
            delegate.toDeleteFavorite(self)
        }
    }
}
