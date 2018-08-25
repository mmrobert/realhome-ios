//
//  BuyerTabRootVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import CoreData
import Alamofire
import Moya
import RxSwift
import Firebase

class BuyerTabRootVC: UIViewController {
    
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var msgLabel: UILabel!
    
    @IBOutlet weak var recommendationView: UIView!
    @IBOutlet weak var recommendationLabel: UILabel!
    
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var serviceView: UIView!
    @IBOutlet weak var serviceLabel: UILabel!
    
    var userRef: DatabaseReference? // agents or buyers
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpLogo()
        
        let toMsgVC = UITapGestureRecognizer(target: self, action: #selector(BuyerTabRootVC.messageVC(tapGestureRecognizer:)))
        self.msgView.isUserInteractionEnabled = true
        self.msgView.addGestureRecognizer(toMsgVC)
        
        let toRecommendationVC = UITapGestureRecognizer(target: self, action: #selector(BuyerTabRootVC.recommendationVC(tapGestureRecognizer:)))
        self.recommendationView.isUserInteractionEnabled = true
        self.recommendationView.addGestureRecognizer(toRecommendationVC)
        
        let toPostVC = UITapGestureRecognizer(target: self, action: #selector(BuyerTabRootVC.postVC(tapGestureRecognizer:)))
        self.postView.isUserInteractionEnabled = true
        self.postView.addGestureRecognizer(toPostVC)
        
        let toServiceVC = UITapGestureRecognizer(target: self, action: #selector(BuyerTabRootVC.serviceVC(tapGestureRecognizer:)))
        self.serviceView.isUserInteractionEnabled = true
        self.serviceView.addGestureRecognizer(toServiceVC)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.msgLabel.text = LanguageGeneral.messages
        self.recommendationLabel.text = LanguageGeneral.recommendations
        self.postLabel.text = LanguageGeneral.posts
        self.serviceLabel.text = LanguageGeneral.services
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
    
    @objc fileprivate func messageVC(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "agentslistBuyerSB") as! AgentListVC
        controller.catIndex = 1
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func recommendationVC(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "agentslistBuyerSB") as! AgentListVC
        controller.catIndex = 2
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func postVC(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "agentslistBuyerSB") as! AgentListVC
        controller.catIndex = 3
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func serviceVC(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "agentslistBuyerSB") as! AgentListVC
        controller.catIndex = 4
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    @IBAction func addMoreAgent(_ sender: Any) {
        self.alertWithTextInput(aTitle: LanguageGeneral.enterAnotherAgentCodeStr, withMsg: LanguageGeneral.toGetConnectedStr, confirmTitle: LanguageGeneral.enterStr)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        
        // the following is full url
        // print(netWorkProvider.endpoint(.residential(paras: parameterH)).urlRequest?.description ?? "net url")
        // print(RealHomeAPI.url(RealHomeAPI.residential(paras: parameterH)))
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
                    self.broadNotify()
                }
            })
        }
    }
    
    fileprivate func broadNotify() {
        noteCenter.post(name: NSNotification.Name(rawValue: "newAgentCodeAdded"), object: nil, userInfo: nil)
    }

    deinit {
        if let refHH = self.userRef {
            refHH.removeAllObservers()
        }
    }
}
