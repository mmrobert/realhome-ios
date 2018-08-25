//
//  SettingsTabRootVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-27.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD
import Firebase

class SettingsTabRootVC: UITableViewController {

    @IBOutlet weak var signInItemBtn: UIBarButtonItem!
    
// for localized
    @IBOutlet weak var languagelabel: UILabel!
    @IBOutlet weak var languageContentLabel: UILabel!
    @IBOutlet weak var contactUsLabel: UILabel!
    @IBOutlet weak var logOutLabel: UILabel!
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    public weak var agentGroupDelegate: AddAgentGroup?
    
    var userRef: DatabaseReference? // agents or buyers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  self.tableView.estimatedRowHeight = 50.0
      //  self.tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.setUpLogo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.languagelabel.text = LanguageGeneral.languageStr
        self.contactUsLabel.text = LanguageGeneral.contactUsStr
        self.logOutLabel.text = LanguageGeneral.logOutStr
        
        let tempLanguage = UserDefaults.standard.object(forKey: uLanguage)
        
        if let _tempLanguage = tempLanguage as? String {
            self.languageContentLabel.text = _tempLanguage
        } else {
            self.languageContentLabel.text = englishStr
        }
        
        let imgData = UserDefaults.standard.object(forKey: uPhoto) as? Data
        if let _imgData = imgData, let _img = UIImage(data: _imgData) {
            self.userImgView.image = _img
        } else {
            self.userImgView.image = UIImage(named: "userimg")
        }
        
        let nameFirst = UserDefaults.standard.object(forKey: uFirstName) as? String
        if let _nameFirst = nameFirst, (_nameFirst.trimmingCharacters(in: .whitespacesAndNewlines)).count > 0 {
            self.userNameLabel.text = _nameFirst
        } else {
            let nameLast = UserDefaults.standard.object(forKey: uLastName) as? String
            if let _nameLast = nameLast, (_nameLast.trimmingCharacters(in: .whitespacesAndNewlines)).count > 0 {
                self.userNameLabel.text = _nameLast
            } else {
                let nameNick = UserDefaults.standard.object(forKey: uNickName) as? String
                if let _nameNick = nameNick, (_nameNick.trimmingCharacters(in: .whitespacesAndNewlines)).count > 0 {
                    self.userNameLabel.text = _nameNick
                } else {
                    self.userNameLabel.text = LanguageGeneral.nameStr
                }
            }
        }
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let userPassword = UserDefaults.standard.object(forKey: uPassword) as? String
        let userRole: String? = UserDefaults.standard.object(forKey: uRole) as? String
        
        if let em = userEmail, let pa = userPassword, em.count > 1, pa.count > 0 {
            self.logoutCell.isUserInteractionEnabled = true
            self.logoutCell.isHidden = false
        } else {
            self.logoutCell.isUserInteractionEnabled = false
            self.logoutCell.isHidden = true
        }
        
        var agentGroupID: String?
        if let _userRole = userRole, _userRole == "buyer" {
            let idArrH = CoreDataController.fetchAgentGroupsBuyer()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        } else {
            let idArrH = CoreDataController.fetchAgentGroups()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        }
        
        if let em = userEmail, let pa = userPassword, em.count > 1, pa.count > 0 {
            if let _agentGroupID = agentGroupID, _agentGroupID.count > 2 {
                self.signInItemBtn.isEnabled = false
                self.signInItemBtn.tintColor = UIColor.clear
            } else {
                self.signInItemBtn.isEnabled = true
                self.signInItemBtn.tintColor = nil
                
                if let _roleH = userRole, _roleH == "buyer" {
                    self.signInItemBtn.title = LanguageGeneral.contactAgentStr
                } else {
                    self.signInItemBtn.title = LanguageGeneral.connectBuyersStr
                }
            }
        } else {
            self.signInItemBtn.isEnabled = true
            self.signInItemBtn.tintColor = nil
            self.signInItemBtn.title = LanguageGeneral.signInStr
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 10.0
        }
        return 8.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 3) {
            return 10.0
        }
        return 8.0
    }
/*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
*/
    // MARK: - Table view data source
/*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/
/*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
*/
/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
*/
    
    @IBAction func signinAction(_ sender: Any) {
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let userPassword = UserDefaults.standard.object(forKey: uPassword) as? String
        let userRole: String? = UserDefaults.standard.object(forKey: uRole) as? String
        
        var agentGroupID: String?
        if let _userRole = userRole, _userRole == "buyer" {
            let idArrH = CoreDataController.fetchAgentGroupsBuyer()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        } else {
            let idArrH = CoreDataController.fetchAgentGroups()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        }
        
        if let em = userEmail, let pa = userPassword, em.count > 1, pa.count > 0 {
            if let _agentGroupID = agentGroupID, _agentGroupID.count > 2 {
                // left button is disabled and doing nothing
            } else {
                if let _roleH = userRole, _roleH == "buyer" {
                    self.alertWithTextInput(aTitle: LanguageGeneral.enterAgentCodeStr, withMsg: LanguageGeneral.toGetConnectedStr, confirmTitle: LanguageGeneral.enterStr)
                } else {
                    self.enterAndApplyCodeAlert()
                  /*
                    self.alertWithTextInput(aTitle: LanguageGeneral.enterYourAgentCodeStr, withMsg: LanguageGeneral.toGetCommunicateStr, confirmTitle: LanguageGeneral.enterStr)
                  */
                }
            }
        } else {
            let storyB = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "loginNavigator")
            self.present(controller, animated: true, completion: nil)
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
        let cancelAct = UIAlertAction(title: LanguageGeneral.cancelStr, style: .destructive, handler: nil)
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
        customAlert.originatedVC = ""
        self.present(customAlert, animated: true, completion: nil)
    }

    fileprivate func updateAgentCodeServer(theCode: String, theNickname: String) {
        
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        let emailH: String = (UserDefaults.standard.object(forKey: uEmail) as? String)!
        let roleH: String = (UserDefaults.standard.object(forKey: uRole) as? String)!
        
        let parameterH: [String:Any] = ["op": "q24",
                                        "email": emailH,
                                        "role": roleH,
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
                                self.presentAlert(aTitle: LanguageGeneral.errMsgNoSuchCode, withMsg: LanguageGeneral.errMsgYouMaySetLater, confirmTitle: LanguageGeneral.okStr)
                            }
                        } else {
                            self.presentAlert(aTitle: LanguageGeneral.errMsgNoSuchCode, withMsg: LanguageGeneral.errMsgYouMaySetLater, confirmTitle: LanguageGeneral.okStr)
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in update agent code favorite-tab: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in update agent code favorite-tab: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
        
        // the following is full url
        // print(netWorkProvider.endpoint(.residential(paras: parameterH)).urlRequest?.description ?? "net url")
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
        let _emailH: String? = UserDefaults.standard.object(forKey: uEmail) as? String
        let emailH: String = _emailH ?? ""
        let _nameH: String? = UserDefaults.standard.object(forKey: uNickName) as? String
        let nameH: String = _nameH ?? ""
        let _roleH: String? = UserDefaults.standard.object(forKey: uRole) as? String
        let roleH: String = _roleH ?? ""
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
            if let _delegate = self.agentGroupDelegate {
                _delegate.toAddAgentGroup(role: roleH)
            }
        }
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    deinit {
        if let refHH = self.userRef {
            refHH.removeAllObservers()
        }
    }
}

extension SettingsTabRootVC: AlertViewWithApplyDelegate {
    func enterBtnTapped(codeStr: String, nickNameStr: String) {
        self.updateAgentCodeServer(theCode: codeStr, theNickname: nickNameStr)
    }
    
    func cancelBtntapped() {
        
    }
}
