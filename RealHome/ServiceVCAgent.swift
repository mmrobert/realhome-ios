//
//  ServiceVCAgent.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-06.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ServiceVCAgent: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var agentGroupRef: DatabaseReference?
    var serviceRef: DatabaseReference?
    
    var serviceDeleteRef: DatabaseReference?
    var serviceDeleteHandle: DatabaseHandle?
    
    var serviceNameDic: [String:[String]] = [:]
    var serviceIntroDic: [String:[String]] = [:]
    var servicePhoneDic: [String:[String]] = [:]
    var servicePhotoDic: [String:[String]] = [:]
    
    var agentGroupID: String?
    
    var agentsArr: [[String:String]] = []
    var agentsArrRef: DatabaseReference?
    var agentsArrHandle: DatabaseHandle?
    
    var agentServiceRef: [String: DatabaseReference] = [:]
    var agentServiceRefHandle: [String: DatabaseHandle] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = LanguageGeneral.services
        
        self.agentGroupID = CoreDataController.fetchAgentGroups()[0].value(forKeyPath: "groupID") as? String
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(ServiceVCAgent.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        let nibService = UINib(nibName: "ServiceTableCell", bundle: nil)
        self.tableView.register(nibService, forCellReuseIdentifier: "ServiceTableCellAgent")
        
        let nibNoService = UINib(nibName: "NoItemTableCell", bundle: nil)
        self.tableView.register(nibNoService, forCellReuseIdentifier: "NoServiceTableCellAgent")
        
        if let _agentGroupID = self.agentGroupID {
            agentGroupRef = FirebaseNodesCreation.getAgentGroup(agentGroupID: _agentGroupID)
            if let _agentGroupRef = agentGroupRef {
                agentsArrRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "agents")
                serviceRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "services")
                self.getAgentsFIR()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.title = LanguageGeneral.services
        self.tableView.reloadData()
    }
    
    private func getAgentsFIR() {
        let agentsArrQuery = agentsArrRef?.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // posts from the Firebase DB with ".value"
        agentsArrHandle = agentsArrQuery?.observe(.value, with: { [unowned self] (snapshot) -> Void in
            
            for dAgent in self.agentsArr {
                if let aaEmail = dAgent["email"], aaEmail.count > 0 {
                    if let refHandle = self.agentServiceRefHandle[aaEmail] {
                        self.agentServiceRef[aaEmail]?.removeObserver(withHandle: refHandle)
                    }
                    self.agentServiceRef.removeValue(forKey: aaEmail)
                    self.agentServiceRefHandle.removeValue(forKey: aaEmail)
                    
                    self.serviceNameDic.removeValue(forKey: aaEmail)
                    self.serviceIntroDic.removeValue(forKey: aaEmail)
                    self.servicePhoneDic.removeValue(forKey: aaEmail)
                    self.servicePhotoDic.removeValue(forKey: aaEmail)
                }
            }
            
            self.agentsArr.removeAll()
            
            for itemSnap in snapshot.children {
                if let _itemSnap = itemSnap as? DataSnapshot {
                    let agentData = _itemSnap.value as? [String : String] ?? [:]
                    if let emailH = agentData["email"] {
                        let nameH = agentData["name"] ?? ""
                        let nicknameH = agentData["nickname"] ?? ""
                        
                        let theAgent = ["email": emailH, "name": nameH, "nickname": nicknameH]
                        self.agentsArr.append(theAgent)
                    } else {
                        print("Error! Could not decode agent data in agent")
                    }
                }
            }
            for aAgent in self.agentsArr {
                if let _serviceRef = self.serviceRef {
                    if let aaEmail = aAgent["email"], aaEmail.count > 0 {
                        let aaEmailDecoded = FirebaseNodesCreation.decodeEmail(email: aaEmail)
                        let aaServiceRef = FirebaseNodesCreation.getSubNode(parentNode: _serviceRef, node: aaEmailDecoded)
                        self.observeServices(forAgent: aaServiceRef, withEmail: aaEmail)
                    }
                }
            }
        })
    }
    
    private func observeServices(forAgent: DatabaseReference, withEmail: String) {
        
        let theQuery = forAgent.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // posts from the Firebase DB with ".value"
        let theHandle = theQuery.observe(.value, with: { [unowned self] (snapshot) -> Void in
            var serName: [String] = []
            var serInto: [String] = []
            var serPhone: [String] = []
            var serPhoto: [String] = []
            for itemSnap in snapshot.children {
                if let _itemSnap = itemSnap as? DataSnapshot {
                    let serviceData = _itemSnap.value as? [String : String] ?? [:]
                    if let name = serviceData["name"] {
                        serName.append(name)
                        let introS = serviceData["introduction"] ?? ""
                        serInto.append(introS)
                        let phoneS = serviceData["phone"] ?? ""
                        serPhone.append(phoneS)
                        let photoS = serviceData["photo"] ?? ""
                        serPhoto.append(photoS)
                    } else {
                        print("Error! Could not decode service data in agent")
                    }
                }
            }
            self.serviceNameDic[withEmail] = serName
            self.serviceIntroDic[withEmail] = serInto
            self.servicePhoneDic[withEmail] = serPhone
            self.servicePhotoDic[withEmail] = serPhoto
            self.tableView.reloadData()
        })
        self.agentServiceRef[withEmail] = forAgent
        self.agentServiceRefHandle[withEmail] = theHandle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.agentsArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let emailH = self.agentsArr[section]["email"], emailH.count > 0 {
            let nameArrH = self.serviceNameDic[emailH]
            return nameArrH?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableCellAgent", for: indexPath) as! ServiceTableCell
        
        let emailH = self.agentsArr[indexPath.section]["email"] ?? ""
        
        let nameArrH = self.serviceNameDic[emailH]
        cell.nameLabel.text = nameArrH?[indexPath.row]
        
        let introArrH = self.serviceIntroDic[emailH]
        cell.intoLabel.text = introArrH?[indexPath.row]
        
        let phoneArrH = self.servicePhoneDic[emailH]
        cell.phoneLabel.text = phoneArrH?[indexPath.row]
        
        let photoArrH = self.servicePhotoDic[emailH]
        
        if let photoSH = photoArrH?[indexPath.row], photoSH.count > 0 {
            if let photoData = HelpFunctions.stringBase64ToPhoto(imgString: photoSH) {
                cell.photoImg.image = UIImage(data: photoData)
            } else {
                cell.photoImg.image = UIImage(named: "agent")
            }
        } else {
            cell.photoImg.image = UIImage(named: "agent")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        //  let nameLast = UserDefaults.standard.object(forKey: uLastName) as? String
        if let emailH = self.agentsArr[indexPath.section]["email"] , emailH == userEmail {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
      //  let nameLast = UserDefaults.standard.object(forKey: uLastName) as? String
        if let emailH = self.agentsArr[indexPath.section]["email"], emailH == userEmail {
            
            if editingStyle == .delete {
                let nameH = (self.serviceNameDic[emailH])?[indexPath.row] ?? ""
                let introH = (self.serviceIntroDic[emailH])?[indexPath.row] ?? ""
                let phoneH = (self.servicePhoneDic[emailH])?[indexPath.row] ?? ""
                self.presentAlertOkCancel(aTitle: LanguageGeneral.deleteStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr, nameIn: nameH, introIn: introH, phoneIn: phoneH, forAgentEmail: emailH)
                
                //  tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func deleteSerice(nameIn: String, introIn: String, phoneIn: String, forAgentEmail: String) {
        
        if let refHandle = serviceDeleteHandle {
            serviceDeleteRef?.removeObserver(withHandle: refHandle)
        }
        
        serviceDeleteRef = self.agentServiceRef[forAgentEmail]
        
        let queryForName = serviceDeleteRef?.queryOrdered(byChild: "name").queryEqual(toValue: nameIn)
        
        serviceDeleteHandle = queryForName?.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let serviceData = snapshot.value as? [String : String] ?? [:]
            
            let introS = serviceData["introduction"] ?? ""
            let phoneS = serviceData["phone"] ?? ""
            
            if introS == introIn && phoneS == phoneIn {
                
                snapshot.ref.removeValue()
                
            } else {
                print("Error! Could not delete service data.")
            }
        })
    }

    @IBAction func addService(_ sender: Any) {
        let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "addServiceVCinAgent") as! AddServiceVCAgent
        //   controller.role = "buyer"
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    fileprivate func presentAlertOkCancel(aTitle: String?, withMsg: String?, confirmTitle: String?, nameIn: String, introIn: String, phoneIn: String, forAgentEmail: String) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let okHandler: Handler = {action in
            self.deleteSerice(nameIn: nameIn, introIn: introIn, phoneIn: phoneIn, forAgentEmail: forAgentEmail)
        }
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let okAct = UIAlertAction(title: confirmTitle, style: .default, handler: okHandler)
        let cancelAct = UIAlertAction(title: LanguageGeneral.cancelStr, style: .default, handler: nil)
        alert.addAction(cancelAct)
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

    deinit {
        if let refHandle = agentsArrHandle {
            agentsArrRef?.removeObserver(withHandle: refHandle)
        }
        if let refHandle = serviceDeleteHandle {
            serviceDeleteRef?.removeObserver(withHandle: refHandle)
        }
        for dAgent in self.agentsArr {
            if let aaEmail = dAgent["email"], aaEmail.count > 0 {
                if let refHandle = self.agentServiceRefHandle[aaEmail] {
                    self.agentServiceRef[aaEmail]?.removeObserver(withHandle: refHandle)
                }
                self.agentServiceRef.removeValue(forKey: aaEmail)
                self.agentServiceRefHandle.removeValue(forKey: aaEmail)
            }
        }
        noteCenter.removeObserver(self)
    }
}
