//
//  LoginVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-25.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var containerEmailPW: UIView!
    @IBOutlet weak var emailImg: UIImageView!
    @IBOutlet weak var pwImg: UIImageView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var pwText: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var viewDismissKB: UIView!
    
    @IBOutlet weak var scrollViewBottomDistance: NSLayoutConstraint!
    
    fileprivate var userRole: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpLogo()

        // Do any additional setup after loading the view.
        self.containerEmailPW.layer.borderWidth = 1
        self.containerEmailPW.layer.borderColor = UIColor.gray.cgColor
        self.containerEmailPW.layer.masksToBounds = true
        
        self.emailImg.image?.withRenderingMode(.alwaysTemplate)
        self.emailImg.tintColor = UIColor(hue: 0.7, saturation: 0.9, brightness: 0.7, alpha: 1.0)
        
        self.pwImg.image?.withRenderingMode(.alwaysTemplate)
        self.pwImg.tintColor = UIColor(hue: 0.7, saturation: 0.9, brightness: 0.7, alpha: 1.0)
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        //  dismiss.cancelsTouchesInView = false
        
        self.emailText.delegate = self
        self.pwText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noteCenter.addObserver(self, selector: #selector(LoginVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(LoginVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    fileprivate func setUpLogo() {
        
        let navController = navigationController
        var bannerHeight: CGFloat = 0
        if let _navController = navController {
            //  let bannerWidth = _navController.navigationBar.frame.size.width
            bannerHeight = _navController.navigationBar.frame.size.height
        }
        
        let reducedHeight = bannerHeight - 22
        
        let logoImage = UIImage(named: "navlogo")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.frame = CGRect(x: 0, y: 0, width: reducedHeight, height: reducedHeight)
        logoImageView.contentMode = .scaleAspectFit
        
        let logoLabel = UILabel()
        logoLabel.text = appName
        logoLabel.font = UIFont.italicSystemFont(ofSize: 18)
        logoLabel.textAlignment = .left
        logoLabel.textColor = UIColor(red: 252/255, green: 124/255, blue: 52/255, alpha: 1.0)
        logoLabel.frame = CGRect(x: reducedHeight + 2, y: 0, width: 98, height: reducedHeight)
        
        let logoView = UIView(frame: CGRect(x: 0, y: 0, width: reducedHeight + 2 + 98, height: reducedHeight))
        logoView.addSubview(logoImageView)
        logoView.addSubview(logoLabel)
        
        let logoItem = UIBarButtonItem(customView: logoView)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = 0
        navigationItem.leftBarButtonItems = [negativeSpacer, logoItem]
        
        // navigationItem.title = "Cheng - 9876889"
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if let _emailText = self.emailText.text, let _pwText = self.pwText.text {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            let testResult = emailTest.evaluate(with: _emailText)
            if !testResult {
                let alertMsg = errMsgNotRightEmailFormat
                let okTitle = okStr
                self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
            } else {
                if _pwText.characters.count < 5 {
                    let alertMsg = errMsgPasswordShort
                    let okTitle = okStr
                    self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
                } else {
                    self.connectingServer()
                }
            }
        } else {
            let alertMsg = errMsgPWEmailEmpty
            let okTitle = okStr
            self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
        }
    }
    
    fileprivate func connectingServer() {
        
        self.toMainPages()
    }
    
    fileprivate func toMainPages() {
        
        self.performSegue(withIdentifier: "loginReturnToTab", sender: self)
    
/*
        if let _userRole = self.userRole {
            
            if _userRole == "buyer" {
                let storyB = UIStoryboard(name: "LoggedIn", bundle: nil)
                let controller = storyB.instantiateViewController(withIdentifier: "loggedInBuyer")
                self.present(controller, animated: true, completion: nil)
            } else {
                let storyB = UIStoryboard(name: "LoggedInAgent", bundle: nil)
                let controller = storyB.instantiateViewController(withIdentifier: "loggedInAgent")
                self.present(controller, animated: true, completion: nil)
            }
        }
*/
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let enterPWHandler: Handler = { [unowned self] action in
        
        }
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert);
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: enterPWHandler)
        alert.addAction(enterPWAct);
        //   let closeAppAct = UIAlertAction(title: "Close App", style: .default, handler: closeAppHandler)
        //   alert.addAction(closeAppAct)
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

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailText || textField == self.pwText) {
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
