//
//  RecommendationVCAgent.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-09.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import MBProgressHUD
import Alamofire
import AlamofireImage

class RecommendationVCAgent: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segControll: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtnItem: UIBarButtonItem!
    
    weak var textRadioBtnView: TextRadioButton?
    
    var agentGroupID: String?
    
    var dataResidentialArr: [[String:Any?]] = []
    var dataCommercialArr: [[String:Any?]] = []
    
    var agentGroupRef: DatabaseReference?
    var recoRef: DatabaseReference?
    
    var recoDeleteRef: DatabaseReference?
    var recoDeleteHandle: DatabaseHandle?
  /*
    var listIDDic: [String:[String]] = [:]
    var byEmailDic: [String:[String]] = [:]
    var byNameDic: [String:[String]] = [:]
    var resiCommDic: [String:[String]] = [:]
  */
    var resiFromFIR: [String:[[String:String]]] = [:]
    var commFromFIR: [String:[[String:String]]] = [:]
    
    var agentsArr: [[String:String]] = []
    var agentsArrRef: DatabaseReference?
    var agentsArrHandle: DatabaseHandle?
    
    var agentRecoRef: [String: DatabaseReference] = [:]
    var agentRecoRefHandle: [String: DatabaseHandle] = [:]
    
  //  var propsLoadedResi: Bool = false
  //  var propsLoadedComm: Bool = false
    
    var favoriteProps: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LanguageGeneral.recommendations
        
        self.agentGroupID = CoreDataController.fetchAgentGroups()[0].value(forKeyPath: "groupID") as? String
        
        // Do any additional setup after loading the view.
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.addBtnItem.target = self
        self.addBtnItem.action = #selector(RecommendationVCAgent.addRecommendation(_:))
        
        noteCenter.addObserver(self, selector: #selector(RecommendationVCAgent.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        let nibResi = UINib(nibName: "ResiTableCell", bundle: nil)
        self.tableView.register(nibResi, forCellReuseIdentifier: "ResiRecommCellAgent")
        
        let nibComm = UINib(nibName: "CommTableCell", bundle: nil)
        self.tableView.register(nibComm, forCellReuseIdentifier: "CommRecommCellAgent")
        
        let nibNoItem = UINib(nibName: "NoItemTableCell", bundle: nil)
        self.tableView.register(nibNoItem, forCellReuseIdentifier: "NoItemRecommCellAgent")
        
        if let _agentGroupID = self.agentGroupID {
            agentGroupRef = FirebaseNodesCreation.getAgentGroup(agentGroupID: _agentGroupID)
            if let _agentGroupRef = agentGroupRef {
                agentsArrRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "agents")
                recoRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "recommendations")
                
                self.getAgentsFIR()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.favoriteProps = CoreDataController.fetchFavoriteProps()
        
        self.segControll.setTitle(LanguageProperty.residentialStr, forSegmentAt: 0)
        self.segControll.setTitle(LanguageProperty.commercialStr, forSegmentAt: 1)
    }
    
    @IBAction func segChangeTap(_ sender: Any) {
        self.tableView.reloadData()
        self.loadingPropDataFromServer()
    }
    
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.title = LanguageGeneral.recommendations
        self.tableView.reloadData()
    }
    
    private func getAgentsFIR() {
        let agentsArrQuery = agentsArrRef?.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // posts from the Firebase DB with ".value"
        agentsArrHandle = agentsArrQuery?.observe(.value, with: { [unowned self] (snapshot) -> Void in
            
            for dAgent in self.agentsArr {
                if let aaEmail = dAgent["email"], aaEmail.count > 0 {
                    if let refHandle = self.agentRecoRefHandle[aaEmail] {
                        self.agentRecoRef[aaEmail]?.removeObserver(withHandle: refHandle)
                    }
                    self.agentRecoRef.removeValue(forKey: aaEmail)
                    self.agentRecoRefHandle.removeValue(forKey: aaEmail)
                    
                    self.resiFromFIR.removeValue(forKey: aaEmail)
                    self.commFromFIR.removeValue(forKey: aaEmail)
                /*
                    self.listIDDic.removeValue(forKey: aaEmail)
                    self.byEmailDic.removeValue(forKey: aaEmail)
                    self.byNameDic.removeValue(forKey: aaEmail)
                    self.resiCommDic.removeValue(forKey: aaEmail)
                 */
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
                        print("Error! Could not decode agent data in agent recommendation.")
                    }
                }
            }
            for aAgent in self.agentsArr {
                if let _recoRef = self.recoRef {
                    if let aaEmail = aAgent["email"], aaEmail.count > 0 {
                        let aaEmailDecoded = FirebaseNodesCreation.decodeEmail(email: aaEmail)
                        let aaRecoRef = FirebaseNodesCreation.getSubNode(parentNode: _recoRef, node: aaEmailDecoded)
                        self.observeRecommendations(forAgent: aaRecoRef, withEmail: aaEmail)
                    }
                }
            }
        })
    }
    
    private func observeRecommendations(forAgent: DatabaseReference, withEmail: String) {
        
        let theQuery = forAgent.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // recommendations from the Firebase DB with ".value"
        let theHandle = theQuery.observe(.value, with: { [unowned self] (snapshot) -> Void in
         /*
            var listIDAr: [String] = []
            var byEmailAr: [String] = []
            var byNameAr: [String] = []
            var resiCommAr: [String] = []
         */
            var resiProps: [[String:String]] = []
            var commProps: [[String:String]] = []
            
            for itemSnap in snapshot.children {
                if let _itemSnap = itemSnap as? DataSnapshot {
                    let recommData = _itemSnap.value as? [String : String] ?? [:]
                    
                    if let listingID = recommData["listingID"], listingID.count > 1 {
                        if let resiOrComm = recommData["resiOrComm"], resiOrComm == "residential" {
                            resiProps.append(recommData)
                        } else {
                            commProps.append(recommData)
                        }
                    /*
                        listIDAr.append(listingID)
                        let byEmail = recommData["byEmail"] ?? ""
                        byEmailAr.append(byEmail)
                        let byName = recommData["byName"] ?? ""
                        byNameAr.append(byName)
                        let resiOrComm = recommData["resiOrComm"] ?? ""
                        resiCommAr.append(resiOrComm)
                     */
                    } else {
                        print("Error! Could not decode recommendation data in agent")
                    }
                }
            }
            self.resiFromFIR[withEmail] = resiProps
            self.commFromFIR[withEmail] = commProps
      /*
            self.listIDDic[withEmail] = listIDAr
            self.byEmailDic[withEmail] = byEmailAr
            self.byNameDic[withEmail] = byNameAr
            self.resiCommDic[withEmail] = resiCommAr
       */
            if self.resiFromFIR.count > self.agentsArr.count - 1 {
                self.loadingPropDataFromServer()
            }
            
        })
        self.agentRecoRef[withEmail] = forAgent
        self.agentRecoRefHandle[withEmail] = theHandle
    }
    
    func loadingPropDataFromServer() {
        
        switch (self.segControll.selectedSegmentIndex) {
        case 0:
            let listIDArrResi = self.getListingIDArrayFir(firArr: self.resiFromFIR)
            if listIDArrResi.count > 0 {
              //  if !(self.propsLoadedResi) {
                    let iDCombinationResi = self.getlistIDcombination(idsArr: listIDArrResi)
                    let parameterResi: [String:Any] = ["op": "q11",
                                                       "listingids": iDCombinationResi]
                    self.connectingServer(parameterIn: parameterResi)
             //   }
             /*
                else {
                    self.updateFirebaseReco(resiCommIn: "residential")
                }
              */
            } else {
                self.dataResidentialArr.removeAll()
                self.tableView.reloadData()
            }
        case 1:
            let listIDArrComm = self.getListingIDArrayFir(firArr: self.commFromFIR)
            if listIDArrComm.count > 0 {
              //  if !(self.propsLoadedComm) {
                    let iDCombinationComm = self.getlistIDcombination(idsArr: listIDArrComm)
                    let parameterComm: [String:Any] = ["op": "q12",
                                                       "listingids": iDCombinationComm]
                    self.connectingServer(parameterIn: parameterComm)
              //  }
              /*
                else {
                    self.updateFirebaseReco(resiCommIn: "commercial")
                }
               */
            } else {
                self.dataCommercialArr.removeAll()
                self.tableView.reloadData()
            }
        default:
            return
        }
    }
    
    fileprivate func getListingIDArrayFir(firArr: [String:[[String:String]]]) -> [String] {
        var listIDArr: [String] = []
        for firPAgent in firArr.values {
            for firP in firPAgent {
                if let listIDh = firP["listingID"], !(listIDArr.contains(listIDh)) {
                    listIDArr.append(listIDh)
                }
            }
        }
        return listIDArr
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
      //  print(netWorkProvider.endpoint(.propsFilter(paras: parameterIn)).urlRequest?.description ?? "net url")
    }
    
    func parseNetworkDataProps(propArrIn: [[String:Any?]]) {
        switch (self.segControll.selectedSegmentIndex) {
        case 0:
          //  self.propsLoadedResi = true
            self.dataResidentialArr = propArrIn
            updateFirebaseReco(resiCommIn: "residential")
            self.tableView.reloadData()
        case 1:
          //  self.propsLoadedComm = true
            self.dataCommercialArr = propArrIn
            updateFirebaseReco(resiCommIn: "commercial")
            self.tableView.reloadData()
        default:
            return
        }
    }
    
    func updateFirebaseReco(resiCommIn: String) {
        if let byEmailH = UserDefaults.standard.object(forKey: uEmail) as? String, resiCommIn == "residential" {
            if let resiFirAgent = self.resiFromFIR[byEmailH] {
                let listIDArrAgent = self.getListingIDArrThisAgent(firArr: resiFirAgent)
                let listIDArrProp = self.getListingIDArrayProp(propsIn: self.dataResidentialArr)
                var listIDdeleteFir = ""
                for idH in listIDArrAgent {
                    if !(listIDArrProp.contains(idH)) {
                        listIDdeleteFir = idH
                    }
                }
                if listIDdeleteFir.count > 0 {
                    self.deleteFIRitemWithListingID(listingID: listIDdeleteFir, byEmailIn: byEmailH)
                }
            }
        } else if let byEmailH = UserDefaults.standard.object(forKey: uEmail) as? String, resiCommIn == "commercial" {
            if let commFirAgent = self.commFromFIR[byEmailH] {
                let listIDArrAgent = self.getListingIDArrThisAgent(firArr: commFirAgent)
                let listIDArrProp = self.getListingIDArrayProp(propsIn: self.dataCommercialArr)
                var listIDdeleteFir = ""
                for idH in listIDArrAgent {
                    if !(listIDArrProp.contains(idH)) {
                        listIDdeleteFir = idH
                    }
                }
                if listIDdeleteFir.count > 0 {
                    self.deleteFIRitemWithListingID(listingID: listIDdeleteFir, byEmailIn: byEmailH)
                }
            }
        } else {
            return
        }
    }
    
    func getListingIDArrayProp(propsIn: [[String:Any?]]) -> [String] {
        var listIDarr: [String] = []
        for propI in propsIn {
            if let idH = propI["ListingID"] as? String {
                listIDarr.append(idH)
            }
        }
        return listIDarr
    }
    
    func getListingIDArrThisAgent(firArr: [[String : String]]) -> [String] {
        var listIDarr: [String] = []
        for recoI in firArr {
            if let idH = recoI["listingID"], !(listIDarr.contains(idH)) {
                listIDarr.append(idH)
            }
        }
        return listIDarr
    }
    
    func addRecommendation(_ sender: UIBarButtonItem) {
        
        let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
        let customAlert = storyB.instantiateViewController(withIdentifier: "alertAddRecommSB") as! AlertAddRecommVC
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func createRecommendation(listingID: String, resiComm: String) {
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let nameNick = UserDefaults.standard.object(forKey: uNickName) as? String
        let emailH = userEmail ?? ""
        let nameNickH = nameNick ?? ""
        
        let emailCode = FirebaseNodesCreation.decodeEmail(email: emailH)
        let refPath: String = self.agentGroupID! + "/" + "recommendations" + "/" + emailCode
        let newRecoRef = FirebaseNodesCreation.getFirDBInstance().reference(withPath: refPath)
        
        let nowStamp = Date().description
        let recomm = ["byEmail": emailH,
                      "byName": nameNickH,
                      "listingID": listingID,
                      "resiOrComm": resiComm,
                      "timeStamp": nowStamp]
        
        let addNodeHH = newRecoRef.childByAutoId()
        
        addNodeHH.setValue(recomm)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //self.agentsArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (self.segControll.selectedSegmentIndex) {
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
        
        switch (self.segControll.selectedSegmentIndex) {
        case 0:
            if self.dataResidentialArr.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ResiRecommCellAgent", for: indexPath) as! ResiTableCell
                
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
                cell.setDeleteCross(enableIt: false)
                
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
                
                cell.resiTableCellDelegate = self
                
                var isFavorite: Bool = false
                if let idThis = dataAtThisRow["ListingID"] as? String {
                    for objj: NSManagedObject in self.favoriteProps {
                        if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == idThis {
                            isFavorite = true
                        }
                    }
                }
                if isFavorite {
                    cell.setHeart(showIt: true, withTapAction: false)
                } else {
                    cell.setHeart(showIt: true, withTapAction: true)
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoItemRecommCellAgent", for: indexPath) as! NoItemTableCell
                cell.noItemLabel.text = LanguageProperty.noRecommendationStr
                return cell
            }
        case 1:
            if self.dataCommercialArr.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommRecommCellAgent", for: indexPath) as! CommTableCell
                
                let dataAtThisRow = self.dataCommercialArr[indexPath.row]
                
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
                cell.setDeleteCross(enableIt: false)
                
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
                cell.propTypeValueLabel.text = dataAtThisRow["businesstype"] as? String
                
                cell.commTableCellDelegate = self
                
                var isFavorite: Bool = false
                if let idThis = dataAtThisRow["ListingID"] as? String {
                    for objj: NSManagedObject in self.favoriteProps {
                        if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == idThis {
                            isFavorite = true
                        }
                    }
                }
                if isFavorite {
                    cell.setHeart(showIt: true, withTapAction: false)
                } else {
                    cell.setHeart(showIt: true, withTapAction: true)
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoItemRecommCellAgent", for: indexPath) as! NoItemTableCell
                cell.noItemLabel.text = LanguageProperty.noRecommendationStr
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoItemRecommCellAgent", for: indexPath) as! NoItemTableCell
            cell.noItemLabel.text = LanguageProperty.noRecommendationStr
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.segControll.selectedSegmentIndex {
        case 0:
            if self.dataResidentialArr.count > 0 {
                let storyB = UIStoryboard(name: "FavoritesControllers", bundle: nil)
                let controller = storyB.instantiateViewController(withIdentifier: "PropertyDetailsVCinFavorites") as! PropertyDetailsVC
                
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
        
        switch (self.segControll.selectedSegmentIndex) {
        case 0:
            if self.dataResidentialArr.count > 0 {
                return true
            } else {
                return false
            }
        case 1:
            if self.dataCommercialArr.count > 0 {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch (self.segControll.selectedSegmentIndex) {
            case 0:
                let dataThisRow = self.dataResidentialArr[indexPath.row]
                if let idDelete = dataThisRow["ListingID"] as? String, let byEmailH = UserDefaults.standard.object(forKey: uEmail) as? String {
                    self.presentAlertOkCancel(aTitle: LanguageGeneral.deleteStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr, listingID: idDelete, byEmailIn: byEmailH, indexP: indexPath, theRow: indexPath.row, theCase: 0)
                }
            case 1:
                let dataThisRow = self.dataCommercialArr[indexPath.row]
                if let idDelete = dataThisRow["ListingID"] as? String, let byEmailH = UserDefaults.standard.object(forKey: uEmail) as? String {
                    self.presentAlertOkCancel(aTitle: LanguageGeneral.deleteStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr, listingID: idDelete, byEmailIn: byEmailH, indexP: indexPath, theRow: indexPath.row, theCase: 1)
                }
            default:
                return
            }
        }
    }
    
    func deleteFIRitemWithListingID(listingID: String, byEmailIn: String) {
        
        if let refHandle = recoDeleteHandle {
            recoDeleteRef?.removeObserver(withHandle: refHandle)
        }
        
        recoDeleteRef = self.agentRecoRef[byEmailIn]
        
        let queryForReco = recoDeleteRef?.queryOrdered(byChild: "listingID").queryEqual(toValue: listingID)
        
        recoDeleteHandle = queryForReco?.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let recoData = snapshot.value as? [String : String] ?? [:]
            
            let emailR = recoData["byEmail"] ?? ""
            
            if emailR == byEmailIn {
                
                snapshot.ref.removeValue()
                
            } else {
                print("Error! Could not delete post data in agent.")
            }
        })
        
    }
    
    func addFavorite(rowToAdd: Int, resiCommIn: String) {
        
        if resiCommIn == "residential" {
            let dataAtThisRow = self.dataResidentialArr[rowToAdd]
            if let listIDtoAdd = dataAtThisRow["ListingID"] as? String {
                var isFavorite: Bool = false
                for objj: NSManagedObject in self.favoriteProps {
                    if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == listIDtoAdd {
                        isFavorite = true
                    }
                }
                if !isFavorite {
                    _ = CoreDataController.createFavoriteEntity(listID: listIDtoAdd, resiComm: "residential")
                    self.favoriteProps = CoreDataController.fetchFavoriteProps()
                    self.broadNotify(resiCommIn: "residential")
                }
            }
        } else if resiCommIn == "commercial" {
            let dataAtThisRow = self.dataCommercialArr[rowToAdd]
            if let listIDtoAdd = dataAtThisRow["ListingID"] as? String {
                var isFavorite: Bool = false
                for objj: NSManagedObject in self.favoriteProps {
                    if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == listIDtoAdd {
                        isFavorite = true
                    }
                }
                if !isFavorite {
                    _ = CoreDataController.createFavoriteEntity(listID: listIDtoAdd, resiComm: "commercial")
                    self.favoriteProps = CoreDataController.fetchFavoriteProps()
                    self.broadNotify(resiCommIn: "commercial")
                }
            }
        } else {
            return
        }
    }
    
    fileprivate func broadNotify(resiCommIn: String) {
        let key = "keyStr"
        let newValue = resiCommIn
        let dictionaryInfo = [key: newValue]
        noteCenter.post(name: NSNotification.Name(rawValue: "AddFavoriteFromRecommAgent"), object: nil, userInfo: dictionaryInfo)
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    fileprivate func presentAlertOkCancel(aTitle: String?, withMsg: String?, confirmTitle: String?, listingID: String, byEmailIn: String, indexP: IndexPath, theRow: Int, theCase: Int) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let okHandler: Handler = {action in
            self.deleteFIRitemWithListingID(listingID: listingID, byEmailIn: byEmailIn)
          //  self.tableView.deleteRows(at: [indexP], with: .fade)
         /*
            switch theCase {
            case 0:
                self.dataResidentialArr.remove(at: theRow)
                self.tableView.deleteRows(at: [indexP], with: .fade)
            case 1:
                self.dataCommercialArr.remove(at: theRow)
                self.tableView.deleteRows(at: [indexP], with: .fade)
            default:
                return
            }
          */
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
        if let refHandle = recoDeleteHandle {
            recoDeleteRef?.removeObserver(withHandle: refHandle)
        }
        for dAgent in self.agentsArr {
            if let aaEmail = dAgent["email"], aaEmail.count > 0 {
                if let refHandle = self.agentRecoRefHandle[aaEmail] {
                    self.agentRecoRef[aaEmail]?.removeObserver(withHandle: refHandle)
                }
                self.agentRecoRef.removeValue(forKey: aaEmail)
                self.agentRecoRefHandle.removeValue(forKey: aaEmail)
            }
        }
        noteCenter.removeObserver(self)
    }
}

extension RecommendationVCAgent: AlertAddRecommDelegate {
    
    func cancellBtnTapped() {
        
    }
    
    func addBtnTapped(listIDStr: String, resiCommStr: String) {
        
        if listIDStr.count > 1 {
            self.createRecommendation(listingID: listIDStr, resiComm: resiCommStr)
        } else {
            self.presentAlert(aTitle: LanguageGeneral.errMsgNeedAllFieldsStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr)
        }
    }
}

extension RecommendationVCAgent: ResiTableCellDelegate {
    func toAddFavoriteResi(_ cellView: ResiTableCell) {
        let likedRow = self.tableView.indexPath(for: cellView)
        if let _likedRow = likedRow?.row {
            self.addFavorite(rowToAdd: _likedRow, resiCommIn: "residential")
        }
    }
}

extension RecommendationVCAgent: CommTableCellDelegate {
    func toAddFavoriteComm(_ cellView: CommTableCell) {
        let likedRow = self.tableView.indexPath(for: cellView)
        if let _likedRow = likedRow?.row {
            self.addFavorite(rowToAdd: _likedRow, resiCommIn: "commercial")
        }
    }
}
