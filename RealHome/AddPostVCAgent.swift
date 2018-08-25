//
//  AddPostVCAgent.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-08.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class AddPostVCAgent: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleContent: UITextView!
    @IBOutlet weak var briefingLabel: UILabel!
    @IBOutlet weak var briefingContent: UITextView!
    @IBOutlet weak var webURLLabel: UILabel!
    @IBOutlet weak var webURLContent: UITextView!
    
    @IBOutlet weak var cancelBtnItem: UIBarButtonItem!
    @IBOutlet weak var addBtnItem: UIBarButtonItem!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    var agentGroupID: String?
    
    var myPostRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LanguageGeneral.addAPostStr
        
        self.agentGroupID = CoreDataController.fetchAgentGroups()[0].value(forKeyPath: "groupID") as? String
        
        self.localizedView()
        self.setCancelAddAction()

        // Do any additional setup after loading the view.
        self.titleContent.layer.cornerRadius = 8
        self.titleContent.layer.borderColor = (UIColor.lightGray.withAlphaComponent(0.7)).cgColor
        self.titleContent.layer.borderWidth = 0.6
        self.titleContent.layer.masksToBounds = true
        
        self.briefingContent.layer.cornerRadius = 8
        self.briefingContent.layer.borderColor = (UIColor.lightGray.withAlphaComponent(0.7)).cgColor
        self.briefingContent.layer.borderWidth = 0.6
        self.briefingContent.layer.masksToBounds = true
        
        self.webURLContent.layer.cornerRadius = 8
        self.webURLContent.layer.borderColor = (UIColor.lightGray.withAlphaComponent(0.7)).cgColor
        self.webURLContent.layer.borderWidth = 0.6
        self.webURLContent.layer.masksToBounds = true
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(AddPostVCAgent.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        dismiss.cancelsTouchesInView = false
        
        noteCenter.addObserver(self, selector: #selector(AddPostVCAgent.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(AddPostVCAgent.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        noteCenter.addObserver(self, selector: #selector(AddPostVCAgent.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.title = LanguageGeneral.addAPostStr
        self.localizedView()
    }
    
    @objc fileprivate func dismissKeyboard() {
        //  self.view.endEditing(true)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    fileprivate func localizedView() {

        self.titleLabel.text = LanguageGeneral.titleStr
        self.briefingLabel.text = LanguageGeneral.briefingStr
        self.webURLLabel.text = LanguageGeneral.webUrlStr
        
        self.cancelBtnItem.title = LanguageGeneral.cancelStr
        self.addBtnItem.title = LanguageGeneral.addStr
        
        // self.addBtn.setTitle(LanguageGeneral.addStr, for: .normal)
    }
    
    fileprivate func setCancelAddAction() {
        
        self.cancelBtnItem.target = self
        self.cancelBtnItem.action = #selector(AddPostVCAgent.cancelTapped(_:))
        
        self.addBtnItem.target = self
        self.addBtnItem.action = #selector(AddPostVCAgent.addTapped(_:))
        //   self.addBtn.addTarget(self, action: #selector(AddServiceVCAgent.addTapped(_:)), for: .touchUpInside)
    }
    
    @objc fileprivate func cancelTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func addTapped(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()
        let titleStr = self.titleContent.text ?? ""
        let briefStr = self.briefingContent.text ?? ""
        let webUrlStr = self.webURLContent.text ?? ""
        if titleStr.count > 0 && briefStr.count > 0 && webUrlStr.count > 0 {
            if webUrlStr.range(of: "http://", options: .caseInsensitive) != nil || webUrlStr.range(of: "https://", options: .caseInsensitive) != nil {
                self.createPost()
            } else {
                self.presentAlert(aTitle: LanguageGeneral.errMsgContainsHttpStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr)
            }
        } else {
            self.presentAlert(aTitle: LanguageGeneral.errMsgNeedAllFieldsStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr)
        }
    }
    
    func createPost() {
        
        let aaEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let aaNickName = UserDefaults.standard.object(forKey: uNickName) as? String
        let aaE = aaEmail ?? ""
        let aaN = aaNickName ?? ""
        
        let emailCode = FirebaseNodesCreation.decodeEmail(email: aaE)
        let refPath: String = self.agentGroupID! + "/" + "posts" + "/" + emailCode
        
        myPostRef = FirebaseNodesCreation.getFirDBInstance().reference(withPath: refPath)
        
        if let newPostRef = myPostRef?.childByAutoId() {
            
            let nowStamp = Date().description
            
            let titleStr = self.titleContent.text ?? ""
            let briefStr = self.briefingContent.text ?? ""
            let webUrlStr = self.webURLContent.text ?? ""
            let postH = ["byEmail": aaE,
                         "byName": aaN,
                          "title": titleStr,
                            "introduction": briefStr,
                            "siteURL": webUrlStr,
                            "timeStamp": nowStamp]
            
            newPostRef.setValue(postH)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.presentAlert(aTitle: LanguageGeneral.errMsgTryAgainStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr)
        }
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
        self.scrollViewBottom.constant = offset
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
            //   self?.scrollViewBottom.constant = offset
            self?.view.layoutIfNeeded() ?? ()
            // var currentOffset = self.tableView.contentOffset
            // currentOffset.y = currentOffset.y - 100
            // self.tableView.setContentOffset(currentOffset, animated: false)
            }, completion: nil)
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
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
