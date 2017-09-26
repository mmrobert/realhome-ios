//
//  ForgotPasswordVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-25.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var resetReminderLabel: UILabel!
    
    @IBOutlet weak var containerEmail: UIView!
    @IBOutlet weak var emailImg: UIImageView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var scrollViewBottomDistance: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.containerEmail.layer.borderWidth = 1
        self.containerEmail.layer.borderColor = UIColor.gray.cgColor
        self.containerEmail.layer.masksToBounds = true
        
        self.emailImg.image?.withRenderingMode(.alwaysTemplate)
        self.emailImg.tintColor = UIColor.red //UIColor(hue: 0.7, saturation: 0.9, brightness: 0.7, alpha: 1.0)
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordVC.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        //  dismiss.cancelsTouchesInView = false
        
        //  self.resetOutlet.layer.cornerRadius = 10
        
        self.emailText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noteCenter.addObserver(self, selector: #selector(ForgotPasswordVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(ForgotPasswordVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        noteCenter.removeObserver(self)
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
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.scrollViewBottomDistance.constant = offset
            
            // var currentOffset = self.tableView.contentOffset
            // currentOffset.y = currentOffset.y - 100
            // self.tableView.setContentOffset(currentOffset, animated: false)
        }, completion: { (finished: Bool) -> Void in
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func resetPasswordAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if let _emailText = self.emailText.text {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            let testResult = emailTest.evaluate(with: _emailText)
            if !testResult {
                let alertMsg = errMsgNotRightEmailFormat
                let okTitle = okStr
                self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
            } else {
                self.connectingServer()
            }
        } else {
            let alertMsg = errMsgProvideEmail
            let okTitle = okStr
            self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
        }
    }
    
    fileprivate func connectingServer() {
        self.toLoginPage()
    }
    
    fileprivate func toLoginPage() {
        let alertMessage = errMsgSentEmailResetPW
        let okTitle = okStr
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let okHandler: Handler = { [unowned self] action in
            self.navigationController?.popViewController(animated: true)
        }
        
        let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        let okAct = UIAlertAction(title: okTitle, style: .default, handler: okHandler)
        alert.addAction(okAct)
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
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
        //   let closeAppAct = UIAlertAction(title: "Close App", style: .default, handler: closeAppHandler)
        //   alert.addAction(closeAppAct)
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        noteCenter.removeObserver(self)
    }
}

extension ForgotPasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailText {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //    self.scrollToCursorForInputView(inputView: textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldStr = textField.text! as NSString
        _ = oldStr.replacingCharacters(in: range, with: string)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // workaround for jumping text bug
        textField.resignFirstResponder()
        textField.layoutIfNeeded()
    }
}

