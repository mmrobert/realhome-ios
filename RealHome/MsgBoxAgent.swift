//
//  MsgBoxAgent.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-11.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class MsgBoxAgent: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var agentGroupID: String?
    
    var agentGroupRef: DatabaseReference?
    
    var buyersArr: [[String:String]] = []
    var buyersArrRef: DatabaseReference?
    var buyersArrHandle: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LanguageGeneral.messages

        // Do any additional setup after loading the view.
        
        self.agentGroupID = CoreDataController.fetchAgentGroups()[0].value(forKeyPath: "groupID") as? String
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(MsgBoxAgent.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        let nibMsgBox = UINib(nibName: "MsgBoxTableCell", bundle: nil)
        self.tableView.register(nibMsgBox, forCellReuseIdentifier: "MsgBoxCellAgent")
        
        if let _agentGroupID = self.agentGroupID {
            agentGroupRef = FirebaseNodesCreation.getAgentGroup(agentGroupID: _agentGroupID)
            if let _agentGroupRef = agentGroupRef {
                buyersArrRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "buyers")
                self.getBuyersFIR()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.title = LanguageGeneral.messages
      //  self.tableView.reloadData()
    }
    
    private func getBuyersFIR() {
        let buyersArrQuery = buyersArrRef?.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // posts from the Firebase DB with ".value"
        buyersArrHandle = buyersArrQuery?.observe(.value, with: { [unowned self] (snapshot) -> Void in
            
            self.buyersArr.removeAll()
            
            for itemSnap in snapshot.children {
                if let _itemSnap = itemSnap as? DataSnapshot {
                    let buyerData = _itemSnap.value as? [String : String] ?? [:]
                    if let emailH = buyerData["email"] {
                        let nameH = buyerData["name"] ?? ""
                        let nicknameH = buyerData["nickname"] ?? ""
                        let photoH = buyerData["photo"] ?? ""
                        
                        let theBuyer = ["email": emailH, "name": nameH, "nickname": nicknameH, "photo": photoH]
                        self.buyersArr.append(theBuyer)
                    } else {
                        print("Error! Could not decode buyer data in agent msg box")
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.buyersArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgBoxCellAgent", for: indexPath) as! MsgBoxTableCell
        
        let nickNameH = self.buyersArr[indexPath.row]["nickname"] ?? ""
        cell.nameLabel.text = nickNameH
        
        if let photoSH = self.buyersArr[indexPath.row]["photo"], photoSH.count > 0 {
            if let photoData = HelpFunctions.stringBase64ToPhoto(imgString: photoSH) {
                cell.photoImgView.image = UIImage(data: photoData)
            } else {
                cell.photoImgView.image = UIImage(named: "buyer")
            }
        } else {
            cell.photoImgView.image = UIImage(named: "buyer")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "msgChatVCinAgent") as! MsgChatAgent
        controller.buyerEmail = self.buyersArr[indexPath.row]["email"]
        controller.buyerNickname = self.buyersArr[indexPath.row]["nickname"]
        
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
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
        if let refHandle = buyersArrHandle {
            buyersArrRef?.removeObserver(withHandle: refHandle)
        }
        noteCenter.removeObserver(self)
    }
}
