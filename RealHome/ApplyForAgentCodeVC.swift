//
//  ApplyForAgentCodeVC.swift
//  RealHome
//
//  Created by boqian cheng on 2018-08-05.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import CoreData
import Alamofire
import Moya
import RxSwift
import Firebase

protocol ApplyForCodeDelegate: class {
    func dismissThisVC()
}

class ApplyForAgentCodeVC: UIViewController {

    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var codeTxt: UITextField!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTxt: UITextField!
    
    @IBOutlet weak var scrollBottomDistance: NSLayoutConstraint!
    
    public weak var delegate: ApplyForCodeDelegate?
    
    var userRef: DatabaseReference? // agents or buyers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteCenter.addObserver(self, selector: #selector(ApplyForAgentCodeVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(ApplyForAgentCodeVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Do any additional setup after loading the view.
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        self.emailTxt.text = userEmail
        self.emailTxt.isUserInteractionEnabled = false
        
        self.codeTxt.text = ""
        self.nameTxt.text = ""
        
        self.applyBtn.layer.cornerRadius = 8
        self.applyBtn.layer.masksToBounds = true
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(ApplyForAgentCodeVC.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        dismiss.cancelsTouchesInView = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = LanguageGeneral.applyForAgentCodeStr
        
        // for localized
        self.noteLabel.text = LanguageGeneral.theCodeMustBeStr
        self.emailLabel.text = LanguageGeneral.emailStr
        self.codeLabel.text = LanguageGeneral.codeStr
        self.nameLabel.text = LanguageGeneral.nickNameShortStr
        self.applyBtn.setTitle(LanguageGeneral.applyStr, for: .normal)
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
    
    @IBAction func applyAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if let _codeText = self.codeTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines), _codeText.count == 6 {
            let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
            let _userEmail = userEmail ?? ""
            let _nickN = self.nameTxt.text ?? ""
            self.applyTheCodeOnServer(emailIn: _userEmail, codeIn: _codeText, nameIn: _nickN)
        } else {
            let alertMsg = LanguageGeneral.theCodeMustBeStr
            let okTitle = LanguageGeneral.okStr
            self.presentAlert(aTitle: nil, withMsg: alertMsg, confirmTitle: okTitle)
        }
    }
    
    fileprivate func applyTheCodeOnServer(emailIn: String, codeIn: String, nameIn: String) {
        
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        let userRoleH = UserDefaults.standard.object(forKey: uRole) as? String
        let _userRoleH = userRoleH ?? ""
        
        let parameterH: [String:Any] = ["op": "q111",
                                        "email": emailIn,
                                        "agentcode": codeIn,
                                        "nickname": nameIn,
                                        "role": _userRoleH]
        
        netWorkProvider.rx.request(.applyTheCode(paras: parameterH)).subscribe { [unowned self] event in
            progs.hide(animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonDic = try response.mapJSON() as? [String:Any] {
                        if let succ = jsonDic["success"] as? String, succ == "true" {
                            if let _approved = jsonDic["approved"] as? String, _approved == "true" {
                                let alertSS = LanguageGeneral.codeStr + " " + codeIn + " " + LanguageGeneral.isPerfectStr
                                self.presentAlertOkAct(aTitle: alertSS, withMsg: nil, confirmTitle: LanguageGeneral.okStr)
                                UserDefaults.standard.set(nameIn, forKey: uNickName)
                                UserDefaults.standard.synchronize()
                                self.addUserToFir(theCode: codeIn)
                            } else {
                                let alertSS = LanguageGeneral.codeStr + " " + codeIn + " " + LanguageGeneral.hasBeenTakenStr
                                self.presentAlert(aTitle: alertSS, withMsg: nil, confirmTitle: LanguageGeneral.okStr)
                            }
                        } else {
                            self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in apply code: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in apply code: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
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
        let _emailH = UserDefaults.standard.object(forKey: uEmail) as? String
        let emailH = _emailH ?? ""
        let _nameH = UserDefaults.standard.object(forKey: uNickName) as? String
        let nameH = _nameH ?? ""
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
                    let nodeToAdd = FirebaseNodesCreation.getSubNode(parentNode: refH, node: emailC)
                    if let imgDataH = UserDefaults.standard.object(forKey: uPhoto) as? Data {
                        let imgStrH = HelpFunctions.photoToStringBase64(imgData: imgDataH)
                        let userH = ["email": emailH,
                                     "name": nameH,
                                     "nickname": nameH,
                                     "photo": imgStrH]
                        nodeToAdd.setValue(userH)
                    } else {
                        let userH = ["email": emailH,
                                     "name": nameH,
                                     "nickname": nameH]
                        nodeToAdd.setValue(userH)
                    }
                }
            })
        }
    }
    
    @IBAction func finishAction(_ sender: Any) {
        self.view.endEditing(true)
      //  self.broadNotify(newValue: "")
        self.delegate?.dismissThisVC()
    }
    
    fileprivate func broadNotify(newValue: String) {
        noteCenter.post(name: NSNotification.Name(rawValue: "agentcodeapplied"), object: nil, userInfo: nil)
    }
    
    fileprivate func presentAlertOkAct(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let acts = UIAlertAction(title: confirmTitle, style: .default) { [unowned self] (alertAction) in
            self.broadNotify(newValue: "")
            self.delegate?.dismissThisVC()
        }
        alert.addAction(acts)
        self.present(alert, animated: true, completion: nil)
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
