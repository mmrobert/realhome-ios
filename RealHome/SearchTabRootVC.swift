//
//  SearchTabRootVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Cluster
import MBProgressHUD
import CoreData
import Firebase

protocol AddAgentGroup: class {
    func toAddAgentGroup(role: String) -> Void
}

class SearchTabRootVC: UIViewController {

    @IBOutlet weak var filterContainer: UIView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var listContainer: UIView!
    @IBOutlet weak var listLabel: UILabel!
    
    @IBOutlet weak var signInItemBtn: UIBarButtonItem!
    
    @IBOutlet weak var searchMap: MKMapView!
    
    @IBOutlet weak var cityContainer: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    
    let clusterManager = ClusterManager()
    
    weak var resiCardView: ResidentialCardView?
    weak var commCardView: CommercialCardView?
    var isCardViewShowing: Bool = false
    var cardOriginY: CGFloat = 0
    
    var stateForSearch: String?
    var cityForSearch: String?
    var cityLatiForSearch: String?
    var cityLongForSearch: String?
    var resiCommForSearch: String?
    var saleRentForSearch: String?
    var bldgTypeForSearch: String?
    var minPriceForSearch: Double?
    var maxPriceForSearch: Double?
    var minRoomsForSearch: Int?
    var maxRoomsForSearch: Int?
    var minBathsForSearch: Int?
    var maxBathsForSearch: Int?
    var minGarageForSearch: Int?
    var maxGarageForSearch: Int?
    var basementForSearch: String?
    var openHouseForSearch: Bool?
    var propTypeForSearch: String?
    var minAreaSizeForSearch: Double?
    var maxAreaSizeForSearch: Double?
    
    public weak var agentGroupDelegate: AddAgentGroup?
    
    var propertiesArr: [[String:Any?]] = []
    
   // var llocs: [CLLocationCoordinate2D] = []
    var llocs: [[String:Any]] = []
    
    var propsIDtoList: [String] = []
    var coorsToList: [String:CLLocationCoordinate2D] = [:]
    var propsToList: [[String:Any?]] = []
    
    var favoriteProps: [NSManagedObject] = []
    
    var userRef: DatabaseReference? // agents or buyers
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        self.filterLabel.text = LanguageProperty.filterStr
        self.listLabel.text = LanguageProperty.listStr
        
        self.favoriteProps = CoreDataController.fetchFavoriteProps()
        
        self.prepareSearchData()
        self.cityLabel.text = self.cityForSearch
        
        self.addCardView()
        
        let tapForCity = UITapGestureRecognizer(target: self, action: #selector(SearchTabRootVC.chooseCityTap(regognizer:)))
        self.cityContainer.isUserInteractionEnabled = true
        self.cityContainer.addGestureRecognizer(tapForCity)
        
        let tapForFilter = UITapGestureRecognizer(target: self, action: #selector(SearchTabRootVC.modifyFilterTap(regognizer:)))
        self.filterContainer.isUserInteractionEnabled = true
        self.filterContainer.addGestureRecognizer(tapForFilter)
        
        let tapForListing = UITapGestureRecognizer(target: self, action: #selector(SearchTabRootVC.listingHouseTap(regognizer:)))
        self.listContainer.isUserInteractionEnabled = true
        self.listContainer.addGestureRecognizer(tapForListing)
        
        // Do any additional setup after loading the view.
        
        self.setUpLogo()
        
        UserDefaults.standard.set(true, forKey: isSearchFilterChanged)
        self.setupSearchMap()
        self.searchProp()
        
        noteCenter.addObserver(self, selector: #selector(SearchTabRootVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
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
        
        self.favoriteProps = CoreDataController.fetchFavoriteProps()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
      //  self.signInItemBtn.title = LanguageGeneral.signInStr
        self.filterLabel.text = LanguageProperty.filterStr
        self.listLabel.text = LanguageProperty.listStr
    }
    
    fileprivate func prepareSearchData() {
        
        let tempState = UserDefaults.standard.object(forKey: stateSearch) as? String
        
        if let _tempState = tempState, _tempState.count > 0 {
            self.stateForSearch = _tempState
        } else {
            self.stateForSearch = "Ontario"
        }
        
        let tempCity = UserDefaults.standard.object(forKey: citySearch) as? String
        
        if let _tempCity = tempCity, _tempCity.count > 0 {
            self.cityForSearch = _tempCity
        } else {
            self.cityForSearch = "Toronto"
        }
        
        let tempCityLati = UserDefaults.standard.object(forKey: citySearchLati) as? String
        
        if let _tempCityLati = tempCityLati, _tempCityLati.count > 0 {
            self.cityLatiForSearch = _tempCityLati
        } else {
            self.cityLatiForSearch = "43.7001100"
        }
        
        let tempCityLong = UserDefaults.standard.object(forKey: citySearchLong) as? String
        
        if let _tempCityLong = tempCityLong, _tempCityLong.count > 0 {
            self.cityLongForSearch = _tempCityLong
        } else {
            self.cityLongForSearch = "-79.4163000"
        }
        
        let tempResiComm = UserDefaults.standard.object(forKey: resiOrCommSearch) as? String
        
        if let _tempResiComm = tempResiComm, _tempResiComm.count > 0 {
            self.resiCommForSearch = _tempResiComm
        } else {
            self.resiCommForSearch = "residential"
        }
        
        let tempSaleRent = UserDefaults.standard.object(forKey: saleRentSearch) as? String
        
        if let _tempSaleRent = tempSaleRent, _tempSaleRent.count > 0 {
            self.saleRentForSearch = _tempSaleRent
        } else {
            self.saleRentForSearch = "for sale"
        }
        
        let tempBldgType = UserDefaults.standard.object(forKey: bldgTypeSearch) as? String
        
        if let _tempBldgType = tempBldgType, _tempBldgType.count > 0 {
            self.bldgTypeForSearch = _tempBldgType
        } else {
            self.bldgTypeForSearch = all
        }
        
        let tempMinPrice = UserDefaults.standard.object(forKey: minPriceSearch) as? Double
        
        if let _tempMinPrice = tempMinPrice, _tempMinPrice > 0 {
            self.minPriceForSearch = _tempMinPrice
          //  print("maxp--1053--" + String(describing: _tempMinPrice))
        } else {
            self.minPriceForSearch = Double(minPriceInit)
        }
        
        let tempMaxPrice = UserDefaults.standard.object(forKey: maxPriceSearch) as? Double
        
        if let _tempMaxPrice = tempMaxPrice, _tempMaxPrice > 0 {
           // print("maxp--1053--" + String(describing: _tempMaxPrice))
            self.maxPriceForSearch = _tempMaxPrice
        } else {
            self.maxPriceForSearch = Double(maxPriceInit)
        }
        
        let tempMinRooms = UserDefaults.standard.object(forKey: minRoomsSearch) as? Int
        
        if let _tempMinRooms = tempMinRooms {
            self.minRoomsForSearch = _tempMinRooms
        } else {
            self.minRoomsForSearch = minRoomsInit
        }
        
        let tempMaxRooms = UserDefaults.standard.object(forKey: maxRoomsSearch) as? Int
        
        if let _tempMaxRooms = tempMaxRooms {
            self.maxRoomsForSearch = _tempMaxRooms
        } else {
            self.maxRoomsForSearch = maxRoomsInit
        }
        
        let tempMinBaths = UserDefaults.standard.object(forKey: minBathsSearch) as? Int
        
        if let _tempMinBaths = tempMinBaths {
            self.minBathsForSearch = _tempMinBaths
        } else {
            self.minBathsForSearch = minBathsInit
        }
        
        let tempMaxBaths = UserDefaults.standard.object(forKey: maxBathsSearch) as? Int
        
        if let _tempMaxBaths = tempMaxBaths {
            self.maxBathsForSearch = _tempMaxBaths
        } else {
            self.maxBathsForSearch = maxBathsInit
        }
        
        let tempMinGarage = UserDefaults.standard.object(forKey: minGarageSearch) as? Int
        
        if let _tempMinGarage = tempMinGarage {
            self.minGarageForSearch = _tempMinGarage
        } else {
            self.minGarageForSearch = minGarageInit
        }
        
        let tempMaxGarage = UserDefaults.standard.object(forKey: maxGarageSearch) as? Int
        
        if let _tempMaxGarage = tempMaxGarage {
            self.maxGarageForSearch = _tempMaxGarage
        } else {
            self.maxGarageForSearch = maxGarageInit
        }
        
        let tempBasement = UserDefaults.standard.object(forKey: basementSearch) as? String
        
        if let _tempBasement = tempBasement, _tempBasement.count > 0 {
            self.basementForSearch = _tempBasement
        } else {
            self.basementForSearch = all
        }
        
        let tempOpenHouse = UserDefaults.standard.object(forKey: openHouseSearch) as? Bool
        
        if let _tempOpenHouse = tempOpenHouse {
            self.openHouseForSearch = _tempOpenHouse
        } else {
            self.openHouseForSearch = false
        }
        
        let tempPropType = UserDefaults.standard.object(forKey: propTypeSearch) as? String
        
        if let _tempPropType = tempPropType, _tempPropType.count > 0 {
            self.propTypeForSearch = _tempPropType
        } else {
            self.propTypeForSearch = all
        }
        
        let tempMinAreaSize = UserDefaults.standard.object(forKey: minAreaSizeSearch) as? Double
        
        if let _tempMinAreaSize = tempMinAreaSize {
            self.minAreaSizeForSearch = _tempMinAreaSize
        } else {
            self.minAreaSizeForSearch = Double(minAreaSizeInit)
        }
        
        let tempMaxAreaSize = UserDefaults.standard.object(forKey: maxAreaSizeSearch) as? Double
        
        if let _tempMaxAreaSize = tempMaxAreaSize {
            self.maxAreaSizeForSearch = _tempMaxAreaSize
        } else {
            self.maxAreaSizeForSearch = Double(maxAreaSizeInit)
        }
    }
    
    fileprivate func setupSearchMap() {
        
        self.searchMap.delegate = self
        
        // When zoom level is quite close to the pins, disable clustering in order to show individual pins and allow the user to interact with them via callouts.
        clusterManager.cellSize = nil
        clusterManager.maxZoomLevel = 17
        clusterManager.minCountForClustering = 3
        clusterManager.clusterPosition = .nearCenter
        clusterManager.shouldRemoveInvisibleAnnotations = false
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
    
    @objc fileprivate func chooseCityTap(regognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "SearchControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "chooseCityInSearch") as! ChooseCityVC
        controller.hidesBottomBarWhenPushed = true
        controller.oldState = self.stateForSearch
        controller.oldCity = self.cityForSearch
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func modifyFilterTap(regognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "SearchControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "filterSettingVCSB") as! FilterSettingVC
        //   controller.role = "buyer"
        controller.hidesBottomBarWhenPushed = true
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func listingHouseTap(regognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "SearchControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "searchlistingVCSB") as! SearchListVC
        controller.hidesBottomBarWhenPushed = true
        findPropsVisibleInMap()
        controller.resi_comm = self.resiCommForSearch
        controller.stateSearch = self.stateForSearch
        controller.propsToList = self.propsToList
        controller.coorsToList = self.coorsToList
        
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    fileprivate func findPropsVisibleInMap() {
        self.propsIDtoList.removeAll()
        self.coorsToList.removeAll()
        self.propsToList.removeAll()
        
        let annosArr = clusterManager.annotations
        if annosArr.count > 0 {
            for annotation in annosArr {
                let coorPoint = MKMapPointForCoordinate(annotation.coordinate)
                if(MKMapRectContainsPoint(searchMap.visibleMapRect, coorPoint)) {
                    if let _idhere = annotation.title, let _idFinal = _idhere {
                        self.propsIDtoList.append(_idFinal)
                        self.coorsToList[_idFinal] = annotation.coordinate
                    }
                }
            }
            for propII in self.propertiesArr {
                let idHere = propII["ListingID"] as? String
                if let _idHere = idHere, self.propsIDtoList.contains(_idHere) {
                    self.propsToList.append(propII)
                }
            }
        }
    }
    
    fileprivate func addCardView() {
        let scWidth = UIScreen.main.bounds.size.width
        let scHeight = UIScreen.main.bounds.size.height
        let tabHeight = self.tabBarController?.tabBar.frame.size.height
        
        var tabHeightValue: CGFloat = 0
        
        if let _tabHeight = tabHeight {
            tabHeightValue = _tabHeight
        } else {
            tabHeightValue = 44.0
        }
        
        self.cardOriginY = scHeight - tabHeightValue
        
        let resiView = ResidentialCardView(frame: CGRect(x: 0, y: self.cardOriginY, width: scWidth, height: 182))
        resiView.resiCardViewDelegate = self
        self.resiCardView = resiView
        self.view.addSubview(resiView)
        
        let commView = CommercialCardView(frame: CGRect(x: 0, y: self.cardOriginY, width: scWidth, height: 182))
        commView.commCardViewDelegate = self
        self.commCardView = commView
        self.view.addSubview(commView)
    }

    @IBAction func loginAction(_ sender: Any) {
        
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
                // left button is disabled and doing nothing
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
    
    @IBAction func returnedFromCity(segue: UIStoryboardSegue) {
        self.prepareSearchData()
        self.cityLabel.text = self.cityForSearch
        self.searchProp()
    }
    
    @IBAction func returnedFromFilter(segue: UIStoryboardSegue) {
        self.prepareSearchData()
        self.searchProp()
    }
    
    fileprivate func searchProp() {
        let isFilterChanged = UserDefaults.standard.object(forKey: isSearchFilterChanged) as? Bool
        if let _isFilterChanged = isFilterChanged {
            if _isFilterChanged {
                UserDefaults.standard.set(false, forKey: isSearchFilterChanged)
                UserDefaults.standard.synchronize()
                self.propertiesArr.removeAll()
                self.llocs.removeAll()
                self.connectingServer()
            } else {
                return
              //  print("ch -- oct 13 2017 3:40pm")
            }
        } else {
            return
        }
    }
    
    fileprivate func setupMapShowArea() {
        
    // Add annotations to the manager.
        
        let annotations: [Annotation] = self.llocs.map { cllValue in
            let annotation = Annotation()
            //
            annotation.title = (cllValue["ID"] as! String)
            //
            let latDou = cllValue["latt"] as! Double
            let logDou = cllValue["logt"] as! Double
            annotation.coordinate = CLLocationCoordinate2D(latitude: latDou, longitude: logDou)
            let color = UIColor(red: 252/255, green: 124/255, blue: 52/255, alpha: 1)
            annotation.style = .color(color, radius: 25)
        
            return annotation
        }
        
        clusterManager.removeAll()
        searchMap.removeAnnotations(searchMap.annotations)//mapView.annotations)
        clusterManager.add(annotations)
        clusterManager.reload(mapView: searchMap)
        
        let annosArr = clusterManager.annotations
        if annosArr.count > 0 {
            var zoomRect = MKMapRectNull
            for annotation in annosArr {
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
                if MKMapRectIsNull(zoomRect) {
                    zoomRect = pointRect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect)
                }
            }
            let bodary = UIEdgeInsets(top: 8.0, left: 30.0, bottom: 8.0, right: 5.0)
            self.searchMap.setVisibleMapRect(zoomRect, edgePadding: bodary, animated: true)
          //  self.searchMap.setVisibleMapRect(zoomRect, animated: true)
        } else {
            let la = self.cityLatiForSearch
            let lo = self.cityLongForSearch
            
            if let _la = la, let _lo = lo, let dLa = Double(_la), let dLo = Double(_lo) {
                let latitude = CLLocationDegrees(dLa)
                let longitude = CLLocationDegrees(dLo)
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                self.searchMap.setCenter(coordinate, animated: true)
                
                let viewRegion: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0))
                // let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, 100000, 100000)
                let adjustedRegion: MKCoordinateRegion = self.searchMap.regionThatFits(viewRegion)
                self.searchMap.setRegion(adjustedRegion, animated: true)
            }
        }
    }
    
    fileprivate func getAddressCoordinate(addressIndex: Int) {
        
        let geocoder = CLGeocoder()
        let propI: [String : Any?] = self.propertiesArr[addressIndex]
        
        let propIID = propI["ListingID"] as? String
        //
        let propIStreet = propI["Address"] as? String
        let _propIStreet = propIStreet ?? ""
        let propICity = propI["City"] as? String
        let _propICity = propICity ?? ""
        let propIPro = propI["Province"] as? String
        let _propIPro = propIPro ?? ""
        let propIPC = propI["PostalCode"] as? String
        let _propIPC = propIPC ?? ""
        
        let propIAddress: String? = _propIStreet + " " + _propICity + " " + _propIPro + " " + _propIPC
        let propILat = propI["latitude"] as? String
        let propILog = propI["longtitude"] as? String
        if let _propIID = propIID, _propIID.count > 1 {
            if let _propILat = propILat, let _propILog = propILog, _propILat.count > 0, _propILog.count > 0 {
                if let latDouble = Double(_propILat), let logDouble = Double(_propILog) {
                    let llocI: [String:Any] = ["ID": _propIID, "latt": latDouble, "logt": logDouble]
                    self.llocs.append(llocI)
                    let nIndex = addressIndex + 1
                    self.loopAddress(nextAddressIndex: nIndex)
                } else {
                    let nIndex = addressIndex + 1
                    self.loopAddress(nextAddressIndex: nIndex)
                }
            } else {
                if let _propIAddress = propIAddress {
                    geocoder.geocodeAddressString(_propIAddress) { [unowned self] (placemarks, error) in
                    //    print("8-10-150pm-geoHH" + _propIAddress)
                        if error == nil {
                            if let placemark = placemarks?[0] {
                                let location0 = placemark.location!
                                let llocI: [String:Any] = ["ID": _propIID, "latt": location0.coordinate.latitude, "logt": location0.coordinate.longitude]
                                self.llocs.append(llocI)
                                let nIndex = addressIndex + 1
                                self.loopAddress(nextAddressIndex: nIndex)
                            }
                        } else {
                            let nIndex = addressIndex + 1
                            self.loopAddress(nextAddressIndex: nIndex)
                        }
                    }
                } else {
                    let nIndex = addressIndex + 1
                    self.loopAddress(nextAddressIndex: nIndex)
                }
            }
        } else {
            let nIndex = addressIndex + 1
            self.loopAddress(nextAddressIndex: nIndex)
        }
    }
    
    fileprivate func loopAddress(nextAddressIndex: Int) {
        let noOfPropsH = self.propertiesArr.count
        if nextAddressIndex < noOfPropsH {
            self.getAddressCoordinate(addressIndex: nextAddressIndex)
        } else {
            self.setupMapShowArea()
           // MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    fileprivate func connectingServer() {
        
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        var parameterH: [String:Any] = [:]
        
        if let _resiComm = self.resiCommForSearch, _resiComm == "residential" {
            let minPri: String = String(format: "%.0f", self.minPriceForSearch ?? 10000.0)
            let maxPri: String = String(format: "%.0f", self.maxPriceForSearch ?? 20000000.0)
            let minBed: String = String(describing: self.minRoomsForSearch ?? 1)
            let maxBed: String = String(describing: self.maxRoomsForSearch ?? 8)
            let minBath: String = String(describing: self.minBathsForSearch ?? 1)
            let maxBath: String = String(describing: self.maxBathsForSearch ?? 8)
            let minGar: String = String(describing: self.minGarageForSearch ?? 0)
            let maxGar: String = String(describing: self.maxGarageForSearch ?? 8)
            let openH: String = String(describing: self.openHouseForSearch ?? false)
            parameterH = ["op": "q1",
                          "state": self.stateForSearch ?? "",
                          "city": self.cityForSearch ?? "",
                          "salerent": self.saleRentForSearch ?? "",
                          "bldgtype": self.bldgTypeForSearch ?? "",
                          "minprice": minPri,
                          "maxprice": maxPri,
                          "minbedroom": minBed,
                          "maxbedroom": maxBed,
                          "minbathroom": minBath,
                          "maxbathroom": maxBath,
                          "mingarage": minGar,
                          "maxgarage": maxGar,
                          "basement": self.basementForSearch ?? "",
                          "openhouse": openH]
        } else {
            let minPri: String = String(format: "%.0f", self.minPriceForSearch ?? 10000.0)
            let maxPri: String = String(format: "%.0f", self.maxPriceForSearch ?? 20000000.0)
            let minArea: String = String(format: "%.0f", self.minAreaSizeForSearch ?? 100.0)
            let maxArea: String = String(format: "%.0f", self.maxAreaSizeForSearch ?? 300000.0)
            parameterH = ["op": "q2",
                          "state": self.stateForSearch ?? "",
                          "city": self.cityForSearch ?? "",
                          "salerent": self.saleRentForSearch ?? "",
                          "businesstype": self.propTypeForSearch ?? "",
                          "minprice": minPri,
                          "maxprice": maxPri,
                          "minarea": minArea,
                          "maxarea": maxArea]
        }
        
        netWorkProvider.rx.request(.propsFilter(paras: parameterH)).subscribe { [unowned self] event in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonArray = try response.mapJSON() as? [String:Any?] {
                        if let succ = jsonArray["success"] as? String, succ == "true" {
                         //   print("8-10-150pm-geo***" + jsonArray.description)
                            if let propArr = jsonArray["property"] as? [[String:Any?]] {
                                self.propertiesArr = propArr
                            }
                            self.loopAddress(nextAddressIndex: 0)
                        } else {
                            self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
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
        do {
            let urlFullPrint = try netWorkProvider.endpoint(.propsFilter(paras: parameterH)).urlRequest().description
            print(urlFullPrint)
        } catch {
            print("wrong url in map search")
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
                    if let jsonDic = try response.mapJSON() as? [String:Any?] {
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
                    debugPrint("Mapping Error in update agent code search-tab: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in update agent code search-tab: \(error.localizedDescription)")
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
    
    func addFavoriteToCoreData(ListID: String, resiComm: String) {
        
        let isFavorite = self.isFavoriteProp(forListID: ListID)
        
        if !isFavorite {
            _ = CoreDataController.createFavoriteEntity(listID: ListID, resiComm: resiComm)
            self.favoriteProps = CoreDataController.fetchFavoriteProps()
            self.broadNotify(resiCommIn: resiComm)
        }
    }
    
    fileprivate func broadNotify(resiCommIn: String) {
        let key = "keyStr"
        let newValue = resiCommIn
        let dictionaryInfo = [key: newValue]
        noteCenter.post(name: NSNotification.Name(rawValue: "AddFavoriteFromSearchTab"), object: nil, userInfo: dictionaryInfo)
    }
    
    fileprivate func isFavoriteProp(forListID: String) -> Bool {
        var isFavorite: Bool = false
        for objj: NSManagedObject in self.favoriteProps {
            if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == forListID {
                isFavorite = true
                break
            }
        }
        return isFavorite
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let acts = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(acts)
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

extension SearchTabRootVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
  
        if let annotation = annotation as? ClusterAnnotation {
            guard let style = annotation.style else { return nil }
            let identifier = "Cluster"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view as? BorderedClusterAnnotationView {
                view.annotation = annotation
                view.style = style
                view.configure()
            } else {
                view = BorderedClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier, style: style, borderColor: .white)
            }
            return view
        } else {
          //  guard let annotation = annotation as? Annotation else { return nil }
            guard let annotation = annotation as? Annotation, let _ = annotation.style else { return nil }
            let identifier = "Pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view {
                view.annotation = annotation
                view.image = UIImage(named: "mappin")
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view!.image = UIImage(named: "mappin")
                view!.canShowCallout = false
            }
 
            return view
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView: mapView) { finished in
            print(finished.description)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let cluster = annotation as? ClusterAnnotation {
            var zoomRect = MKMapRectNull
            for annotation in cluster.annotations {
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
                if MKMapRectIsNull(zoomRect) {
                    zoomRect = pointRect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect)
                }
            }
            let bodary = UIEdgeInsets(top: 8.0, left: 30.0, bottom: 8.0, right: 5.0)
            mapView.setVisibleMapRect(zoomRect, edgePadding: bodary, animated: true)
         //   mapView.setVisibleMapRect(zoomRect, animated: true)
        } else {
            guard annotation is Annotation else { return }
            
            if !isCardViewShowing {
                if let _resiComm = self.resiCommForSearch, _resiComm == "residential" {
                    if let currentID = annotation.title, let _currentID = currentID {
                        let isFavorite = self.isFavoriteProp(forListID: _currentID)
                        if isFavorite {
                            self.resiCardView?.disableHeartImg()
                        } else {
                            self.resiCardView?.enableHeartImg()
                        }
                        for currentProp in self.propertiesArr {
                            if let idAtI = currentProp["ListingID"] as? String, idAtI == _currentID {
                                let coorH = annotation.coordinate
                                let srH = currentProp["salerent"] as? String
                                let priH = currentProp["Price"] as? String
                                //
                                let propIStreet = currentProp["Address"] as? String
                                let _propIStreet = propIStreet ?? ""
                                let propICity = currentProp["City"] as? String
                                let _propICity = propICity ?? ""
                                let propIPro = currentProp["Province"] as? String
                                let _propIPro = propIPro ?? ""
                                let propIPC = currentProp["PostalCode"] as? String
                                let _propIPC = propIPC ?? ""
                                
                                let addH: String? = _propIStreet + " " + _propICity + " " + _propIPro + " " + _propIPC
                                //
                                let bedH = currentProp["BedroomsTotal"] as? String
                                let bathH = currentProp["BathroomTotal"] as? String
                                let bldgH = currentProp["bldgtype"] as? String
                                let ph1H = currentProp["photo1url"] as? String
                                self.resiCardView?.setBldgTypeSaleRent(bldgT: bldgH, saleR: srH)
                                self.resiCardView?.setPriceAddress(price: priH, address: addH, coor2Din: coorH)
                                self.resiCardView?.setListIDBedsBaths(listID: _currentID, beds: bedH, baths: bathH)
                                self.resiCardView?.setPhoto1(photoURL: ph1H)
                                
                                break
                            }
                        }
                        
                       isCardViewShowing = true
                        UIView.animate(withDuration: 0.5, animations: {
                            self.resiCardView?.frame.origin.y = self.cardOriginY - (self.resiCardView?.bounds.height)!
                        }, completion: nil)
                    }
                } else {
                    //
                    if let currentID = annotation.title, let _currentID = currentID {
                        let isFavorite = self.isFavoriteProp(forListID: _currentID)
                        if isFavorite {
                            self.commCardView?.disableHeartImg()
                        } else {
                            self.commCardView?.enableHeartImg()
                        }
                        for currentProp in self.propertiesArr {
                            if let idAtI = currentProp["ListingID"] as? String, idAtI == _currentID {
                                let coorH = annotation.coordinate
                                let srH = currentProp["salerent"] as? String
                                let priH = currentProp["Price"] as? String
                                //
                                let propIStreet = currentProp["Address"] as? String
                                let _propIStreet = propIStreet ?? ""
                                let propICity = currentProp["City"] as? String
                                let _propICity = propICity ?? ""
                                let propIPro = currentProp["Province"] as? String
                                let _propIPro = propIPro ?? ""
                                let propIPC = currentProp["PostalCode"] as? String
                                let _propIPC = propIPC ?? ""
                                
                                let addH: String? = _propIStreet + " " + _propICity + " " + _propIPro + " " + _propIPC
                                //
                                let busiH = currentProp["businesstype"] as? String
                                let ph1H = currentProp["photo1url"] as? String
                                self.commCardView?.setSaleRent(saleR: srH)
                                self.commCardView?.setPriceAddress(price: priH, address: addH, coor2Din: coorH)
                                self.commCardView?.setListIDProp(listID: _currentID, prop: busiH)
                                self.commCardView?.setPhoto1(photoURL: ph1H)
                                
                                break
                            }
                        }
                        
                        isCardViewShowing = true
                        UIView.animate(withDuration: 0.5, animations: {
                            self.commCardView?.frame.origin.y = self.cardOriginY - (self.commCardView?.bounds.height)!
                        }, completion: nil)
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            views.forEach { $0.alpha = 1 }
        }, completion: nil)
    }
}

extension SearchTabRootVC: ResiCardViewActions {
    
    func toHideCardViewResi() {
        if isCardViewShowing {
            isCardViewShowing = false
            UIView.animate(withDuration: 0.5, animations: {
                self.resiCardView?.frame.origin.y = self.cardOriginY
            }, completion: nil)
        }
    }
    
    func toAddFavoriteResi(listID: String) {
        self.addFavoriteToCoreData(ListID: listID, resiComm: "residential")
    }
    
    func toShowPropDetailResi(listID: String, addressO: String, coor2D: CLLocationCoordinate2D, bldgTypeO: String) {
        
        if isCardViewShowing {
            isCardViewShowing = false
            UIView.animate(withDuration: 0.5, animations: {
                self.resiCardView?.frame.origin.y = self.cardOriginY
            }, completion: nil)
        }
        
        let storyB = UIStoryboard(name: "FavoritesControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "PropertyDetailsVCinFavorites") as! PropertyDetailsVC
        controller.hidesBottomBarWhenPushed = true
        controller.listingIDPassedIn = listID
        controller.addressPassedIn = addressO
        controller.latitudePassedIn = String(describing: coor2D.latitude)
        controller.longitudePassedIn = String(describing: coor2D.longitude)
        controller.bldgTypePassedIn = bldgTypeO
        controller.statePassedIn = self.stateForSearch
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SearchTabRootVC: CommCardViewActions {
    
    func toHideCardViewComm() {
        if isCardViewShowing {
            isCardViewShowing = false
            UIView.animate(withDuration: 0.5, animations: {
                self.commCardView?.frame.origin.y = self.cardOriginY
            }, completion: nil)
        }
    }
    
    func toAddFavoriteComm(listID: String) {
        self.addFavoriteToCoreData(ListID: listID, resiComm: "commercial")
    }
    
    func toShowPropDetailComm(listID: String, addressO: String, coor2D: CLLocationCoordinate2D, busiType: String) {
        
        if isCardViewShowing {
            isCardViewShowing = false
            UIView.animate(withDuration: 0.5, animations: {
                self.commCardView?.frame.origin.y = self.cardOriginY
            }, completion: nil)
        }
        
        let storyB = UIStoryboard(name: "FavoritesControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "PropertyDetailsCommVCinFavorites") as! PropertyDetailsCommVC
        controller.hidesBottomBarWhenPushed = true
        controller.listingIDPassedIn = listID
        controller.addressPassedIn = addressO
        controller.latitudePassedIn = String(describing: coor2D.latitude)
        controller.longitudePassedIn = String(describing: coor2D.longitude)
        controller.busiTypePassedIn = busiType
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension SearchTabRootVC: AlertViewWithApplyDelegate {
    func enterBtnTapped(codeStr: String, nickNameStr: String) {
        self.updateAgentCodeServer(theCode: codeStr, theNickname: nickNameStr)
    }
    
    func cancelBtntapped() {
        
    }
}
