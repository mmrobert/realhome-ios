//
//  CommercialCardView.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-20.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreLocation

protocol CommCardViewActions: class {
    func toHideCardViewComm() -> Void
    func toAddFavoriteComm(listID: String) -> Void
    func toShowPropDetailComm(listID: String, addressO: String, coor2D: CLLocationCoordinate2D, busiType: String) -> Void
}

class CommercialCardView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var boundaryView: UIView!
    
    @IBOutlet weak var deleteCross: UIImageView!
    
    @IBOutlet weak var saleRentLabel: UILabel!
    @IBOutlet weak var photo1: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var listingIDLabel: UILabel!
    @IBOutlet weak var listingIDValueLabel: UILabel!
    @IBOutlet weak var propTypeLabel: UILabel!
    @IBOutlet weak var propTypeValueLabel: UILabel!
    
    @IBOutlet weak var heartImg: UIImageView!
    
    var listingID: String?
    var coor2D: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    public weak var commCardViewDelegate: CommCardViewActions?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }
    
    func baseInit() {
        let nib = UINib(nibName: "CommercialCardView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        containerView.frame = self.bounds
        
        self.listingIDLabel.text = LanguageProperty.listingIDStr
        self.propTypeLabel.text = LanguageProperty.propertyTypeStr
        
        self.boundaryView.layer.cornerRadius = 10
        self.boundaryView.layer.masksToBounds = true
        
        let crossTap = UITapGestureRecognizer(target: self, action: #selector(CommercialCardView.crossTapped(regognizer:)))
        self.deleteCross.isUserInteractionEnabled = true
        self.deleteCross.addGestureRecognizer(crossTap)
        
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(CommercialCardView.heartTapped(regognizer:)))
        self.heartImg.addGestureRecognizer(heartTap)
        
        let wholeViewTap = UITapGestureRecognizer(target: self, action: #selector(CommercialCardView.wholeViewTapped(regognizer:)))
        self.boundaryView.addGestureRecognizer(wholeViewTap)
        
        addSubview(containerView)
        
        noteCenter.addObserver(self, selector: #selector(CommercialCardView.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }
    
    @objc fileprivate func crossTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.commCardViewDelegate {
            delegate.toHideCardViewComm()
        }
    }
    
    @objc fileprivate func heartTapped(regognizer: UITapGestureRecognizer) {
        self.disableHeartImg()
        if let delegate = self.commCardViewDelegate {
            if let _listID = self.listingID {
                delegate.toAddFavoriteComm(listID: _listID)
            }
        }
    }
    
    @objc fileprivate func wholeViewTapped(regognizer: UITapGestureRecognizer) {
        if let delegate = self.commCardViewDelegate {
            if let _listID = self.listingID {
                let addH = self.addressLabel.text ?? ""
                let buType = self.propTypeValueLabel.text ?? ""
                delegate.toShowPropDetailComm(listID: _listID, addressO: addH, coor2D: self.coor2D, busiType: buType)
            }
        }
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.listingIDLabel.text = LanguageProperty.listingIDStr
        self.propTypeLabel.text = LanguageProperty.propertyTypeStr
    }

    // set the value for labels
    public func setSaleRent(saleR: String?) {
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
    
    public func setListIDProp(listID: String?, prop: String?) {
        self.listingIDValueLabel.text = listID
        self.propTypeValueLabel.text = prop
        
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
