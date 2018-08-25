//
//  FavoritesTabRootVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD
import Alamofire
import AlamofireImage
import Firebase

class FavoritesTabRootVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var signInItemBtn: UIBarButtonItem!

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    public weak var agentGroupDelegate: AddAgentGroup?
    
    var favoriteIDsResi: [String] = []
    var favoriteIDsComm: [String] = []
    
    var dataResidentialArr: [[String:Any?]] = []
    var dataCommercialArr: [[String:Any?]] = []
    
    var favoriteUpdatedNoteResi: Bool = true
    var favoriteUpdatedNoteComm: Bool = true
    
    var userRef: DatabaseReference? // agents or buyers
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpLogo()
        
        self.segControl.setTitle(LanguageProperty.residentialStr, forSegmentAt: 0)
        self.segControl.setTitle(LanguageProperty.commercialStr, forSegmentAt: 1)
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(FavoritesTabRootVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(FavoritesTabRootVC.newFavoriteAddedSearchTab(note:)), name: NSNotification.Name(rawValue: "AddFavoriteFromSearchTab"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(FavoritesTabRootVC.newFavoriteAddedSearchList(note:)), name: NSNotification.Name(rawValue: "AddFavoriteFromSearchList"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(FavoritesTabRootVC.newFavoriteAddedDetailResi(note:)), name: NSNotification.Name(rawValue: "AddFavoriteFromDetailResi"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(FavoritesTabRootVC.newFavoriteAddedDetailComm(note:)), name: NSNotification.Name(rawValue: "AddFavoriteFromDetailComm"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(FavoritesTabRootVC.newFavoriteAddedRecommAgent(note:)), name: NSNotification.Name(rawValue: "AddFavoriteFromRecommAgent"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(FavoritesTabRootVC.newFavoriteAddedRecommBuyer(note:)), name: NSNotification.Name(rawValue: "AddFavoriteFromRecommBuyer"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        self.favoriteIDsResi = self.getListIDarray(resiCommIn: "residential")
        self.favoriteIDsComm = self.getListIDarray(resiCommIn: "commercial")
            
        self.getDataFromServer()
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.segControl.setTitle(LanguageProperty.residentialStr, forSegmentAt: 0)
        self.segControl.setTitle(LanguageProperty.commercialStr, forSegmentAt: 1)
        self.tableView.reloadData()
    }
    
    @objc fileprivate func newFavoriteAddedSearchTab(note: NSNotification) {
        
        if let userInfoBack = note.userInfo {
            if let resiCommBack = userInfoBack["keyStr"] as? String {
                if resiCommBack == "residential" {
                    self.favoriteUpdatedNoteResi = true
                } else {
                    self.favoriteUpdatedNoteComm = true
                }
            }
        }
    }
    
    @objc fileprivate func newFavoriteAddedSearchList(note: NSNotification) {
        
        if let userInfoBack = note.userInfo {
            if let resiCommBack = userInfoBack["keyStr"] as? String {
                if resiCommBack == "residential" {
                    self.favoriteUpdatedNoteResi = true
                } else {
                    self.favoriteUpdatedNoteComm = true
                }
            }
        }
    }
    
    @objc fileprivate func newFavoriteAddedDetailResi(note: NSNotification) {
        
        if let userInfoBack = note.userInfo {
            if let resiCommBack = userInfoBack["keyStr"] as? String {
                if resiCommBack == "residential" {
                    self.favoriteUpdatedNoteResi = true
                } else {
                    self.favoriteUpdatedNoteComm = true
                }
            }
        }
    }
    
    @objc fileprivate func newFavoriteAddedDetailComm(note: NSNotification) {
        
        if let userInfoBack = note.userInfo {
            if let resiCommBack = userInfoBack["keyStr"] as? String {
                if resiCommBack == "residential" {
                    self.favoriteUpdatedNoteResi = true
                } else {
                    self.favoriteUpdatedNoteComm = true
                }
            }
        }
    }
    
    @objc fileprivate func newFavoriteAddedRecommAgent(note: NSNotification) {
        
        if let userInfoBack = note.userInfo {
            if let resiCommBack = userInfoBack["keyStr"] as? String {
                if resiCommBack == "residential" {
                    self.favoriteUpdatedNoteResi = true
                } else {
                    self.favoriteUpdatedNoteComm = true
                }
            }
        }
    }
    
    @objc fileprivate func newFavoriteAddedRecommBuyer(note: NSNotification) {
        
        if let userInfoBack = note.userInfo {
            if let resiCommBack = userInfoBack["keyStr"] as? String {
                if resiCommBack == "residential" {
                    self.favoriteUpdatedNoteResi = true
                } else {
                    self.favoriteUpdatedNoteComm = true
                }
            }
        }
    }
    
    fileprivate func getListIDarray(resiCommIn: String) -> [String] {
        var getedArr: [String] = []
        let favProps = CoreDataController.fetchFavoriteProps()
        for objj: NSManagedObject in favProps {
            if let rcSaved = objj.value(forKey: "resiComm") as? String, rcSaved == resiCommIn {
                if let idSaved = objj.value(forKey: "listingID") as? String {
                    getedArr.append(idSaved)
                }
            }
        }
        return getedArr
    }
    
    fileprivate func getlistIDcombination(idsArr: [String]) -> String {
        let arrLength = idsArr.count
        var combinedStr = idsArr[0]
        if arrLength < 2 {
            return combinedStr
        } else {
            for ii in 1..<arrLength {
                combinedStr = combinedStr + "-" + idsArr[ii]
            }
            return combinedStr
        }
    }
    
    fileprivate func getDataFromServer() {
        switch (self.segControl.selectedSegmentIndex) {
        case 0:
            if self.favoriteIDsResi.count > 0 {
                if self.favoriteUpdatedNoteResi {
                    let iDCombinationResi = self.getlistIDcombination(idsArr: self.favoriteIDsResi)
                    let parameterResi: [String:Any] = ["op": "q11",
                                                       "listingids": iDCombinationResi]
                    self.connectingServer(parameterIn: parameterResi)
                }
            }
        case 1:
            if self.favoriteIDsComm.count > 0 {
                if self.favoriteUpdatedNoteComm {
                    let iDCombinationComm = self.getlistIDcombination(idsArr: self.favoriteIDsComm)
                    let parameterComm: [String:Any] = ["op": "q12",
                                                       "listingids": iDCombinationComm]
                    self.connectingServer(parameterIn: parameterComm)
                }
            }
        default:
            return
        }
    }
    
    @IBAction func segSelectedAction(_ sender: Any) {
        
      //  self.favoriteIDsResi = self.getListIDarray(resiCommIn: "residential")
      //  self.favoriteIDsComm = self.getListIDarray(resiCommIn: "commercial")
        self.tableView.reloadData()
        self.getDataFromServer()
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
                // button is disabled and doing nothing
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
    
    func connectingServer(parameterIn: [String:Any]) {
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        netWorkProvider.rx.request(.propsMultiIDs(paras: parameterIn)).subscribe { [unowned self] event in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonArray = try response.mapJSON() as? [String:Any?] {
                        if let succ = jsonArray["success"] as? String, succ == "true" {
                            if let propArr = jsonArray["property"] as? [[String:Any?]] {
                                if propArr.count > 0 {
                                    self.parseNetworkDataProps(propArrIn: propArr)
                                } else {
                                    self.parseNetworkDataProps(propArrIn: propArr)
                                    self.presentAlert(aTitle: nil, withMsg: LanguageProperty.listingPropNotExistStr, confirmTitle: LanguageGeneral.okStr)
                                }
                            }
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in search tab: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in search tab: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
        // the following is full url
       // print(netWorkProvider.endpoint(.propsFilter(paras: parameterIn)).urlRequest?.description ?? "net url")
    }
    
    func parseNetworkDataProps(propArrIn: [[String:Any?]]) {
        switch (self.segControl.selectedSegmentIndex) {
        case 0:
            self.favoriteUpdatedNoteResi = false
            self.dataResidentialArr = propArrIn
            updateFavorites(resiCommIn: "residential")
            self.tableView.reloadData()
        case 1:
            self.favoriteUpdatedNoteComm = false
            self.dataCommercialArr = propArrIn
            updateFavorites(resiCommIn: "commercial")
            self.tableView.reloadData()
        default:
            return
        }
    }
    
    func updateFavorites(resiCommIn: String) {
        if resiCommIn == "residential" {
            for idHH in self.favoriteIDsResi {
                CoreDataController.deleteFavoriteEntity(listID: idHH)
            }
            for propI in self.dataResidentialArr {
                if let idNew = propI["ListingID"] as? String {
                    self.addFavoriteProp(idIn: idNew, resiCommIn: resiCommIn)
                }
            }
            self.favoriteIDsResi = self.getListIDarray(resiCommIn: "residential")
        } else if resiCommIn == "commercial" {
            for idHH in self.favoriteIDsComm {
                CoreDataController.deleteFavoriteEntity(listID: idHH)
            }
            for propI in self.dataCommercialArr {
                if let idNew = propI["ListingID"] as? String {
                    self.addFavoriteProp(idIn: idNew, resiCommIn: resiCommIn)
                }
            }
            self.favoriteIDsComm = self.getListIDarray(resiCommIn: "commercial")
        } else {
            return
        }
    }
    
    fileprivate func addFavoriteProp(idIn: String, resiCommIn: String) {
        if idIn.count > 2 {
            var isFavorite: Bool = false
            let favProps = CoreDataController.fetchFavoriteProps()
            for objj: NSManagedObject in favProps {
                if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == idIn {
                    isFavorite = true
                }
            }
            if !isFavorite {
                _ = CoreDataController.createFavoriteEntity(listID: idIn, resiComm: resiCommIn)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (self.segControl.selectedSegmentIndex) {
        case 0:
            if self.dataResidentialArr.count > 0 {
                return self.dataResidentialArr.count
            } else {
                return 1
            }
        case 1:
            if self.dataCommercialArr.count > 0 {
                return self.dataCommercialArr.count
            } else {
                return 1
            }
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (self.segControl.selectedSegmentIndex) {
        case 0:
            if self.dataResidentialArr.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesListCell", for: indexPath) as! FavoritesListTableCell
                
                let dataAtThisRow = self.dataResidentialArr[indexPath.row]
                
                if let imgUrlH = dataAtThisRow["photo1url"] as? String {
                    if let _ = URL(string: imgUrlH) {
                        Alamofire.request(imgUrlH).responseImage { response in
                            if let image = response.result.value {
                                cell.photoImg.image = image
                            }
                        }
                    }
                }
                
                cell.setCaptionsLabel()
                
                cell.bldgTypeLabel.text = dataAtThisRow["bldgtype"] as? String
                cell.saleRentLabel.text = dataAtThisRow["salerent"] as? String
                cell.priceLabel.text = dataAtThisRow["Price"] as? String
                //
                let propIStreet = dataAtThisRow["Address"] as? String
                let _propIStreet = propIStreet ?? ""
                let propICity = dataAtThisRow["City"] as? String
                let _propICity = propICity ?? ""
                let propIPro = dataAtThisRow["Province"] as? String
                let _propIPro = propIPro ?? ""
                let propIPC = dataAtThisRow["PostalCode"] as? String
                let _propIPC = propIPC ?? ""
                
                let addH: String? = _propIStreet + " " + _propICity + " " + _propIPro + " " + _propIPC
                
                cell.addressLabel.text = addH
                //
                cell.listIDValueLabel.text = dataAtThisRow["ListingID"] as? String
                cell.bedRoomValueLabel.text = dataAtThisRow["BedroomsTotal"] as? String
                cell.bathRoomValueLabel.text = dataAtThisRow["BathroomTotal"] as? String
                
                cell.deleteFavoritesDelegate = self
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nofavoritesCell", for: indexPath) as! NoFavoritesTableCell
                cell.setCaptionsLabel()
                cell.goBackSearchDelegate = self
                return cell
            }
        case 1:
            if self.dataCommercialArr.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commercialCell", for: indexPath) as! FavoritesCommercialTableCell
                
                let dataAtThisRow = self.dataCommercialArr[indexPath.row]
                
                if let imgUrlH = dataAtThisRow["photo1url"] as? String {
                    if let _ = URL(string: imgUrlH) {
                        Alamofire.request(imgUrlH).responseImage { response in
                            if let image = response.result.value {
                                cell.photoImgView.image = image
                            }
                        }
                    }
                }
                
                cell.setCaptionsLabel()
                
                cell.saleRentLabel.text = dataAtThisRow["salerent"] as? String
                cell.priceLabel.text = dataAtThisRow["Price"] as? String
                //
                let propIStreet = dataAtThisRow["Address"] as? String
                let _propIStreet = propIStreet ?? ""
                let propICity = dataAtThisRow["City"] as? String
                let _propICity = propICity ?? ""
                let propIPro = dataAtThisRow["Province"] as? String
                let _propIPro = propIPro ?? ""
                let propIPC = dataAtThisRow["PostalCode"] as? String
                let _propIPC = propIPC ?? ""
                
                let addH: String? = _propIStreet + " " + _propICity + " " + _propIPro + " " + _propIPC
                
                cell.addressLabel.text = addH
                //
                cell.listingIDValueLabel.text = dataAtThisRow["ListingID"] as? String
                cell.propertyValueLabel.text = dataAtThisRow["businesstype"] as? String
 
                cell.deleteFavoritesDelegate = self
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nofavoritesCell", for: indexPath) as! NoFavoritesTableCell
                cell.setCaptionsLabel()
                cell.goBackSearchDelegate = self
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nofavoritesCell", for: indexPath) as! NoFavoritesTableCell
            cell.setCaptionsLabel()
            cell.goBackSearchDelegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.segControl.selectedSegmentIndex {
        case 0:
            if self.dataResidentialArr.count > 0 {
                let storyB = UIStoryboard(name: "FavoritesControllers", bundle: nil)
                let controller = storyB.instantiateViewController(withIdentifier: "PropertyDetailsVCinFavorites") as! PropertyDetailsVC
                controller.hidesBottomBarWhenPushed = true
                let objAti = self.dataResidentialArr[indexPath.row]
                controller.listingIDPassedIn = objAti["ListingID"] as? String
                //
                let propIStreet = objAti["Address"] as? String
                let _propIStreet = propIStreet ?? ""
                let propICity = objAti["City"] as? String
                let _propICity = propICity ?? ""
                let propIPro = objAti["Province"] as? String
                let _propIPro = propIPro ?? ""
                let propIPC = objAti["PostalCode"] as? String
                let _propIPC = propIPC ?? ""
                
                let addH: String? = _propIStreet + " " + _propICity + " " + _propIPro + " " + _propIPC
                
                controller.addressPassedIn = addH
                //
                controller.latitudePassedIn = objAti["latitude"] as? String
                controller.longitudePassedIn = objAti["longtitude"] as? String
                controller.bldgTypePassedIn = objAti["bldgtype"] as? String
                controller.statePassedIn = ""
                if (self.responds(to: #selector(self.show(_:sender:)))) {
                    self.show(controller, sender: self)
                } else {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        case 1:
            if self.dataCommercialArr.count > 0 {
                let storyB = UIStoryboard(name: "FavoritesControllers", bundle: nil)
                let controller = storyB.instantiateViewController(withIdentifier: "PropertyDetailsCommVCinFavorites") as! PropertyDetailsCommVC
                controller.hidesBottomBarWhenPushed = true
                let objAti = self.dataCommercialArr[indexPath.row]
                controller.listingIDPassedIn = objAti["ListingID"] as? String
                //
                let propIStreet = objAti["Address"] as? String
                let _propIStreet = propIStreet ?? ""
                let propICity = objAti["City"] as? String
                let _propICity = propICity ?? ""
                let propIPro = objAti["Province"] as? String
                let _propIPro = propIPro ?? ""
                let propIPC = objAti["PostalCode"] as? String
                let _propIPC = propIPC ?? ""
                
                let addH: String? = _propIStreet + " " + _propICity + " " + _propIPro + " " + _propIPC
                
                controller.addressPassedIn = addH
                //
                controller.latitudePassedIn = objAti["latitude"] as? String
                controller.longitudePassedIn = objAti["longtitude"] as? String
                controller.busiTypePassedIn = objAti["businesstype"] as? String
                if (self.responds(to: #selector(self.show(_:sender:)))) {
                    self.show(controller, sender: self)
                } else {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        default:
            self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgTryAgainStr, confirmTitle: LanguageGeneral.okStr)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    fileprivate func presentAlertOkCancel(aTitle: String?, withMsg: String?, confirmTitle: String?, rowToDelete: IndexPath?, resiComm: String) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let okHandler: Handler = {action in
            if let rowH = rowToDelete?.row {
                if resiComm == "residential" {
                    let propDeleteH = self.dataResidentialArr[rowH]
                    if let idDeleteH = propDeleteH["ListingID"] as? String {
                        CoreDataController.deleteFavoriteEntity(listID: idDeleteH)
                        self.favoriteIDsResi = self.getListIDarray(resiCommIn: "residential")
                        self.dataResidentialArr.remove(at: rowH)
                        self.tableView.reloadData()
                    }
                } else if resiComm == "commercial" {
                    let propDeleteH = self.dataCommercialArr[rowH]
                    if let idDeleteH = propDeleteH["ListingID"] as? String {
                        CoreDataController.deleteFavoriteEntity(listID: idDeleteH)
                        self.favoriteIDsComm = self.getListIDarray(resiCommIn: "commercial")
                        self.dataCommercialArr.remove(at: rowH)
                        self.tableView.reloadData()
                    }
                } else {
                    return
                }
            }
        }
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let okAct = UIAlertAction(title: confirmTitle, style: .default, handler: okHandler)
        let cancelAct = UIAlertAction(title: LanguageGeneral.cancelStr, style: .default, handler: nil)
        alert.addAction(cancelAct)
        alert.addAction(okAct)
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        if let refHH = self.userRef {
            refHH.removeAllObservers()
        }
        noteCenter.removeObserver(self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FavoritesTabRootVC: DeleteFavorites {
    func toDeleteFavorite(_ cellView: FavoritesListTableCell) {
        let deletedRow = self.tableView.indexPath(for: cellView)
        self.presentAlertOkCancel(aTitle: LanguageGeneral.deleteStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr, rowToDelete: deletedRow, resiComm: "residential")
        
      //  print(cellView.bldgTypeLabel.text ?? "delete favorites")
    }
}

extension FavoritesTabRootVC: DeleteCommercialFavorites {
    func toDeleteCommFavorite(_ cellView: FavoritesCommercialTableCell) {
        let deletedRow = self.tableView.indexPath(for: cellView)
        self.presentAlertOkCancel(aTitle: LanguageGeneral.deleteStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr, rowToDelete: deletedRow, resiComm: "commercial")
        
      //  print(cellView.addressLabel.text ?? "delete comm favorites")
    }
}

extension FavoritesTabRootVC: FavoritesNoFavoritesSearchBtn {
    func goBackToSearch(_ sender: UIButton) {
      //  print(sender.title(for: .normal) ?? "favorites search btn")
        self.tabBarController?.selectedIndex = 0
    }
}

extension FavoritesTabRootVC: AlertViewWithApplyDelegate {
    func enterBtnTapped(codeStr: String, nickNameStr: String) {
        self.updateAgentCodeServer(theCode: codeStr, theNickname: nickNameStr)
    }
    
    func cancelBtntapped() {
        
    }
}
