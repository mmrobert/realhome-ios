//
//  UserImgSettingsTableCell.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-28.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

protocol ChangePhotoSettings: class {
    func toChangePhoto(_ cellView: UserImgSettingsTableCell) -> Void
}

class UserImgSettingsTableCell: UITableViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    
    public weak var changePhotoDelegate: ChangePhotoSettings?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      //  self.userImg.layer.cornerRadius = 40.0
       // self.userImg.layer.borderWidth = 1.0
       // self.userImg.layer.borderColor = UIColor.gray.withAlphaComponent(0.6).cgColor
      //  self.userImg.layer.masksToBounds = true
        
        let imgChangeTap = UITapGestureRecognizer(target: self, action: #selector(UserImgSettingsTableCell.imgTapped(regognizer:)))
        self.userImg.isUserInteractionEnabled = true
        self.userImg.addGestureRecognizer(imgChangeTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc fileprivate func imgTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.changePhotoDelegate {
            delegate.toChangePhoto(self)
        }
    }
}
