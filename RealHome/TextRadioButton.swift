//
//  TextRadioButton.swift
//  RealHome
//
//  Created by boqian cheng on 2018-04-29.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import DLRadioButton

protocol TextRadioButtonDelegate: class {
    func toCancel() -> Void
    func toAdd(_ newtxValue: String?, _ newChosedValue: String?) -> Void
}

class TextRadioButton: UIView {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idTextEnter: UITextField!
    @IBOutlet weak var resiBtn: DLRadioButton!
    @IBOutlet weak var commBtn: DLRadioButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    fileprivate var idTxtEntered: String?
    fileprivate var resiCommChosed: String?
    
    public weak var textRadioButtonDelegate: TextRadioButtonDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }
    
    
    func baseInit() {
        let nib = UINib(nibName: "TextRadioButton", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        containerView.frame = self.bounds
        
        self.titleLabel.text = LanguageGeneral.addARecommendationStr
        self.idTextEnter.placeholder = LanguageProperty.listingIDStr
        self.resiBtn.setTitle(LanguageProperty.residentialStr, for: .normal)
        self.commBtn.setTitle(LanguageProperty.commercialStr, for: .normal)
        self.cancelBtn.setTitle(LanguageGeneral.cancelStr, for: .normal)
        self.addBtn.setTitle(LanguageGeneral.addStr, for: .normal)
        
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        
        self.resiBtn.isMultipleSelectionEnabled = false
        self.idTextEnter.delegate = self
        
        self.resiBtn.addTarget(self, action: #selector(TextRadioButton.resiBtnPressed), for: .touchUpInside)
        self.commBtn.addTarget(self, action: #selector(TextRadioButton.commBtnPressed), for: .touchUpInside)
        self.cancelBtn.addTarget(self, action: #selector(TextRadioButton.cancelBtnPressed), for: .touchUpInside)
        self.addBtn.addTarget(self, action: #selector(TextRadioButton.addBtnPressed), for: .touchUpInside)
        
        addSubview(containerView)
        
        noteCenter.addObserver(self, selector: #selector(TextRadioButton.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.titleLabel.text = LanguageGeneral.addARecommendationStr
        self.idTextEnter.placeholder = LanguageProperty.listingIDStr
        self.resiBtn.setTitle(LanguageProperty.residentialStr, for: .normal)
        self.commBtn.setTitle(LanguageProperty.commercialStr, for: .normal)
        self.cancelBtn.setTitle(LanguageGeneral.cancelStr, for: .normal)
        self.addBtn.setTitle(LanguageGeneral.addStr, for: .normal)
    }
    
    @objc fileprivate func resiBtnPressed() {
         self.resiCommChosed = "residential"
    }
    
    @objc fileprivate func commBtnPressed() {
         self.resiCommChosed = "commercial"
    }
    
    @objc fileprivate func cancelBtnPressed() {
        if let delegate = self.textRadioButtonDelegate {
            delegate.toCancel()
        }
    }
    
    @objc fileprivate func addBtnPressed() {
        if let delegate = self.textRadioButtonDelegate {
            delegate.toAdd(self.idTxtEntered, self.resiCommChosed)
        }
    }
    
    public func setupInitValues() {
        self.idTextEnter.text = ""
        self.resiCommChosed = "residential"
        self.resiBtn.isSelected = true
    }
    
    public func enableAllViews() {
        self.idTextEnter.isUserInteractionEnabled = true
        self.resiBtn.isUserInteractionEnabled = true
        self.commBtn.isUserInteractionEnabled = true
        self.cancelBtn.isUserInteractionEnabled = true
        self.addBtn.isUserInteractionEnabled = true
    }
    
    public func disableAllViews() {
        self.idTextEnter.isUserInteractionEnabled = false
        self.resiBtn.isUserInteractionEnabled = false
        self.commBtn.isUserInteractionEnabled = false
        self.cancelBtn.isUserInteractionEnabled = false
        self.addBtn.isUserInteractionEnabled = false
    }

    deinit {
        noteCenter.removeObserver(self)
    }
}

extension TextRadioButton: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.idTextEnter {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //    self.scrollToCursorForInputView(inputView: textField)
        
        self.idTxtEntered = textField.text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldStr = textField.text! as NSString
        let newStr = oldStr.replacingCharacters(in: range, with: string)
        
        self.idTxtEntered = newStr
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //  textField.isUserInteractionEnabled = false
        // workaround for jumping text bug
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
}
