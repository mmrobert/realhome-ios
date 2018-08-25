//
//  EmailToAgentVC.swift
//  RealHome
//
//  Created by boqian cheng on 2018-07-26.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit

class EmailToAgentVC: UIViewController {
    
    public var listingID: String = ""
    public var individualID: String = ""
    public var brokerNameStr: String = ""
    
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTxt: UITextView!
    @IBOutlet weak var sentBtn: UIButton!
    
    @IBOutlet weak var scrollBottomDistance: NSLayoutConstraint!
    
    var senderName: String = ""
    var senderEmail: String = ""
    var senderPhone: String = ""
    var messageToSend: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteCenter.addObserver(self, selector: #selector(EmailToAgentVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(EmailToAgentVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Do any additional setup after loading the view.
        
        self.messageTxt.layer.cornerRadius = 8
        self.messageTxt.layer.borderColor = (UIColor.lightGray.withAlphaComponent(0.7)).cgColor
        self.messageTxt.layer.borderWidth = 0.6
        self.messageTxt.layer.masksToBounds = true
        
        self.sentBtn.layer.cornerRadius = 8
        self.sentBtn.layer.masksToBounds = true
        
        let userNameF = UserDefaults.standard.object(forKey: uFirstName) as? String
        let userNameL = UserDefaults.standard.object(forKey: uLastName) as? String
        let _nameF = userNameF ?? ""
        let _nameL = userNameL ?? ""
        let userName = _nameF + _nameL
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let userPhone = UserDefaults.standard.object(forKey: uPhone) as? String
        
        self.nameTxt.text = userName
        self.emailTxt.text = userEmail
        self.phoneTxt.text = userPhone
        
        self.messageTxt.text = ""
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(EmailToAgentVC.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        dismiss.cancelsTouchesInView = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Email to: " + self.brokerNameStr
        
        // for localized
        self.sentBtn.setTitle(LanguageGeneral.sendStr, for: .normal)
        self.messageLabel.text = LanguageGeneral.messages
        self.nameTxt.placeholder = LanguageGeneral.yourNameStr
        self.emailTxt.placeholder = LanguageGeneral.yourEmailStr
        self.phoneTxt.placeholder = LanguageGeneral.yourPhoneStr
    }
    
    @objc fileprivate func dismissKeyboard() {
        //  self.view.endEditing(true)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
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
    
    @IBAction func sendAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if let _emailText = self.emailTxt.text, _emailText.count > 2 {
            self.senderEmail = _emailText
            if let _name = self.nameTxt.text, _name.count > 0 {
                self.senderName = _name
                if let _msgH = self.messageTxt.text, _msgH.count > 0 {
                    self.messageToSend = _msgH
                    let _phone = self.phoneTxt.text ?? ""
                    self.senderPhone = _phone
                    self.sendingEmailOnServer()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let alertMsg = LanguageGeneral.errMsgNoMsgToSend
                    let okTitle = LanguageGeneral.okStr
                    self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
                }
            } else {
                let alertMsg = LanguageGeneral.errMsgProvideYourName
                let okTitle = LanguageGeneral.okStr
                self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
            }
        } else {
            let alertMsg = LanguageGeneral.errMsgProvideYourEmail
            let okTitle = LanguageGeneral.okStr
            self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
        }
    }
    
    fileprivate func sendingEmailOnServer() {
        
        let parameterH: [String:Any] = ["op": "q101",
                                        "SenderName": self.senderName,
                                        "SenderEmailAddress": self.senderEmail,
                                        "Message": self.messageToSend,
                                        "ListingId": self.listingID,
                                        "Culture": "en-CA",
                                        "IndividualId": self.individualID]
        
        //  "SenderPhoneNumber": self.senderPhone,
        
        netWorkProvider.rx.request(.creaEmailBroker(paras: parameterH)).subscribe { event in
            switch event {
            case .success(let response):
                debugPrint("Mapping in crea analytical: \(response.debugDescription)")
            case .error(let error):
                debugPrint("Networking Error in crea analytical: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
        do {
            let urlFullPrint = try netWorkProvider.endpoint(.propsFilter(paras: parameterH)).urlRequest().description
            print(urlFullPrint)
        } catch {
            print("wrong url in map search")
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
