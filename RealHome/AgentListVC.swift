//
//  AgentListVC.swift
//  RealHome
//
//  Created by boqian cheng on 2018-07-27.
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

class AgentListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public var catIndex: Int = 1
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAgentBarItem: UIBarButtonItem!
    
    var agentCodeList: [NSManagedObject] = []
    
    var agentCodesArr: [String] = []   // existed on firebase
    var agentsInfo: [String:[String:String]] = [:]
    
    var agentsRefarr: [DatabaseReference] = []
    
    var userRef: DatabaseReference? // agents or buyers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.catIndex == 1 {
            self.title = LanguageGeneral.messages
        } else if self.catIndex == 2 {
            self.title = LanguageGeneral.recommendations
        } else if self.catIndex == 3 {
            self.title = LanguageGeneral.posts
        } else if self.catIndex == 4 {
            self.title = LanguageGeneral.services
        } else {
            self.title = ""
        }
        
        self.addAgentBarItem.target = self
        self.addAgentBarItem.action = #selector(AgentListVC.addAnotherAgentCode(_:))

        // Do any additional setup after loading the view.
        
        noteCenter.addObserver(self, selector: #selector(AgentListVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(AgentListVC.newAgentCodeAdding(note:)), name: NSNotification.Name(rawValue: "newAgentCodeAdded"), object: nil)
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.getAgentCodesArr()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func getAgentCodesArr() {
        
        self.agentCodeList = CoreDataController.fetchAgentGroupsBuyer()
        
        for refHH in self.agentsRefarr {
            refHH.removeAllObservers()
        }
        self.agentCodesArr.removeAll()
        self.agentsInfo.removeAll()
        self.agentsRefarr.removeAll()
        
        for agentII in self.agentCodeList {
            if let agentCodeII = agentII.value(forKeyPath: "groupID") as? String, agentCodeII.count > 2 {
                self.getAgentNameEmail(theAgentCode: agentCodeII)
            }
        }
      /*
         let jjjkk = ["Agent000001", "Agent558855"]
         for agentII in jjjkk {
         self.getAgentNameEmail(theAgentCode: agentII)
         }
      */
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        if self.catIndex == 1 {
            self.title = LanguageGeneral.messages
        } else if self.catIndex == 2 {
            self.title = LanguageGeneral.recommendations
        } else if self.catIndex == 3 {
            self.title = LanguageGeneral.posts
        } else if self.catIndex == 4 {
            self.title = LanguageGeneral.services
        } else {
            self.title = ""
        }
        //  self.tableView.reloadData()
    }
    
    @objc fileprivate func newAgentCodeAdding(note: NSNotification) {
        
        self.getAgentCodesArr()
    }
    
    fileprivate func getAgentNameEmail(theAgentCode: String) {
        let refPath: String = theAgentCode + "/" + "agents"
        let agentRef: DatabaseReference = FirebaseNodesCreation.getFirDBInstance().reference(withPath: refPath)
        
        agentRef.observe(.value, with: { [unowned self] (snapshot) -> Void in
            var agentInfoArrHH: [[String:String]] = []
            for itemSnap in snapshot.children {
                if let _itemSnap = itemSnap as? DataSnapshot {
                    let agentData = _itemSnap.value as? [String : String] ?? [:]
                    if let emailH = agentData["email"] {
                        let nameH = agentData["name"] ?? ""
                        let nicknameH = agentData["nickname"] ?? ""
                        let photoH = agentData["photo"] ?? ""
                        let theAgentInfo = ["code": theAgentCode, "email": emailH, "name": nameH, "nickname": nicknameH, "photo": photoH]
                        agentInfoArrHH.append(theAgentInfo)
                    } else {
                        print("Error! Could not decode agent data in buyer post")
                    }
                }
            }
            if agentInfoArrHH.count > 0 {
                self.agentCodesArr.append(theAgentCode)
                self.agentsInfo[theAgentCode] = agentInfoArrHH[0]
                self.tableView.reloadData()
            }
        })
        self.agentsRefarr.append(agentRef)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.agentCodesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "agenttablecellMsgBox", for: indexPath) as! AgentTableCell
        
        let codeHH = self.agentCodesArr[indexPath.row]
        
        let endIndexH = codeHH.endIndex
        let stIndex = codeHH.startIndex
        let startIndexH = codeHH.index(stIndex, offsetBy: 5, limitedBy: endIndexH)
        let rangeH = startIndexH..<endIndexH
        
        cell.code.text = codeHH[rangeH]
        
        if let agentHH = self.agentsInfo[codeHH] {
            cell.nickName.text = agentHH["nickname"]
            if let photoSH = agentHH["photo"], photoSH.count > 0 {
                if let photoData = HelpFunctions.stringBase64ToPhoto(imgString: photoSH) {
                    cell.photo.image = UIImage(data: photoData)
                } else {
                    cell.photo.image = UIImage(named: "agent")
                }
            } else {
                cell.photo.image = UIImage(named: "agent")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let agentCodeHHH = self.agentCodesArr[indexPath.row]
        
        if self.catIndex == 1 {
            let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "msgVCinBuyer") as! MsgChatBuyer
            controller.agentGroupID = agentCodeHHH
            controller.nickNameIn = self.agentsInfo[agentCodeHHH]?["nickname"]
            if (self.responds(to: #selector(self.show(_:sender:)))) {
                self.show(controller, sender: self)
            } else {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else if self.catIndex == 2 {
            let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "recommendationVCinBuyer") as! RecommendationVCBuyer
            controller.agentGroupID = agentCodeHHH
            controller.nickNameIn = self.agentsInfo[agentCodeHHH]?["nickname"]
            if (self.responds(to: #selector(self.show(_:sender:)))) {
                self.show(controller, sender: self)
            } else {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else if self.catIndex == 3 {
            let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "postVCinBuyer") as! PostVCBuyer
            controller.agentGroupID = agentCodeHHH
            controller.nickNameIn = self.agentsInfo[agentCodeHHH]?["nickname"]
            if (self.responds(to: #selector(self.show(_:sender:)))) {
                self.show(controller, sender: self)
            } else {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else if self.catIndex == 4 {
            let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "serviceVCinBuyer") as! ServiceVCBuyer
            controller.agentGroupID = agentCodeHHH
            controller.nickNameIn = self.agentsInfo[agentCodeHHH]?["nickname"]
            if (self.responds(to: #selector(self.show(_:sender:)))) {
                self.show(controller, sender: self)
            } else {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let codeHH = self.agentCodesArr[indexPath.row]
            self.deleteAgentCode(agentCodeIn: codeHH)
            
            //  tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func deleteAgentCode(agentCodeIn: String) {
        
        self.presentAlertOkCancel(aTitle: LanguageGeneral.deleteStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr, agentCodeIn: agentCodeIn)
    }
    
    func addAnotherAgentCode(_ sender: UIBarButtonItem) {
        self.alertWithTextInput(aTitle: LanguageGeneral.enterAnotherAgentCodeStr, withMsg: LanguageGeneral.toGetConnectedStr, confirmTitle: LanguageGeneral.enterStr)
    }
    
    fileprivate func alertWithTextInput(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let action = UIAlertAction(title: confirmTitle, style: .default) { [unowned self] (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let _code: String = textField.text ?? ""
            self.updateAgentCodeServer(theCode: _code)
        }
        let cancelAct = UIAlertAction(title: LanguageGeneral.cancelStr, style: .destructive, handler: nil)
        alert.addTextField { (textField) in
            textField.placeholder = LanguageGeneral.agentCodeStr
            textField.keyboardType = .numberPad
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(cancelAct)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func presentAlertOkCancel(aTitle: String?, withMsg: String?, confirmTitle: String?, agentCodeIn: String) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let okHandler: Handler = {action in
            let _emailH = UserDefaults.standard.object(forKey: uEmail) as? String
            let emailH = _emailH ?? ""
            let emailC = FirebaseNodesCreation.decodeEmail(email: emailH)
            let refPath: String = agentCodeIn + "/" + "buyers"
            let refHH = FirebaseNodesCreation.getFirDBInstance().reference(withPath: refPath)
            let nodeToDelete = FirebaseNodesCreation.getSubNode(parentNode: refHH, node: emailC)
            
            nodeToDelete.removeValue()
            CoreDataController.deleteAgentGroupEntityBuyer(groupID: agentCodeIn)
            self.getAgentCodesArr()
        }
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let okAct = UIAlertAction(title: confirmTitle, style: .default, handler: okHandler)
        let cancelAct = UIAlertAction(title: LanguageGeneral.cancelStr, style: .default, handler: nil)
        alert.addAction(cancelAct)
        alert.addAction(okAct)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func updateAgentCodeServer(theCode: String) {
        
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        let emailH: String = (UserDefaults.standard.object(forKey: uEmail) as? String)!
        let roleH: String = (UserDefaults.standard.object(forKey: uRole) as? String)!
        
        let parameterH: [String:Any] = ["op": "q23",
                                        "email": emailH,
                                        "role": roleH,
                                        "agentcode": theCode]
        
        netWorkProvider.rx.request(.updateAgentCode(paras: parameterH)).subscribe { [unowned self] event in
            progs.hide(animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonDic = try response.mapJSON() as? [String:Any] {
                        if let succ = jsonDic["success"] as? String, succ == "true" {
                            if let _codematch = jsonDic["codematch"] as? String, _codematch == "true" {
                                self.addUserToFir(theCode: theCode)
                            } else {
                                self.presentAlert(aTitle: LanguageGeneral.errMsgNoSuchCode, withMsg: LanguageGeneral.errMsgYouMaySetLater, confirmTitle: LanguageGeneral.okStr)
                            }
                        } else {
                            self.presentAlert(aTitle: LanguageGeneral.errMsgNoSuchCode, withMsg: LanguageGeneral.errMsgYouMaySetLater, confirmTitle: LanguageGeneral.okStr)
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in update agent code login: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in update agent code login: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let acts = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(acts)
        self.present(alert, animated: true, completion: nil)
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
                    let agentCodeHH: String = "Agent" + theCode
                    self.getAgentNameEmail(theAgentCode: agentCodeHH)
                }
            })
        }
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
        for refHH in self.agentsRefarr {
            refHH.removeAllObservers()
        }
        if let refHH = self.userRef {
            refHH.removeAllObservers()
        }
        noteCenter.removeObserver(self)
    }
}
