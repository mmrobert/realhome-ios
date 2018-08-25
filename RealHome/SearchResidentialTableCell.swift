//
//  SearchResidentialTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-16.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol SearchResiDelegate: class {
    func toAddResiFavorite(_ cellView: SearchResidentialTableCell) -> Void
}

class SearchResidentialTableCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var bldgType: UILabel!
    @IBOutlet weak var saleOrRentLabel: UILabel!
    @IBOutlet weak var photo1: UIImageView!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var listingIDLabel: UILabel!
    @IBOutlet weak var listingIDValueLabel: UILabel!
    @IBOutlet weak var bedsLabel: UILabel!
    @IBOutlet weak var bedsValueLabel: UILabel!
    @IBOutlet weak var bathsLabel: UILabel!
    @IBOutlet weak var bathsValueLabel: UILabel!
    
    @IBOutlet weak var heartImg: UIImageView!
    
    public weak var searchResiDelegate: SearchResiDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.masksToBounds = true
        
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(SearchResidentialTableCell.heartTapped(regognizer:)))
        self.heartImg.addGestureRecognizer(heartTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setCaptionsLabel() {
        self.listingIDLabel.text = LanguageProperty.listingIDStr
        self.bedsLabel.text = LanguageProperty.bedsStr
        self.bathsLabel.text = LanguageProperty.bathsStr
    }

    @objc fileprivate func heartTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.searchResiDelegate {
            self.heartImg.isUserInteractionEnabled = false
            self.heartImg.image = UIImage(named: "heartfull")
            delegate.toAddResiFavorite(self)
        }
    }
}
