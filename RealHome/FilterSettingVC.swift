//
//  FilterSettingVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-17.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class FilterSettingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let bldgTypeSavedArray = [all, house, rowTownhouse, condoApartment, duplex, triplex, fourplex, gardenHome, mobileHome, manufacturedHome, recreationalCottage]
    let propertyTypeSavedArray = [all, business, retail, office, industrial, hospitality, institutional, agriculture, vacantLand]
    let basementSavedArray = [all, finished, unfinished, none, partial, separated_entrance, walk_out, crawl_space, walk_up, slab]
    
    var bldgTypeArray = [LanguageProperty.allStr, LanguageProperty.houseStr, LanguageProperty.rowTownhouseStr, LanguageProperty.condoApartmentStr, LanguageProperty.duplexStr, LanguageProperty.triplexStr, LanguageProperty.fourplexStr, LanguageProperty.gardenHomeStr, LanguageProperty.mobileHomeStr, LanguageProperty.manufacturedHomeStr, LanguageProperty.recreationalCottageStr]
    var propertyTypeArray = [LanguageProperty.allStr, LanguageProperty.businessStr, LanguageProperty.retailStr, LanguageProperty.officeStr, LanguageProperty.industrialStr, LanguageProperty.hospitalityStr, LanguageProperty.institutionalStr, LanguageProperty.agricultureStr, LanguageProperty.vacantLandStr]
    var basementArray = [LanguageProperty.allStr, LanguageProperty.finishedStr, LanguageProperty.unfinishedStr, LanguageProperty.noneStr, LanguageProperty.partialStr, LanguageProperty.separated_entranceStr, LanguageProperty.walk_outStr, LanguageProperty.crawl_spaceStr, LanguageProperty.walk_upStr, LanguageProperty.slabStr]
    
    @IBOutlet weak var segController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelItemBtn: UIBarButtonItem!
    @IBOutlet weak var searchItemBtn: UIBarButtonItem!
    
    var oldResiComm: String?
    var oldSaleRent: String?
    var oldBldgType: String?
    var oldMinPrice: Double?
    var oldMaxPrice: Double?
    var oldMinRooms: Int?
    var oldMaxRooms: Int?
    var oldMinBaths: Int?
    var oldMaxBaths: Int?
    var oldMinGarage: Int?
    var oldMaxGarage: Int?
    var oldBasement: String?
    var oldOpenHouse: Bool?
    var oldPropType: String?
    var oldMinAreaSize: Double?
    var oldMaxAreaSize: Double?
    
    var newResiComm: String?
    var newSaleRent: String?
    var newBldgType: String?
    var newMinPrice: Double?
    var newMaxPrice: Double?
    var newMinRooms: Int?
    var newMaxRooms: Int?
    var newMinBaths: Int?
    var newMaxBaths: Int?
    var newMinGarage: Int?
    var newMaxGarage: Int?
    var newBasement: String?
    var newOpenHouse: Bool?
    var newPropType: String?
    var newMinAreaSize: Double?
    var newMaxAreaSize: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cancelItemBtn.title = LanguageGeneral.cancelStr
        self.searchItemBtn.title = LanguageGeneral.searchStr

        // Do any additional setup after loading the view.
        
        self.segController.setTitle(LanguageProperty.residentialStr, forSegmentAt: 0)
        self.segController.setTitle(LanguageProperty.commercialStr, forSegmentAt: 1)
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(FilterSettingVC.newBldgTypeChoosed(note:)), name: NSNotification.Name(rawValue: "BldgTypeChosed"), object: nil)
        noteCenter.addObserver(self, selector: #selector(FilterSettingVC.newBasementChoosed(note:)), name: NSNotification.Name(rawValue: "BasementChosed"), object: nil)
        noteCenter.addObserver(self, selector: #selector(FilterSettingVC.newPropChoosed(note:)), name: NSNotification.Name(rawValue: "PropTypeChosed"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(FilterSettingVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        self.prepareData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.cancelItemBtn.title = LanguageGeneral.cancelStr
        self.searchItemBtn.title = LanguageGeneral.searchStr
        self.segController.setTitle(LanguageProperty.residentialStr, forSegmentAt: 0)
        self.segController.setTitle(LanguageProperty.commercialStr, forSegmentAt: 1)
        
        bldgTypeArray = [LanguageProperty.allStr, LanguageProperty.houseStr, LanguageProperty.rowTownhouseStr, LanguageProperty.condoApartmentStr, LanguageProperty.duplexStr, LanguageProperty.triplexStr, LanguageProperty.fourplexStr, LanguageProperty.gardenHomeStr, LanguageProperty.mobileHomeStr, LanguageProperty.manufacturedHomeStr, LanguageProperty.recreationalCottageStr]
        
        propertyTypeArray = [LanguageProperty.allStr, LanguageProperty.businessStr, LanguageProperty.retailStr, LanguageProperty.officeStr, LanguageProperty.industrialStr, LanguageProperty.hospitalityStr, LanguageProperty.institutionalStr, LanguageProperty.agricultureStr, LanguageProperty.vacantLandStr]
        
        basementArray = [LanguageProperty.allStr, LanguageProperty.finishedStr, LanguageProperty.unfinishedStr, LanguageProperty.noneStr, LanguageProperty.partialStr, LanguageProperty.separated_entranceStr, LanguageProperty.walk_outStr, LanguageProperty.crawl_spaceStr, LanguageProperty.walk_upStr, LanguageProperty.slabStr]
        
        self.tableView.reloadData()
    }
    
    fileprivate func prepareData() {
        
        let tempResiComm = UserDefaults.standard.object(forKey: resiOrCommSearch) as? String
        
        if let _tempResiComm = tempResiComm, _tempResiComm.count > 0 {
            self.oldResiComm = _tempResiComm
            self.newResiComm = self.oldResiComm
        } else {
            self.oldResiComm = "residential"
            self.newResiComm = self.oldResiComm
        }
        if self.newResiComm == "commercial" {
            self.segController.selectedSegmentIndex = 1
        } else {
            self.segController.selectedSegmentIndex = 0
        }
        
        let tempSaleRent = UserDefaults.standard.object(forKey: saleRentSearch) as? String
        
        if let _tempSaleRent = tempSaleRent, _tempSaleRent.count > 0 {
            self.oldSaleRent = _tempSaleRent
            self.newSaleRent = self.oldSaleRent
        } else {
            self.oldSaleRent = "for sale"
            self.newSaleRent = self.oldSaleRent
        }
        
        let tempBldgType = UserDefaults.standard.object(forKey: bldgTypeSearch) as? String
        
        if let _tempBldgType = tempBldgType, _tempBldgType.count > 0 {
            self.oldBldgType = _tempBldgType
            self.newBldgType = self.oldBldgType
        } else {
            self.oldBldgType = all
            self.newBldgType = self.oldBldgType
        }
        
        let tempMinPrice = UserDefaults.standard.object(forKey: minPriceSearch) as? Double
        
        if let _tempMinPrice = tempMinPrice {
            self.oldMinPrice = _tempMinPrice
            self.newMinPrice = self.oldMinPrice
        } else {
            self.oldMinPrice = Double(minPriceInit)
            self.newMinPrice = self.oldMinPrice
        }
        
        let tempMaxPrice = UserDefaults.standard.object(forKey: maxPriceSearch) as? Double
        
        if let _tempMaxPrice = tempMaxPrice {
            self.oldMaxPrice = _tempMaxPrice
            self.newMaxPrice = self.oldMaxPrice
        } else {
            self.oldMaxPrice = Double(maxPriceInit)
            self.newMaxPrice = self.oldMaxPrice
        }
        
        let tempMinRooms = UserDefaults.standard.object(forKey: minRoomsSearch) as? Int
        
        if let _tempMinRooms = tempMinRooms {
            self.oldMinRooms = _tempMinRooms
            self.newMinRooms = self.oldMinRooms
        } else {
            self.oldMinRooms = minRoomsInit
            self.newMinRooms = self.oldMinRooms
        }
        
        let tempMaxRooms = UserDefaults.standard.object(forKey: maxRoomsSearch) as? Int
        
        if let _tempMaxRooms = tempMaxRooms {
            self.oldMaxRooms = _tempMaxRooms
            self.newMaxRooms = self.oldMaxRooms
        } else {
            self.oldMaxRooms = maxRoomsInit
            self.newMaxRooms = self.oldMaxRooms
        }
        
        let tempMinBaths = UserDefaults.standard.object(forKey: minBathsSearch) as? Int
        
        if let _tempMinBaths = tempMinBaths {
            self.oldMinBaths = _tempMinBaths
            self.newMinBaths = self.oldMinBaths
        } else {
            self.oldMinBaths = minBathsInit
            self.newMinBaths = self.oldMinBaths
        }
        
        let tempMaxBaths = UserDefaults.standard.object(forKey: maxBathsSearch) as? Int
        
        if let _tempMaxBaths = tempMaxBaths {
            self.oldMaxBaths = _tempMaxBaths
            self.newMaxBaths = self.oldMaxBaths
        } else {
            self.oldMaxBaths = maxBathsInit
            self.newMaxBaths = self.oldMaxBaths
        }
        
        let tempMinGarage = UserDefaults.standard.object(forKey: minGarageSearch) as? Int
        
        if let _tempMinGarage = tempMinGarage {
            self.oldMinGarage = _tempMinGarage
            self.newMinGarage = self.oldMinGarage
        } else {
            self.oldMinGarage = minGarageInit
            self.newMinGarage = self.oldMinGarage
        }
        
        let tempMaxGarage = UserDefaults.standard.object(forKey: maxGarageSearch) as? Int
        
        if let _tempMaxGarage = tempMaxGarage {
            self.oldMaxGarage = _tempMaxGarage
            self.newMaxGarage = self.oldMaxGarage
        } else {
            self.oldMaxGarage = maxGarageInit
            self.newMaxGarage = self.oldMaxGarage
        }
        
        let tempBasement = UserDefaults.standard.object(forKey: basementSearch) as? String
        
        if let _tempBasement = tempBasement, _tempBasement.count > 0 {
            self.oldBasement = _tempBasement
            self.newBasement = self.oldBasement
        } else {
            self.oldBasement = all
            self.newBasement = self.oldBasement
        }
        
        let tempOpenHouse = UserDefaults.standard.object(forKey: openHouseSearch) as? Bool
        
        if let _tempOpenHouse = tempOpenHouse {
            self.oldOpenHouse = _tempOpenHouse
            self.newOpenHouse = self.oldOpenHouse
        } else {
            self.oldOpenHouse = false
            self.newOpenHouse = self.oldOpenHouse
        }
        
        let tempPropType = UserDefaults.standard.object(forKey: propTypeSearch) as? String
        
        if let _tempPropType = tempPropType, _tempPropType.count > 0 {
            self.oldPropType = _tempPropType
            self.newPropType = self.oldPropType
        } else {
            self.oldPropType = all
            self.newPropType = self.oldPropType
        }
        
        let tempMinAreaSize = UserDefaults.standard.object(forKey: minAreaSizeSearch) as? Double
        
        if let _tempMinAreaSize = tempMinAreaSize {
            self.oldMinAreaSize = _tempMinAreaSize
            self.newMinAreaSize = self.oldMinAreaSize
        } else {
            self.oldMinAreaSize = Double(minAreaSizeInit)
            self.newMinAreaSize = self.oldMinAreaSize
        }
        
        let tempMaxAreaSize = UserDefaults.standard.object(forKey: maxAreaSizeSearch) as? Double
        
        if let _tempMaxAreaSize = tempMaxAreaSize {
            self.oldMaxAreaSize = _tempMaxAreaSize
            self.newMaxAreaSize = self.oldMaxAreaSize
        } else {
            self.oldMaxAreaSize = Double(maxAreaSizeInit)
            self.newMaxAreaSize = self.oldMaxAreaSize
        }
    }
    
    @objc fileprivate func newBldgTypeChoosed(note: NSNotification) {
        let key = "keyStr"
        let userInformation = note.userInfo as? [String:Any]
        self.newBldgType = userInformation?[key] as? String
        self.tableView.reloadData()
    }
    
    @objc fileprivate func newBasementChoosed(note: NSNotification) {
        let key = "keyStr"
        let userInformation = note.userInfo as? [String:Any]
        self.newBasement = userInformation?[key] as? String
        self.tableView.reloadData()
    }
    
    @objc fileprivate func newPropChoosed(note: NSNotification) {
        let key = "keyStr"
        let userInformation = note.userInfo as? [String:Any]
        self.newPropType = userInformation?[key] as? String
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (self.segController.selectedSegmentIndex) {
        case 0:
            return 8
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (self.segController.selectedSegmentIndex) {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "saleRentCellInFilter", for: indexPath) as! SaleRentChooseTableCell
                
                cell.forSaleBtn.setTitle(LanguageProperty.forSaleStr, for: .normal)
                cell.forRentBtn.setTitle(LanguageProperty.forRentStr, for: .normal)
                if let _newSaleRent = self.newSaleRent, _newSaleRent == "for sale" {
                    cell.forSaleBtn.isSelected = true
                } else if let _newSaleRent = self.newSaleRent, _newSaleRent == "for rent" {
                    cell.forRentBtn.isSelected = true
                }
                cell.saleRentChoiceDelegate = self
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "bldgTypeCellInFilter", for: indexPath)
                cell.textLabel?.text = LanguageProperty.bldgTypeStr
                if let _newBldgType = self.newBldgType, let indexOfType = bldgTypeSavedArray.index(of: _newBldgType) {
                    cell.detailTextLabel?.text = bldgTypeArray[indexOfType]
                } else {
                    cell.detailTextLabel?.text = LanguageProperty.allStr
                }
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "priceRangeCellInFilter", for: indexPath) as! PriceRangeTableCell
                
                cell.setCaptionsLabel()
            //    cell.setKBDoneLabel()
                if let _minP = self.newMinPrice, let _maxP = self.newMaxPrice {
                    cell.setLowerUpperValue(lowerV: _minP, upperV: _maxP)
                }
                cell.changePriceDelegate = self
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "bedsRoomCellInFilter", for: indexPath) as! BedsRoomTableCell
                cell.bedsRoomLabel.text = LanguageProperty.bedRoomsStr
                if let _minR = self.newMinRooms, let _maxR = self.newMaxRooms {
                    cell.setLowerUpperValue(lowerV: Double(_minR), upperV: Double(_maxR))
                }
                cell.bedsRoomChoiceDelegate = self
                return cell
            } else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "bathsRoomCellInFilter", for: indexPath) as! BathsRoomTableCell
                cell.bathsRoomLabel.text = LanguageProperty.bathRoomsStr
                if let _minB = self.newMinBaths, let _maxB = self.newMaxBaths {
                    cell.setLowerUpperValue(lowerV: Double(_minB), upperV: Double(_maxB))
                }
                cell.bathsRoomChoiceDelegate = self
                return cell
            } else if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "garageCellInFilter", for: indexPath) as! GarageTableCell
                cell.garageLabel.text = LanguageProperty.garageStr
                if let _minG = self.newMinGarage, let _maxG = self.newMaxGarage {
                    cell.setLowerUpperValue(lowerV: Double(_minG), upperV: Double(_maxG))
                }
                cell.garageChoiceDelegate = self
                return cell
            } else if indexPath.row == 6 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "basementCellInFilter", for: indexPath)
                cell.textLabel?.text = LanguageProperty.basementStr
                if let _newBasement = self.newBasement, let indexOfType = basementSavedArray.index(of: _newBasement) {
                    cell.detailTextLabel?.text = basementArray[indexOfType]
                } else {
                    cell.detailTextLabel?.text = LanguageProperty.allStr
                }
                return cell
            } else if indexPath.row == 7 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "openHouseCellInFilter", for: indexPath) as! OpenHouseTableCell
                
                cell.openHouseLabel.text = LanguageProperty.openHouseStr
                if let _newOpenHouse = self.newOpenHouse, _newOpenHouse == true {
                    cell.switch.setOn(true, animated: false)
                } else {
                    cell.switch.setOn(false, animated: false)
                }
                cell.openHouseChoiceDelegate = self
                
                return cell
            } else {
                let cell = UITableViewCell()
                return cell
            }
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "saleRentCellInFilter", for: indexPath) as! SaleRentChooseTableCell
                
                cell.forSaleBtn.setTitle(LanguageProperty.forSaleStr, for: .normal)
                cell.forRentBtn.setTitle(LanguageProperty.forRentStr, for: .normal)
                if let _newSaleRent = self.newSaleRent, _newSaleRent == "for sale" {
                    cell.forSaleBtn.isSelected = true
                } else if let _newSaleRent = self.newSaleRent, _newSaleRent == "for rent" {
                    cell.forRentBtn.isSelected = true
                }
                cell.saleRentChoiceDelegate = self
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "propertyTypeCellInFilter", for: indexPath)
                cell.textLabel?.text = LanguageProperty.propertyTypeStr
                if let _newPropType = self.newPropType, let indexOfType = propertyTypeSavedArray.index(of: _newPropType) {
                    cell.detailTextLabel?.text = propertyTypeArray[indexOfType]
                } else {
                    cell.detailTextLabel?.text = LanguageProperty.allStr
                }
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "priceRangeCellInFilter", for: indexPath) as! PriceRangeTableCell
                
                cell.setCaptionsLabel()
             //   cell.setKBDoneLabel()
                if let _minP = self.newMinPrice, let _maxP = self.newMaxPrice {
                    cell.setLowerUpperValue(lowerV: _minP, upperV: _maxP)
                }
                cell.changePriceDelegate = self
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "areaSizeCellInFilter", for: indexPath) as! AreaSizeTableCell
                cell.areaSizeLabel.text = LanguageProperty.areaSizeStr
                cell.areaUnitLabel.text = LanguageProperty.areaUnitStr
                if let _minA = self.newMinAreaSize, let _maxA = self.newMaxAreaSize {
                    cell.setLowerUpperValue(lowerV: _minA, upperV: _maxA)
                }
                cell.areaSizeChoiceDelegate = self
                return cell
            } else {
                let cell = UITableViewCell()
                return cell
            }
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    @IBAction func segSelectedAct(_ sender: Any) {
     //   print(self.segController.selectedSegmentIndex)
        if self.segController.selectedSegmentIndex == 0 {
            self.newResiComm = "residential"
        } else {
            self.newResiComm = "commercial"
        }
        self.tableView.reloadData()
    }
    
    @IBAction func searchItemAct(_ sender: Any) {
        
        if self.newResiComm == "commercial" {
            let checkChanged = self.oldResiComm != self.newResiComm || self.oldSaleRent != self.newSaleRent || self.oldMinPrice != self.newMinPrice || self.oldMaxPrice != self.newMaxPrice || self.oldPropType != self.newPropType || self.oldMinAreaSize != self.newMinAreaSize || self.oldMaxAreaSize != self.newMaxAreaSize
            if checkChanged {
                UserDefaults.standard.set(true, forKey: isSearchFilterChanged)
                UserDefaults.standard.set(self.newResiComm, forKey: resiOrCommSearch)
                UserDefaults.standard.set(self.newSaleRent, forKey: saleRentSearch)
                UserDefaults.standard.set(self.newMinPrice, forKey: minPriceSearch)
                UserDefaults.standard.set(self.newMaxPrice, forKey: maxPriceSearch)
                UserDefaults.standard.set(self.newPropType, forKey: propTypeSearch)
                UserDefaults.standard.set(self.newMinAreaSize, forKey: minAreaSizeSearch)
                UserDefaults.standard.set(self.newMaxAreaSize, forKey: maxAreaSizeSearch)
                
                UserDefaults.standard.synchronize()
            }
        } else {
            let checkChanged = self.oldResiComm != self.newResiComm || self.oldSaleRent != self.newSaleRent || self.oldBldgType != self.newBldgType || self.oldMinPrice != self.newMinPrice || self.oldMaxPrice != self.newMaxPrice || self.oldMinRooms != self.newMinRooms || self.oldMaxRooms != self.newMaxRooms || self.oldMinBaths != self.newMinBaths || self.oldMaxBaths != self.newMaxBaths || self.oldMinGarage != self.newMinGarage || self.oldMaxGarage != self.newMaxGarage || self.oldBasement != self.newBasement || self.oldOpenHouse != self.newOpenHouse
            if checkChanged {
                UserDefaults.standard.set(true, forKey: isSearchFilterChanged)
                UserDefaults.standard.set(self.newResiComm, forKey: resiOrCommSearch)
                UserDefaults.standard.set(self.newSaleRent, forKey: saleRentSearch)
                UserDefaults.standard.set(self.newBldgType, forKey: bldgTypeSearch)
                UserDefaults.standard.set(self.newMinPrice, forKey: minPriceSearch)
                UserDefaults.standard.set(self.newMaxPrice, forKey: maxPriceSearch)
                UserDefaults.standard.set(self.newMinRooms, forKey: minRoomsSearch)
                UserDefaults.standard.set(self.newMaxRooms, forKey: maxRoomsSearch)
                UserDefaults.standard.set(self.newMinBaths, forKey: minBathsSearch)
                UserDefaults.standard.set(self.newMaxBaths, forKey: maxBathsSearch)
                UserDefaults.standard.set(self.newMinGarage, forKey: minGarageSearch)
                UserDefaults.standard.set(self.newMaxGarage, forKey: maxGarageSearch)
                UserDefaults.standard.set(self.newBasement, forKey: basementSearch)
                UserDefaults.standard.set(self.newOpenHouse, forKey: openHouseSearch)
                
                UserDefaults.standard.synchronize()
            }
        }
        
        self.performSegue(withIdentifier: "filterReturnToSearch", sender: self)
    }
    
    @IBAction func cancelItemAct(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toBldgTypeChooseVC" {
            let bldgTVC = segue.destination as! BldgTypeChooseVC
            bldgTVC.chosedBldgType = self.newBldgType
        } else if segue.identifier == "toBasementChoose" {
            let basementVC = segue.destination as! BasementChooseVC
            basementVC.chosedBasement = self.newBasement
        } else if segue.identifier == "toPropTypeChoose" {
            let propVC = segue.destination as! PropertyTypeChooseVC
            propVC.chosedPropType = self.newPropType
        }
    }
    
    deinit {
        noteCenter.removeObserver(self)
    }
}

extension FilterSettingVC: SaleRentChoiceSearch {
    func toChangeSaleRent(_ cellView: SaleRentChooseTableCell, saleOrRent: String) {
        self.newSaleRent = saleOrRent
    }
}

extension FilterSettingVC: PriceChangeSearch {
    func toChangePrice(_ cellView: PriceRangeTableCell, _ newtxValue: Double, _ viewTag: Int) {
        if viewTag == 1 {
            self.newMinPrice = newtxValue
        } else {
            self.newMaxPrice = newtxValue
        }
    }
}

extension FilterSettingVC: BedsRoomChangeSearch {
    func toChangeBedsRoom(_ cellView: BedsRoomTableCell, minRooms: Int, maxRooms: Int) {
        self.newMinRooms = minRooms
        self.newMaxRooms = maxRooms
    }
}

extension FilterSettingVC: BathsRoomChangeSearch {
    func toChangeBathsRoom(_ cellView: BathsRoomTableCell, minRooms: Int, maxRooms: Int) {
        self.newMinBaths = minRooms
        self.newMaxBaths = maxRooms
    }
}

extension FilterSettingVC: GarageChangeSearch {
    func toChangeGarage(_ cellView: GarageTableCell, minPark: Int, maxPark: Int) {
        self.newMinGarage = minPark
        self.newMaxGarage = maxPark
    }
}

extension FilterSettingVC: OpenHouseChoiceSearch {
    func toChangeOpenHouse(_ cellView: OpenHouseTableCell, openHouse: Bool) {
        self.newOpenHouse = openHouse
    }
}

extension FilterSettingVC: AreaSizeChangeSearch {
    func toChangeAreaSize(_ cellView: AreaSizeTableCell, minArea: Double, maxArea: Double) {
        self.newMinAreaSize = minArea
        self.newMaxAreaSize = maxArea
    }
}



