//
//  NoFavoritesTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-02.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol SearchFavoritesNoFavorites: class {
    func goBackToSearch(_ sender: UIButton) -> Void
}

class NoFavoritesTableCell: UITableViewCell {

    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var noFavoritesMsgLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    
    public weak var goBackSearchDelegate: SearchFavoritesNoFavorites?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerV.layer.cornerRadius = 10.0
        self.containerV.layer.masksToBounds = true
        self.noFavoritesMsgLabel.text = noSavedFavoritesStr
        self.searchBtn.setTitle(searchStr, for: .normal)
        self.searchBtn.addTarget(self, action: #selector(NoFavoritesTableCell.searchTapped(_:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc fileprivate func searchTapped(_ sender: UIButton) {
        if let delegate = self.goBackSearchDelegate {
            delegate.goBackToSearch(sender)
        }
    }

}
