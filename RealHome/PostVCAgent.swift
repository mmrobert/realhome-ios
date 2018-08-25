//
//  PostVCAgent.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-08.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class PostVCAgent: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtnItem: UIBarButtonItem!
    
    var agentGroupID: String?
    
    var agentGroupRef: DatabaseReference?
    var postRef: DatabaseReference?
    
    var postDeleteRef: DatabaseReference?
    var postDeleteHandle: DatabaseHandle?
    
    var postTitleDic: [String:[String]] = [:]
    var postIntroDic: [String:[String]] = [:]
    var postSiteURLDic: [String:[String]] = [:]
    
    var agentsArr: [[String:String]] = []
    var agentsArrRef: DatabaseReference?
    var agentsArrHandle: DatabaseHandle?
    
    var agentPostRef: [String: DatabaseReference] = [:]
    var agentPostRefHandle: [String: DatabaseHandle] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = LanguageGeneral.posts
        
        self.agentGroupID = CoreDataController.fetchAgentGroups()[0].value(forKeyPath: "groupID") as? String
        
        self.addBtnItem.target = self
        self.addBtnItem.action = #selector(PostVCAgent.addPost(_:))
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(PostVCAgent.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        let nibPost = UINib(nibName: "PostTableCell", bundle: nil)
        self.tableView.register(nibPost, forCellReuseIdentifier: "PostTableCellAgent")
        
        let nibNoPost = UINib(nibName: "NoItemTableCell", bundle: nil)
        self.tableView.register(nibNoPost, forCellReuseIdentifier: "NoPostTableCellAgent")
        
        if let _agentGroupID = self.agentGroupID {
            agentGroupRef = FirebaseNodesCreation.getAgentGroup(agentGroupID: _agentGroupID)
            if let _agentGroupRef = agentGroupRef {
                agentsArrRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "agents")
                postRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "posts")
                self.getAgentsFIR()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.title = LanguageGeneral.posts
        self.tableView.reloadData()
    }
    
    private func getAgentsFIR() {
        let agentsArrQuery = agentsArrRef?.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // posts from the Firebase DB with ".value"
        agentsArrHandle = agentsArrQuery?.observe(.value, with: { [unowned self] (snapshot) -> Void in
            
            for dAgent in self.agentsArr {
                if let aaEmail = dAgent["email"], aaEmail.count > 0 {
                    if let refHandle = self.agentPostRefHandle[aaEmail] {
                        self.agentPostRef[aaEmail]?.removeObserver(withHandle: refHandle)
                    }
                    self.agentPostRef.removeValue(forKey: aaEmail)
                    self.agentPostRefHandle.removeValue(forKey: aaEmail)
                    
                    self.postTitleDic.removeValue(forKey: aaEmail)
                    self.postIntroDic.removeValue(forKey: aaEmail)
                    self.postSiteURLDic.removeValue(forKey: aaEmail)
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
                        print("Error! Could not decode agent data in agent post")
                    }
                }
            }
            for aAgent in self.agentsArr {
                if let _postRef = self.postRef {
                    if let aaEmail = aAgent["email"], aaEmail.count > 0 {
                        let aaEmailDecoded = FirebaseNodesCreation.decodeEmail(email: aaEmail)
                        let aaPostRef = FirebaseNodesCreation.getSubNode(parentNode: _postRef, node: aaEmailDecoded)
                        self.observePosts(forAgent: aaPostRef, withEmail: aaEmail)
                    }
                }
            }
        })
    }
    
    private func observePosts(forAgent: DatabaseReference, withEmail: String) {
        
        let theQuery = forAgent.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // posts from the Firebase DB with ".value"
        let theHandle = theQuery.observe(.value, with: { [unowned self] (snapshot) -> Void in
            var postTitle: [String] = []
            var postIntro: [String] = []
            var postSiteUrl: [String] = []
            for itemSnap in snapshot.children {
                if let _itemSnap = itemSnap as? DataSnapshot {
                    let postData = _itemSnap.value as? [String : String] ?? [:]
                    if let siteURL = postData["siteURL"] {
                        if URL(string: siteURL) != nil {
                            postSiteUrl.append(siteURL)
                            let titleS = postData["title"] ?? ""
                            postTitle.append(titleS)
                            let intoS = postData["introduction"] ?? ""
                            postIntro.append(intoS)
                        }
                    } else {
                        print("Error! Could not decode post data in agent")
                    }
                }
            }
            self.postTitleDic[withEmail] = postTitle
            self.postIntroDic[withEmail] = postIntro
            self.postSiteURLDic[withEmail] = postSiteUrl
            self.tableView.reloadData()
        })
        self.agentPostRef[withEmail] = forAgent
        self.agentPostRefHandle[withEmail] = theHandle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.agentsArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let emailH = self.agentsArr[section]["email"], emailH.count > 0 {
            let siteArrH = self.postSiteURLDic[emailH]
            return siteArrH?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableCellAgent", for: indexPath) as! PostTableCell
        
        let emailH = self.agentsArr[indexPath.section]["email"] ?? ""
        
        let titleArrH = self.postTitleDic[emailH]
        cell.titleLabel.text = titleArrH?[indexPath.row]
        
        let introArrH = self.postIntroDic[emailH]
        cell.briefIntoLabel.text = introArrH?[indexPath.row]
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "postsiteVCinBuyer") as! PostWebSiteVC
        
        let emailH = self.agentsArr[indexPath.section]["email"] ?? ""
        
        let siteArrH = self.postSiteURLDic[emailH]
        controller.siteURL = siteArrH?[indexPath.row]
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
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
                let siteURLH = (self.postSiteURLDic[emailH])?[indexPath.row] ?? ""
                let titleH = (self.postTitleDic[emailH])?[indexPath.row] ?? ""
                let introH = (self.postIntroDic[emailH])?[indexPath.row] ?? ""
                
                self.presentAlertOkCancel(aTitle: LanguageGeneral.deleteStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr, siteUrlIn: siteURLH, titleIn: titleH, introIn: introH, forAgentEmail: emailH)
                //  tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func deletePost(siteUrlIn: String, titleIn: String, introIn: String, forAgentEmail: String) {
        
        if let refHandle = postDeleteHandle {
            postDeleteRef?.removeObserver(withHandle: refHandle)
        }
        
        postDeleteRef = self.agentPostRef[forAgentEmail]
        
        
        let queryForURL = postDeleteRef?.queryOrdered(byChild: "siteURL").queryEqual(toValue: siteUrlIn)
        
        postDeleteHandle = queryForURL?.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let postData = snapshot.value as? [String : String] ?? [:]
            
            let titleS = postData["title"] ?? ""
            let introS = postData["introduction"] ?? ""
            
            if titleS == titleIn && introS == introIn {
                
                snapshot.ref.removeValue()
                
            } else {
                print("Error! Could not delete post data in agent.")
            }
        })
    }
    
    func addPost(_ sender: UIBarButtonItem) {
        let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "addPostVCinAgent") as! AddPostVCAgent
        //   controller.role = "buyer"
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    fileprivate func presentAlertOkCancel(aTitle: String?, withMsg: String?, confirmTitle: String?, siteUrlIn: String, titleIn: String, introIn: String, forAgentEmail: String) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let okHandler: Handler = {action in
            self.deletePost(siteUrlIn: siteUrlIn, titleIn: titleIn, introIn: introIn, forAgentEmail: forAgentEmail)
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
        if let refHandle = postDeleteHandle {
            postDeleteRef?.removeObserver(withHandle: refHandle)
        }
        for dAgent in self.agentsArr {
            if let aaEmail = dAgent["email"], aaEmail.count > 0 {
                if let refHandle = self.agentPostRefHandle[aaEmail] {
                    self.agentPostRef[aaEmail]?.removeObserver(withHandle: refHandle)
                }
                self.agentPostRef.removeValue(forKey: aaEmail)
                self.agentPostRefHandle.removeValue(forKey: aaEmail)
            }
        }
        noteCenter.removeObserver(self)
    }
}
