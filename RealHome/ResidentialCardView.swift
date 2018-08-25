//
//  ResidentialCardView.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-11.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreLocation

protocol ResiCardViewActions: class {
    func toHideCardViewResi() -> Void
    func toAddFavoriteResi(listID: String) -> Void
    func toShowPropDetailResi(listID: String, addressO: String, coor2D: CLLocationCoordinate2D, bldgTypeO: String) -> Void
}

class ResidentialCardView: UIView {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var boundaryView: UIView!
    @IBOutlet weak var deleteCross: UIImageView!
    
    @IBOutlet weak var bldgTypeLabel: UILabel!
    @IBOutlet weak var saleRentLabel: UILabel!
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
    
    var listingID: String?
    var coor2D: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    public weak var resiCardViewDelegate: ResiCardViewActions?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }
    
    func baseInit() {
        let nib = UINib(nibName: "ResidentialCardView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        containerView.frame = self.bounds
        
        self.listingIDLabel.text = LanguageProperty.listingIDStr
        self.bedsLabel.text = LanguageProperty.bedsStr
        self.bathsLabel.text = LanguageProperty.bathsStr
        
        self.boundaryView.layer.cornerRadius = 10
        self.boundaryView.layer.masksToBounds = true
        
        let crossTap = UITapGestureRecognizer(target: self, action: #selector(ResidentialCardView.crossTapped(regognizer:)))
        self.deleteCross.isUserInteractionEnabled = true
        self.deleteCross.addGestureRecognizer(crossTap)
        
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(ResidentialCardView.heartTapped(regognizer:)))
        self.heartImg.addGestureRecognizer(heartTap)
        
        let wholeViewTap = UITapGestureRecognizer(target: self, action: #selector(ResidentialCardView.wholeViewTapped(regognizer:)))
        self.boundaryView.addGestureRecognizer(wholeViewTap)
        
        addSubview(containerView)
        
        noteCenter.addObserver(self, selector: #selector(ResidentialCardView.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }
    
    @objc fileprivate func crossTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.resiCardViewDelegate {
            delegate.toHideCardViewResi()
        }
    }
    
    @objc fileprivate func heartTapped(regognizer: UITapGestureRecognizer) {
        self.disableHeartImg()
        if let delegate = self.resiCardViewDelegate {
            if let _listID = self.listingID {
                delegate.toAddFavoriteResi(listID: _listID)
            }
        }
    }
    
    @objc fileprivate func wholeViewTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.resiCardViewDelegate {
            if let _listID = self.listingID {
                let addH = self.addressLabel.text ?? ""
                let bldgTypeH = self.bldgTypeLabel.text ?? ""
                delegate.toShowPropDetailResi(listID: _listID, addressO: addH, coor2D: self.coor2D, bldgTypeO: bldgTypeH)
            }
        }
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.listingIDLabel.text = LanguageProperty.listingIDStr
        self.bedsLabel.text = LanguageProperty.bedsStr
        self.bathsLabel.text = LanguageProperty.bathsStr
    }
    
    // set the value for labels
    public func setBldgTypeSaleRent(bldgT: String?, saleR: String?) {
        self.bldgTypeLabel.text = bldgT
        self.saleRentLabel.text = saleR
    }
    
    public func setPhoto1(photoURL: String?) {
        if let imgUrlH = photoURL, let _ = URL(string: imgUrlH) {
            Alamofire.request(imgUrlH).responseImage { response in
                if let image = response.result.value {
                    self.photo1.image = image
                }
            }
        }
    }
    
    public func setPriceAddress(price: String?, address: String?, coor2Din: CLLocationCoordinate2D) {
        self.priceLabel.text = price
        self.addressLabel.text = address
        self.coor2D = coor2Din
    }
    
    public func setListIDBedsBaths(listID: String?, beds: String?, baths: String?) {
        self.listingIDValueLabel.text = listID
        self.bedsValueLabel.text = beds
        self.bathsValueLabel.text = baths
        
        self.listingID = listID
    }
    
    public func enableHeartImg() {
        self.heartImg.isUserInteractionEnabled = true
        self.heartImg.image = UIImage(named: "heartempty")
    }
    
    public func disableHeartImg() {
        self.heartImg.image = UIImage(named: "heartfull")
        self.heartImg.isUserInteractionEnabled = false
    }

    deinit {
        noteCenter.removeObserver(self)
    }
}
