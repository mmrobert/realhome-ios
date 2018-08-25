//
//  AlertAddRecommVC.swift
//  RealHome
//
//  Created by boqian cheng on 2018-08-17.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import DLRadioButton

protocol AlertAddRecommDelegate: class {
    func addBtnTapped(listIDStr: String, resiCommStr: String)
    func cancellBtnTapped()
}

class AlertAddRecommVC: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listingIDTxt: UITextField!
    @IBOutlet weak var resiBtn: DLRadioButton!
    @IBOutlet weak var commBtn: DLRadioButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var scrollBottomDistance: NSLayoutConstraint!
    
    public var delegate: AlertAddRecommDelegate?
    
    fileprivate var idTxtEntered: String = ""
    fileprivate var resiCommChosed: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        self.listingIDTxt.becomeFirstResponder()
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(AlertAddRecommVC.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        dismiss.cancelsTouchesInView = false
        
        noteCenter.addObserver(self, selector: #selector(AlertAddRecommVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(AlertAddRecommVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.setupInitValues()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    @objc fileprivate func dismissKeyboard() {
        //  self.view.endEditing(true)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.titleLabel.text = LanguageGeneral.addARecommendationStr
        self.listingIDTxt.placeholder = LanguageProperty.listingIDStr
        self.resiBtn.setTitle(LanguageProperty.residentialStr, for: .normal)
        self.commBtn.setTitle(LanguageProperty.commercialStr, for: .normal)
        self.cancelBtn.setTitle(LanguageGeneral.cancelStr, for: .normal)
        self.addBtn.setTitle(LanguageGeneral.addStr, for: .normal)
        
        animateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // pragma mark - Keyboard notifications
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let offset = keyboardSize.size.height
                //- (self.tabBarController?.tabBar.frame.size.height)!
                self.animateOnKeyboardEvent(notification: notification, withOffset: offset)
            }
        }
        //  self.scrollToCursorForInputView(inputView: self.currentInputView!)
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification){
        self.animateOnKeyboardEvent(notification: notification, withOffset: 0.0)
    }
    
    fileprivate func animateOnKeyboardEvent(notification: NSNotification, withOffset offset: CGFloat) {
        let userInfo = notification.userInfo!
        let duration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int
        let options: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: UInt(curve << 16) | UIViewAnimationOptions.beginFromCurrentState.rawValue)
        
        self.view.layoutIfNeeded()
        self.scrollBottomDistance.constant = offset
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
            //  self.scrollViewBottomDistance.constant = offset
            self?.view.layoutIfNeeded() ?? ()
            // var currentOffset = self.tableView.contentOffset
            // currentOffset.y = currentOffset.y - 100
            // self.tableView.setContentOffset(currentOffset, animated: false)
            }, completion: nil)
    }
    
    func setupInitValues() {
        self.listingIDTxt.text = ""
        self.resiCommChosed = "residential"
        self.resiBtn.isSelected = true
    }
    
    func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        alertView.layer.cornerRadius = 10
        alertView.layer.masksToBounds = true
        
        self.cancelBtn.layer.cornerRadius = 8
        self.cancelBtn.layer.masksToBounds = true
        
        self.addBtn.layer.cornerRadius = 8
        self.addBtn.layer.masksToBounds = true
        
        self.resiBtn.isMultipleSelectionEnabled = false
        self.listingIDTxt.delegate = self
        
        self.resiBtn.addTarget(self, action: #selector(AlertAddRecommVC.resiBtnPressed), for: .touchUpInside)
        self.commBtn.addTarget(self, action: #selector(AlertAddRecommVC.commBtnPressed), for: .touchUpInside)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @objc fileprivate func resiBtnPressed() {
        self.resiCommChosed = "residential"
    }
    
    @objc fileprivate func commBtnPressed() {
        self.resiCommChosed = "commercial"
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.view.endEditing(true)
        self.delegate?.cancellBtnTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if let _listid: String = self.listingIDTxt.text, _listid.count > 1 {
            self.delegate?.addBtnTapped(listIDStr: _listid, resiCommStr: self.resiCommChosed)
            self.dismiss(animated: true, completion: nil)
        } else {
            let alertMsg = "Input Listing ID to Add"
            let okTitle = LanguageGeneral.okStr
            self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
        }
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let acts = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(acts)
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        noteCenter.removeObserver(self)
    }
}

extension AlertAddRecommVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.listingIDTxt {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //    self.scrollToCursorForInputView(inputView: textField)
        
        self.idTxtEntered = textField.text ?? ""
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

