//
//  RegisterVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-25.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData
import Firebase

class RegisterVC: UIViewController {
    
    public var role: String?
    
    @IBOutlet weak var containerEmailPW: UIView!
    @IBOutlet weak var emailImg: UIImageView!
    @IBOutlet weak var pwImg: UIImageView!
    @IBOutlet weak var pwConfirmImg: UIImageView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var pwText: UITextField!
    @IBOutlet weak var pwConfirmText: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var bySignLabel1: UILabel!
    @IBOutlet weak var bySignLabel2: UILabel!
    @IBOutlet weak var termsBtn: UIButton!

    @IBOutlet weak var scrollViewBottomDistance: NSLayoutConstraint!
    
    var userRef: DatabaseReference? // agents or buyers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteCenter.addObserver(self, selector: #selector(RegisterVC.registerCodeApplied(note:)), name: NSNotification.Name(rawValue: "registerApplyCodeNote"), object: nil)
        
      // set nav title
        self.addNavBarLogo()

        // Do any additional setup after loading the view.
        
        self.containerEmailPW.layer.borderWidth = 1
        self.containerEmailPW.layer.borderColor = UIColor.gray.cgColor
        self.containerEmailPW.layer.masksToBounds = true
        
        self.emailImg.image?.withRenderingMode(.alwaysTemplate)
        self.emailImg.tintColor = UIColor(hue: 0.7, saturation: 0.9, brightness: 0.7, alpha: 1.0)
        
        self.pwImg.image?.withRenderingMode(.alwaysTemplate)
        self.pwImg.tintColor = UIColor(hue: 0.7, saturation: 0.9, brightness: 0.7, alpha: 1.0)
        
        self.pwConfirmImg.image?.withRenderingMode(.alwaysTemplate)
        self.pwConfirmImg.tintColor = UIColor(hue: 0.7, saturation: 0.9, brightness: 0.7, alpha: 1.0)
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(RegisterVC.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        dismiss.cancelsTouchesInView = false
        
        self.emailText.delegate = self
        self.pwText.delegate = self
        self.pwConfirmText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // localized
        self.emailText.placeholder = LanguageGeneral.emailStr
        self.pwText.placeholder = LanguageGeneral.passwordStr
        self.pwConfirmText.placeholder = LanguageGeneral.confirmPWStr
        self.registerBtn.setTitle(LanguageGeneral.registerStr, for: .normal)
        self.bySignLabel1.text = LanguageGeneral.bySigningStr1
        self.bySignLabel2.text = LanguageGeneral.bySigningStr2
        self.termsBtn.setTitle(LanguageGeneral.termsConditionsStr, for: .normal)
        
        noteCenter.addObserver(self, selector: #selector(RegisterVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(RegisterVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        noteCenter.removeObserver(self)
    }
    
    @objc fileprivate func dismissKeyboard() {
        //  self.view.endEditing(true)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @objc fileprivate func registerCodeApplied(note: NSNotification) {
        
        self.performSegue(withIdentifier: "registerReturnToMainTab", sender: self)
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
        self.scrollViewBottomDistance.constant = offset
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
           // self.scrollViewBottomDistance.constant = offset
            self?.view.layoutIfNeeded() ?? ()
            // var currentOffset = self.tableView.contentOffset
            // currentOffset.y = currentOffset.y - 100
            // self.tableView.setContentOffset(currentOffset, animated: false)
        }, completion: nil)
    }
    
    fileprivate func addNavBarLogo() -> Void {
        
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
        
        navigationItem.titleView = logoView
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if let _emailText = self.emailText.text, let _pwText = self.pwText.text, let _pwConfirmText = self.pwConfirmText.text {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            let testResult = emailTest.evaluate(with: _emailText)
            if !testResult {
                let alertMsg = LanguageGeneral.errMsgNotRightEmailFormat
                let okTitle = LanguageGeneral.okStr
                self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
            } else {
                if _pwText.count < 5 {
                    let alertMsg = LanguageGeneral.errMsgPasswordShort
                    let okTitle = LanguageGeneral.okStr
                    self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
                } else {
                    if _pwText != _pwConfirmText {
                        let alertMsg = LanguageGeneral.errMsgPWnotConfirm
                        let okTitle = LanguageGeneral.okStr
                        self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
                    } else {
                        self.connectingServer()
                    }
                }
            }
        } else {
            let alertMsg = LanguageGeneral.errMsgPWEmailEmpty
            let okTitle = LanguageGeneral.okStr
            self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
        }
    }
    
    fileprivate func connectingServer() {
        
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        let emailH: String = self.emailText.text ?? ""
        let pwH: String = self.pwText.text ?? ""
        
        
        let parameterH: [String:Any] = ["op": "q21",
                                        "email": emailH,
                                        "password": pwH,
                                        "role": self.role!]
        
        netWorkProvider.rx.request(.register(paras: parameterH)).subscribe { [unowned self] event in
            progs.hide(animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonDic = try response.mapJSON() as? [String:Any] {
                        if let succ = jsonDic["success"] as? String, succ == "true" {
                            if let _register = jsonDic["register"] as? String, _register == "true" {
                                UserDefaults.standard.set(self.emailText.text, forKey: uEmail)
                                UserDefaults.standard.set(self.pwText.text, forKey: uPassword)
                                UserDefaults.standard.set(self.role, forKey: uRole)
                                UserDefaults.standard.synchronize()
                                
                                self.toMainPages()
                            } else {
                                let retMsg = jsonDic["message"] as? String
                                let _retMsg = retMsg ?? ""
                                self.presentAlert(aTitle: nil, withMsg: _retMsg, confirmTitle: LanguageGeneral.okStr)
                            }
                        } else {
                            self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgTryAgainStr, confirmTitle: LanguageGeneral.okStr)
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in register: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in register: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
    }
    
    fileprivate func toMainPages() {
        
        if let _role = self.role {
            if _role == "buyer" {
                self.alertWithTextInput(aTitle: LanguageGeneral.enterAgentCodeStr, withMsg: LanguageGeneral.toGetConnectedStr, confirmTitle: LanguageGeneral.enterStr)
            } else {
                self.enterAndApplyCodeAlert()
              /*
                self.alertWithTextInput(aTitle: LanguageGeneral.enterYourAgentCodeStr, withMsg: LanguageGeneral.toGetCommunicateStr, confirmTitle: LanguageGeneral.enterStr)
              */
            }
        }
    }
    
    fileprivate func alertWithTextInput(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let action = UIAlertAction(title: confirmTitle, style: .default) { [unowned self] (alertAction) in
            let textField1 = alert.textFields![0] as UITextField
            let _code: String = textField1.text ?? ""
            let textField2 = alert.textFields![1] as UITextField
            var _nickname: String = textField2.text ?? ""
            
            if _nickname.count > 0 {
                
            } else {
                let nickN = UserDefaults.standard.object(forKey: uNickName) as? String
                if let _nickN = nickN, _nickN.count > 0 {
                    _nickname = _nickN
                }
            }
            
            self.updateAgentCodeServer(theCode: _code, theNickname: _nickname)
        }
        let cancelAct = UIAlertAction(title: LanguageGeneral.cancelStr, style: .destructive) { [unowned self] (alertAction) in
            self.performSegue(withIdentifier: "registerReturnToMainTab", sender: self)
        }
        alert.addTextField { (textField) in
            textField.placeholder = LanguageGeneral.agentCodeStr
            textField.keyboardType = .numberPad
            textField.clearButtonMode = .whileEditing
        }
        alert.addTextField { (textField) in
            textField.placeholder = LanguageGeneral.yourNameStr
            textField.keyboardType = .namePhonePad
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(cancelAct)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func enterAndApplyCodeAlert() {
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let customAlert = storyB.instantiateViewController(withIdentifier: "alertVCsb") as! AlertViewWithApplyVC
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        customAlert.originatedVC = "register"
        self.present(customAlert, animated: true, completion: nil)
    }
    
    fileprivate func updateAgentCodeServer(theCode: String, theNickname: String) {
        
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        let emailH: String = (UserDefaults.standard.object(forKey: uEmail) as? String)!
        
        let parameterH: [String:Any] = ["op": "q24",
                                        "email": emailH,
                                        "role": self.role!,
                                        "agentcode": theCode,
                                        "nickname": theNickname]
        
        netWorkProvider.rx.request(.updateAgentCodeNickname(paras: parameterH)).subscribe { [unowned self] event in
            progs.hide(animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonDic = try response.mapJSON() as? [String:Any] {
                        if let succ = jsonDic["success"] as? String, succ == "true" {
                            if let _codematch = jsonDic["codematch"] as? String, _codematch == "true" {
                                UserDefaults.standard.set(theNickname, forKey: uNickName)
                                UserDefaults.standard.synchronize()
                                self.addUserToFir(theCode: theCode)
                            } else {
                                self.presentAlertOkAct(aTitle: LanguageGeneral.errMsgNoSuchCode, withMsg: LanguageGeneral.errMsgYouMaySetLater, confirmTitle: LanguageGeneral.okStr)
                            }
                            //   let medStruct = Medicine(object: medJSON)
                            //   self.medListStruct.append(medStruct)
                            // print("1-21-12pm-price" + (prop["Price"] as! Float).description)
                        } else {
                            self.presentAlertOkAct(aTitle: LanguageGeneral.errMsgNoSuchCode, withMsg: LanguageGeneral.errMsgYouMaySetLater, confirmTitle: LanguageGeneral.okStr)
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in update agent code register: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in update agent code register: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
        
        // the following is full url
        // print(netWorkProvider.endpoint(.residential(paras: parameterH)).urlRequest?.description ?? "net url")
        // print(RealHomeAPI.url(RealHomeAPI.residential(paras: parameterH)))
    }
    
    fileprivate func addUserToFir(theCode: String) {
        let roleH: String = (UserDefaults.standard.object(forKey: uRole) as? String)!
        let agentCodeFir: String = "Agent" + theCode
        if roleH == "buyer" {
            if !(CoreDataController.isAgentGroupExistedBuyer(groupID: agentCodeFir)) {
                let _ = CoreDataController.createAgentGroupEntityBuyer(groupID: agentCodeFir)
            }
            self.checkAndCreate(buyerOrAgent: "buyer", theCode: theCode)
        } else {
            if !(CoreDataController.isAgentGroupExisted(groupID: agentCodeFir)) {
                let _ = CoreDataController.createAgentGroupEntity(groupID: agentCodeFir)
            }
            self.checkAndCreate(buyerOrAgent: "agent", theCode: theCode)
        }
    }
    
    fileprivate func checkAndCreate(buyerOrAgent: String, theCode: String) {
        let emailH: String = (UserDefaults.standard.object(forKey: uEmail) as? String)!
        let nameH: String = (UserDefaults.standard.object(forKey: uNickName) as? String)!
        let refPath: String = "Agent" + theCode + "/" + buyerOrAgent + "s"
        self.userRef = FirebaseNodesCreation.getFirDBInstance().reference(withPath: refPath)
        
        if let refH = self.userRef {
            refH.observe(.value, with: { (snapshot) -> Void in
                var isCreated: Bool = false
                for itemSnap in snapshot.children {
                    if let _itemSnap = itemSnap as? DataSnapshot {
                        let userDataF = _itemSnap.value as? [String : String] ?? [:]
                        if let aaEmail = userDataF["email"] {
                            if aaEmail == emailH {
                                isCreated = true
                            }
                        } else {
                            print("Error! Could not decode user data in buyer")
                        }
                    }
                }
                if !isCreated {
                    let emailC = FirebaseNodesCreation.decodeEmail(email: emailH)
                    let userH = ["email": emailH,
                                 "name": nameH,
                                 "nickname": nameH]
                    let nodeToAdd = FirebaseNodesCreation.getSubNode(parentNode: refH, node: emailC)
                    nodeToAdd.setValue(userH)
                }
            })
            self.performSegue(withIdentifier: "registerReturnToMainTab", sender: self)
        }
    }

    
    fileprivate func presentAlertOkAct(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let acts = UIAlertAction(title: confirmTitle, style: .default) { [unowned self] (alertAction) in
            self.performSegue(withIdentifier: "registerReturnToMainTab", sender: self)
        }
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
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let acts = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(acts)
        self.present(alert, animated: true, completion: nil)
    }

    deinit {
        if let refHH = self.userRef {
            refHH.removeAllObservers()
        }
        noteCenter.removeObserver(self)
    }
}

extension RegisterVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailText || textField == self.pwText || textField == self.pwConfirmText) {
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

extension RegisterVC: AlertViewWithApplyDelegate {
    func enterBtnTapped(codeStr: String, nickNameStr: String) {
        self.updateAgentCodeServer(theCode: codeStr, theNickname: nickNameStr)
    }
    
    func cancelBtntapped() {
        
    }
}
