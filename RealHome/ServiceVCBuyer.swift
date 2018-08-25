//
//  ServiceVCBuyer.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-05.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ServiceVCBuyer: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    public var agentGroupID: String?
    public var nickNameIn: String?

    @IBOutlet weak var tableView: UITableView!
    
    var agentGroupRef: DatabaseReference?
    var serviceRef: DatabaseReference?
    
    var serviceNameDic: [String:[String]] = [:]
    var serviceIntroDic: [String:[String]] = [:]
    var servicePhoneDic: [String:[String]] = [:]
    var servicePhotoDic: [String:[String]] = [:]
    
    var agentsArr: [[String:String]] = []
    var agentsArrRef: DatabaseReference?
    var agentsArrHandle: DatabaseHandle?
    
    var agentServiceRef: [String: DatabaseReference] = [:]
    var agentServiceRefHandle: [String: DatabaseHandle] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.nickNameIn
        // Do any additional setup after loading the view.
        
     //   self.agentGroupID = CoreDataController.fetchAgentGroups()[0].value(forKeyPath: "groupID") as? String
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(ServiceVCBuyer.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        let nibService = UINib(nibName: "ServiceTableCell", bundle: nil)
        self.tableView.register(nibService, forCellReuseIdentifier: "ServiceTableCellBuyer")
        
        let nibNoService = UINib(nibName: "NoItemTableCell", bundle: nil)
        self.tableView.register(nibNoService, forCellReuseIdentifier: "NoServiceTableCellBuyer")
        
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
                        print("Error! Could not decode agent data in buyer service")
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
                        print("Error! Could not decode service data in buyer")
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableCellBuyer", for: indexPath) as! ServiceTableCell
        
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
        return false
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
