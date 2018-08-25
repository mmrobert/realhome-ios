//
//  SearchListVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-16.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import AlamofireImage
import CoreData

class SearchListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchTableView: UITableView!
    
    var favoriteProps: [NSManagedObject] = []
    
    public var resi_comm: String?
    public var stateSearch: String?
    public var coorsToList: [String:CLLocationCoordinate2D] = [:]
    public var propsToList: [[String:Any?]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        self.searchTableView.estimatedRowHeight = 50.0
        self.searchTableView.rowHeight = UITableViewAutomaticDimension
        
        self.favoriteProps = CoreDataController.fetchFavoriteProps()
        
        noteCenter.addObserver(self, selector: #selector(SearchListVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoriteProps = CoreDataController.fetchFavoriteProps()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.searchTableView.reloadData()
    }
    
    // MARK: - tableview datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resi_comm != nil {
            return self.propsToList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let resiComm = self.resi_comm {
            if resiComm == "residential" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchResiCell", for: indexPath) as! SearchResidentialTableCell
                
                let dataAtThisRow = self.propsToList[indexPath.row]
                
                if let imgUrlH = dataAtThisRow["photo1url"] as? String {
                    if let _ = URL(string: imgUrlH) {
                        Alamofire.request(imgUrlH).responseImage { response in
                            if let image = response.result.value {
                                cell.photo1.image = image
                            }
                        }
                    }
                }
                
                cell.bldgType.text = dataAtThisRow["bldgtype"] as? String
                cell.saleOrRentLabel.text = dataAtThisRow["salerent"] as? String
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
                cell.bedsValueLabel.text = dataAtThisRow["BedroomsTotal"] as? String
                cell.bathsValueLabel.text = dataAtThisRow["BathroomTotal"] as? String
                
                var isFavorite: Bool = false
                if let idThis = dataAtThisRow["ListingID"] as? String {
                    for objj: NSManagedObject in self.favoriteProps {
                        if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == idThis {
                            isFavorite = true
                        }
                    }
                }
                if isFavorite {
                    cell.heartImg.isUserInteractionEnabled = false
                    cell.heartImg.image = UIImage(named: "heartfull")
                } else {
                    cell.heartImg.isUserInteractionEnabled = true
                    cell.heartImg.image = UIImage(named: "heartempty")
                }
                
                cell.setCaptionsLabel()
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchCommCell", for: indexPath) as! SearchCommercialTableCell
                
                let dataAtThisRow = self.propsToList[indexPath.row]
                
                if let imgUrlH = dataAtThisRow["photo1url"] as? String {
                    if let _ = URL(string: imgUrlH) {
                        Alamofire.request(imgUrlH).responseImage { response in
                            if let image = response.result.value {
                                cell.photo1.image = image
                            }
                        }
                    }
                }
                
                cell.saleOrRentLabel.text = dataAtThisRow["salerent"] as? String
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
                cell.propertyTypeValueLabel.text = dataAtThisRow["businesstype"] as? String
                
                var isFavorite: Bool = false
                if let idThis = dataAtThisRow["ListingID"] as? String {
                    for objj: NSManagedObject in self.favoriteProps {
                        if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == idThis {
                            isFavorite = true
                        }
                    }
                }
                if isFavorite {
                    cell.heartImg.isUserInteractionEnabled = false
                    cell.heartImg.image = UIImage(named: "heartfull")
                } else {
                    cell.heartImg.isUserInteractionEnabled = true
                    cell.heartImg.image = UIImage(named: "heartempty")
                }
                
                cell.setCaptionsLabel()
                
                return cell
            }
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let resiComm = self.resi_comm {
            if resiComm == "residential" {
                if self.propsToList.count > 0 {
                    let storyB = UIStoryboard(name: "FavoritesControllers", bundle: nil)
                    let controller = storyB.instantiateViewController(withIdentifier: "PropertyDetailsVCinFavorites") as! PropertyDetailsVC
              //      controller.hidesBottomBarWhenPushed = true
                    let objAti = self.propsToList[indexPath.row]
                    let listIDAti = objAti["ListingID"] as? String
                    controller.listingIDPassedIn = listIDAti
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
                    if let _listIDAti = listIDAti, let coorAti = self.coorsToList[_listIDAti] {
                        controller.latitudePassedIn = String(describing: coorAti.latitude)
                        controller.longitudePassedIn = String(describing: coorAti.longitude)
                    } else {
                        controller.latitudePassedIn = ""
                        controller.longitudePassedIn = ""
                    }
                    controller.bldgTypePassedIn = objAti["bldgtype"] as? String
                    controller.statePassedIn = self.stateSearch
                    if (self.responds(to: #selector(self.show(_:sender:)))) {
                        self.show(controller, sender: self)
                    } else {
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            } else {
                if self.propsToList.count > 0 {
                    let storyB = UIStoryboard(name: "FavoritesControllers", bundle: nil)
                    let controller = storyB.instantiateViewController(withIdentifier: "PropertyDetailsCommVCinFavorites") as! PropertyDetailsCommVC
              //      controller.hidesBottomBarWhenPushed = true
                    let objAti = self.propsToList[indexPath.row]
                    let listIDAti = objAti["ListingID"] as? String
                    controller.listingIDPassedIn = listIDAti
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
                    if let _listIDAti = listIDAti, let coorAti = self.coorsToList[_listIDAti] {
                        controller.latitudePassedIn = String(describing: coorAti.latitude)
                        controller.longitudePassedIn = String(describing: coorAti.longitude)
                    } else {
                        controller.latitudePassedIn = ""
                        controller.longitudePassedIn = ""
                    }
                    controller.busiTypePassedIn = objAti["businesstype"] as? String
                    if (self.responds(to: #selector(self.show(_:sender:)))) {
                        self.show(controller, sender: self)
                    } else {
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func addFavorite(rowToAdd: Int) {
        
        if let resiComm = self.resi_comm {
            let dataAtThisRow = self.propsToList[rowToAdd]
            if let listIDtoAdd = dataAtThisRow["ListingID"] as? String {
                var isFavorite: Bool = false
                for objj: NSManagedObject in self.favoriteProps {
                    if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == listIDtoAdd {
                        isFavorite = true
                    }
                }
                if !isFavorite {
                    if resiComm == "residential" {
                        _ = CoreDataController.createFavoriteEntity(listID: listIDtoAdd, resiComm: "residential")
                        self.favoriteProps = CoreDataController.fetchFavoriteProps()
                        self.broadNotify(resiCommIn: "residential")
                    } else {
                        _ = CoreDataController.createFavoriteEntity(listID: listIDtoAdd, resiComm: "commercial")
                        self.favoriteProps = CoreDataController.fetchFavoriteProps()
                        self.broadNotify(resiCommIn: "commercial")
                    }
                }
            }
        }
    }
    
    fileprivate func broadNotify(resiCommIn: String) {
        let key = "keyStr"
        let newValue = resiCommIn
        let dictionaryInfo = [key: newValue]
        noteCenter.post(name: NSNotification.Name(rawValue: "AddFavoriteFromSearchList"), object: nil, userInfo: dictionaryInfo)
    }
    
    deinit {
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

extension SearchListVC: SearchResiDelegate {
    func toAddResiFavorite(_ cellView: SearchResidentialTableCell) {
        let likedRow = self.searchTableView.indexPath(for: cellView)
        if let _likedRow = likedRow?.row {
            addFavorite(rowToAdd: _likedRow)
        }
    }
}

extension SearchListVC: SearchCommDelegate {
    func toAddCommFavorite(_ cellView: SearchCommercialTableCell) {
        let likedRow = self.searchTableView.indexPath(for: cellView)
        if let _likedRow = likedRow?.row {
            addFavorite(rowToAdd: _likedRow)
        }
    }
}
