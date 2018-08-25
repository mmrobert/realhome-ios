//
//  AlertViewWithApplyVC.swift
//  RealHome
//
//  Created by boqian cheng on 2018-08-05.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit

protocol AlertViewWithApplyDelegate: class {
    func enterBtnTapped(codeStr: String, nickNameStr: String)
    func cancelBtntapped()
}

class AlertViewWithApplyVC: UIViewController {
    
    public var originatedVC: String = ""
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var nickNameTxt: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var enterBtn: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    
    @IBOutlet weak var scrollBottomDistance: NSLayoutConstraint!
    
    public var delegate: AlertViewWithApplyDelegate?
    
    fileprivate var applyCodeNavi: UINavigationController?
    
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
        codeTxt.becomeFirstResponder()
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(AlertViewWithApplyVC.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        dismiss.cancelsTouchesInView = false
        
        noteCenter.addObserver(self, selector: #selector(AlertViewWithApplyVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(AlertViewWithApplyVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        noteCenter.addObserver(self, selector: #selector(AlertViewWithApplyVC.agentCodeApplied(note:)), name: NSNotification.Name(rawValue: "agentcodeapplied"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = LanguageGeneral.enterYourAgentCodeStr
        self.msgLabel.text = LanguageGeneral.toGetCommunicateStr
        self.codeTxt.placeholder = LanguageGeneral.agentCodeStr
        self.nickNameTxt.placeholder = LanguageGeneral.yourNameStr
        self.cancelBtn.setTitle(LanguageGeneral.cancelStr, for: .normal)
        self.enterBtn.setTitle(LanguageGeneral.enterStr, for: .normal)
        self.applyBtn.setTitle(LanguageGeneral.applyForCodeStr, for: .normal)
        self.orLabel.text = LanguageGeneral.orStr
        animateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func dismissKeyboard() {
        //  self.view.endEditing(true)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @objc fileprivate func agentCodeApplied(note: NSNotification) {
        
        if self.originatedVC.count < 1 {
            self.dismiss(animated: true, completion: nil)
        } else if self.originatedVC == "login" {
            self.broadNotify(typeValueStr: "loginApplyCodeNote")
            self.dismiss(animated: true, completion: nil)
        } else if self.originatedVC == "register" {
            self.broadNotify(typeValueStr: "registerApplyCodeNote")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func broadNotify(typeValueStr: String) {
        noteCenter.post(name: NSNotification.Name(rawValue: typeValueStr), object: nil, userInfo: nil)
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
    
    func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        alertView.layer.cornerRadius = 10
        alertView.layer.masksToBounds = true
        
        self.cancelBtn.layer.cornerRadius = 8
        self.cancelBtn.layer.masksToBounds = true
        
        self.enterBtn.layer.cornerRadius = 8
        self.enterBtn.layer.masksToBounds = true
        
        self.applyBtn.layer.cornerRadius = 8
        self.applyBtn.layer.masksToBounds = true
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func enterAction(_ sender: Any) {
        self.view.endEditing(true)
        if let _codeText = self.codeTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines), _codeText.count == 6 {
            let _code: String = codeTxt.text ?? ""
            let _name: String = nickNameTxt.text ?? ""
            self.delegate?.enterBtnTapped(codeStr: _code, nickNameStr: _name)
            self.dismiss(animated: true, completion: nil)
        } else {
            let alertMsg = LanguageGeneral.theCodeMustBeStr
            let okTitle = LanguageGeneral.okStr
            self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyAction(_ sender: Any) {
        self.view.endEditing(true)
        
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        self.applyCodeNavi = storyB.instantiateViewController(withIdentifier: "navVCforapplycode") as? UINavigationController
        
        self.applyCodeNavi?.providesPresentationContextTransitionStyle = true
        self.applyCodeNavi?.definesPresentationContext = true
        self.applyCodeNavi?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.applyCodeNavi?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        let _applyVC = self.applyCodeNavi?.topViewController as? ApplyForAgentCodeVC
        _applyVC?.delegate = self
        if let _navi = self.applyCodeNavi {
            self.present(_navi, animated: true, completion: nil)
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

extension AlertViewWithApplyVC: ApplyForCodeDelegate {
    func dismissThisVC() {
        self.applyCodeNavi?.dismiss(animated: true) { [unowned self] () in
            self.applyCodeNavi = nil
        }
    }
}
