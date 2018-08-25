//
//  PropertyDetailsCommVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-09.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import UIKit
import ImageSlideshow
import MapKit
import CoreLocation
import MBProgressHUD
import CoreData

class PropertyDetailsCommVC: UIViewController {
    
    public var listingIDPassedIn: String?
    public var addressPassedIn: String?
    public var latitudePassedIn: String?
    public var longitudePassedIn: String?
    public var busiTypePassedIn: String?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBOutlet weak var photoSlider: ImageSlideshow!
    @IBOutlet weak var mapThumb: MKMapView!
    
    @IBOutlet weak var generalTableView: UITableView!
    @IBOutlet weak var generalTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var saleRentLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var heartImg: UIImageView!
    
    @IBOutlet weak var descriptionCapLabel: UILabel!
    @IBOutlet weak var descriptionConLabel: UILabel!
    
    @IBOutlet weak var moreInfoBtn: UIButton!
    @IBOutlet weak var schoolBtn: UIButton!
    
    @IBOutlet weak var realtorCA: UILabel!
    @IBOutlet weak var asscociateCA: UILabel!
    
    // for broker
    @IBOutlet weak var brokerCap: UILabel!
    @IBOutlet weak var brokerName: UILabel!
    @IBOutlet weak var brokerPhone: UILabel!
    @IBOutlet weak var brokerCompany: UILabel!
    @IBOutlet weak var emailBtn: UIButton!
    
  //  let localSource = [ImageSource(imageString: "launchicon")!]
    
    let locationManager = CLLocationManager()
    
    var commDataCaptions: [String] = []
    var commDataValues: [String?] = []
    
    var propertyObj: [String:Any?] = [:]
    var favoriteProps: [NSManagedObject] = []
    
    // for broker
    var individualIDBroker: String = ""
    var brokerNameStr: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
      //  self.favoriteProps = CoreDataController.fetchFavoriteProps()
        
        self.setupPhotoSlider()
        self.setupPriceField()
        self.setupMapField()
        self.setupGeneralTable()
        self.setupOtherFields()
        self.setupBrokerageField()
        
        self.getPropFromServer()
        
        let uuidHH = UserDefaults.standard.object(forKey: uToken) as? String
        if let _uuidHH = uuidHH, _uuidHH.count > 20 {
            creaAnalyticalAPI(eventT: "view", uuidIN: _uuidHH)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.favoriteProps = CoreDataController.fetchFavoriteProps()
        
        commDataCaptions = LanguageProperty.getCommDataCaptions()
        
        self.descriptionCapLabel.text = LanguageProperty.generalDescriptionStr
        self.moreInfoBtn.setTitle(LanguageGeneral.moreInfoStr, for: .normal)
        self.schoolBtn.setTitle(LanguageGeneral.schoolNearbyStr, for: .normal)
        
        self.generalTableView.reloadData()
        
        self.generalTableViewHeight.constant = self.calculateTableHeight(tableView: self.generalTableView)
        
        self.brokerCap.text = LanguageProperty.brokerageStr
        self.emailBtn.setTitle(LanguageProperty.emailToBrokerStr, for: .normal)
    }
    
    fileprivate func setupPhotoSlider() {
        self.photoSlider.backgroundColor = UIColor.darkGray
        self.photoSlider.slideshowInterval = 5.0
        self.photoSlider.pageControlPosition = PageControlPosition.insideScrollView
        self.photoSlider.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.photoSlider.pageControl.pageIndicatorTintColor = UIColor.lightGray
        self.photoSlider.contentScaleMode = UIViewContentMode.scaleAspectFit
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        self.photoSlider.activityIndicator = DefaultActivityIndicator()
        self.photoSlider.currentPageChanged = { page in
            //  print("current page:", page)
        }
        
        let recognizerPhoto = UITapGestureRecognizer(target: self, action: #selector(PropertyDetailsCommVC.didTapPhoto))
        self.photoSlider.addGestureRecognizer(recognizerPhoto)
        
      //  self.photoSlider.setImageInputs(localSource)
    }
    
    @objc fileprivate func didTapPhoto() {
        let fullScreenController = self.photoSlider.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .gray, color: nil)
        fullScreenController.backgroundColor = UIColor.darkGray
    }
    
    fileprivate func setupPriceField() {
        self.priceLabel.text = ""
        self.saleRentLabel.text = ""
        self.heartImg.image = UIImage(named: "heartempty")
        self.heartImg.isUserInteractionEnabled = false
        
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(PropertyDetailsCommVC.addFavoriteProp))
        self.heartImg.addGestureRecognizer(heartTap)
    }
    
    @objc fileprivate func addFavoriteProp() {
        self.heartImg.isUserInteractionEnabled = false
        self.heartImg.image = UIImage(named: "heartfull")
        if let listIDtoAdd = self.listingIDPassedIn, listIDtoAdd.count > 2 {
            var isFavorite: Bool = false
            for objj: NSManagedObject in self.favoriteProps {
                if let idSaved = objj.value(forKey: "listingID") as? String, idSaved == listIDtoAdd {
                    isFavorite = true
                }
            }
            if !isFavorite {
                _ = CoreDataController.createFavoriteEntity(listID: listIDtoAdd, resiComm: "commercial")
                broadNotify(resiCommIn: "commercial")
            }
        }
    }
    
    fileprivate func broadNotify(resiCommIn: String) {
        let key = "keyStr"
        let newValue = resiCommIn
        let dictionaryInfo = [key: newValue]
        noteCenter.post(name: NSNotification.Name(rawValue: "AddFavoriteFromDetailComm"), object: nil, userInfo: dictionaryInfo)
    }
    
    fileprivate func setupMapField() {
        self.addressLabel.text = ""
        
        self.mapThumb.layer.cornerRadius = 33
        self.mapThumb.layer.borderWidth = 5
        self.mapThumb.layer.borderColor = UIColor(red: 252/255, green: 124/255, blue: 52/255, alpha: 1.0).cgColor
        self.mapThumb.layer.masksToBounds = true
        self.mapThumb.delegate = self
        
        let recognizerMap = UITapGestureRecognizer(target: self, action: #selector(PropertyDetailsCommVC.didTapMap))
        self.mapThumb.addGestureRecognizer(recognizerMap)
        
        self.annotateThumbMap()
    }
    
    @objc fileprivate func didTapMap() {
        if let _propILat = self.latitudePassedIn, let _propILog = self.longitudePassedIn, _propILat.count > 0, _propILog.count > 0 {
            if let _ = Double(_propILat), let _ = Double(_propILog) {
                let storyB = UIStoryboard(name: "FavoritesControllers", bundle: nil)
                let controller = storyB.instantiateViewController(withIdentifier: "singleMapViewVC") as! SingleLocationMapVC
                controller.location = Location(latitude: self.latitudePassedIn, longitude: self.longitudePassedIn)
                controller.address = self.addressPassedIn
                if (self.responds(to: #selector(self.show(_:sender:)))) {
                    self.show(controller, sender: self)
                } else {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            } else {
                return
            }
        } else {
            return
        }
    }

    fileprivate func annotateThumbMap() {
        
        // looks this statement has no effect, could be commited out
        self.locationManager.startUpdatingLocation()
        
        var coordinate: CLLocationCoordinate2D
        if let _propILat = self.latitudePassedIn, let _propILog = self.longitudePassedIn, _propILat.count > 0, _propILog.count > 0 {
            if let latDouble = Double(_propILat), let logDouble = Double(_propILog) {
                coordinate = CLLocationCoordinate2D(latitude: latDouble, longitude: logDouble)
            } else {
                coordinate = CLLocationCoordinate2D(latitude: 43.8, longitude: -79.4)
            }
        } else {
            coordinate = CLLocationCoordinate2D(latitude: 43.8, longitude: -79.4)
        }
        
        let viewRegion: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        let adjustedRegion: MKCoordinateRegion = self.mapThumb.regionThatFits(viewRegion)
        self.mapThumb.setRegion(adjustedRegion, animated: true)
        self.mapThumb.setCenter(coordinate, animated: true)
        
        let annotation = CustomMapPointAnnotation()
        annotation.coordinate = coordinate
        self.mapThumb.addAnnotation(annotation)
    }
    
    fileprivate func setupGeneralTable() {
        
        self.descriptionConLabel.text = ""
        
        self.generalTableView.dataSource = self
        self.generalTableView.delegate = self
        self.generalTableView.isScrollEnabled = false
        self.generalTableView.estimatedRowHeight = 50.0
        self.generalTableView.rowHeight = UITableViewAutomaticDimension
        
        self.commDataCaptions = LanguageProperty.getCommDataCaptions()
        self.commDataValues = ["", "", "", "", "", "", "", "", ""]
    }
    
    fileprivate func calculateTableHeight(tableView: UITableView) -> CGFloat {
        
        var height: CGFloat = 0
        
        let noOfSec = tableView.numberOfSections
        if noOfSec > 0 {
            for j in 1...noOfSec {
                let noOfRow = tableView.numberOfRows(inSection: j - 1)
                if noOfRow > 0 {
                    for i in 1...noOfRow {
                        let rowRect = tableView.rectForRow(at: IndexPath(row: i - 1, section: j - 1))
                        let cellHeight = rowRect.size.height
                        height = height + cellHeight
                    }
                }
            }
        }
        return height + 1
    }
    
    fileprivate func setupOtherFields() {
        
        self.schoolBtn.layer.borderWidth = 1
        self.schoolBtn.layer.borderColor = UIColor.gray.cgColor
        self.schoolBtn.layer.cornerRadius = 8
        self.schoolBtn.layer.masksToBounds = true
        
        self.moreInfoBtn.layer.borderWidth = 1
        self.moreInfoBtn.layer.borderColor = UIColor.gray.cgColor
        self.moreInfoBtn.layer.cornerRadius = 8
        self.moreInfoBtn.layer.masksToBounds = true
        
        self.schoolBtn.addTarget(self, action: #selector(PropertyDetailsCommVC.gotoSchoolSite), for: .touchUpInside)
        self.moreInfoBtn.addTarget(self, action: #selector(PropertyDetailsCommVC.gotoMoreInfo), for: .touchUpInside)
        
        let realtorTap = UITapGestureRecognizer(target: self, action: #selector(PropertyDetailsCommVC.gotoRealtorsSite))
        self.realtorCA.isUserInteractionEnabled = true
        self.realtorCA.addGestureRecognizer(realtorTap)
        
        let associateTap = UITapGestureRecognizer(target: self, action: #selector(PropertyDetailsCommVC.gotoAssociateSite))
        self.asscociateCA.isUserInteractionEnabled = true
        self.asscociateCA.addGestureRecognizer(associateTap)
    }
    
    fileprivate func setupBrokerageField() {
        
        self.brokerName.text = ""
        self.brokerPhone.text = ""
        self.brokerCompany.text = ""
        
        self.emailBtn.layer.borderWidth = 1
        self.emailBtn.layer.borderColor = UIColor.gray.cgColor
        self.emailBtn.layer.cornerRadius = 8
        self.emailBtn.layer.masksToBounds = true
        
        self.emailBtn.addTarget(self, action: #selector(PropertyDetailsCommVC.toEmailToBrokerPage), for: .touchUpInside)
    }
    
    @objc fileprivate func gotoSchoolSite() {
        let schoolUrlStr = "http://www.compareschoolrankings.org"
        self.gotoWebSite(withURL: schoolUrlStr)
    }
    
    @objc fileprivate func gotoMoreInfo() {
        let moreInfoUrlStr = self.propertyObj["MoreInfo"] as? String
        let uuidHH = UserDefaults.standard.object(forKey: uToken) as? String
        if let _uuidHH = uuidHH, _uuidHH.count > 20 {
            creaAnalyticalAPI(eventT: "click", uuidIN: _uuidHH)
        }
        self.gotoWebSite(withURL: moreInfoUrlStr)
    }
    
    @objc fileprivate func gotoRealtorsSite() {
        let realtorsUrlStr = "https://www.realtor.ca"
        self.gotoWebSite(withURL: realtorsUrlStr)
    }
    
    @objc fileprivate func gotoAssociateSite() {
        let associateUrlStr = "https://www.crea.ca"
        self.gotoWebSite(withURL: associateUrlStr)
    }
    
    fileprivate func gotoWebSite(withURL: String?) {
        if let _withURL = withURL, _withURL.count > 0 {
            if let _ = URL(string: _withURL) {
                let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
                let controller = storyB.instantiateViewController(withIdentifier: "postsiteVCinBuyer") as! PostWebSiteVC
                
                controller.siteURL = withURL
                if (self.responds(to: #selector(self.show(_:sender:)))) {
                    self.show(controller, sender: self)
                } else {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    @objc fileprivate func toEmailToBrokerPage() {
        
        if self.individualIDBroker.count > 0 {
            
            let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "emailTOagentSB") as! EmailToAgentVC
            
            if let _propId = self.propertyObj["ID"] as? String, _propId.count > 0 {
                controller.listingID = _propId
            } else {
                controller.listingID = ""
            }
            
            controller.individualID = self.individualIDBroker
            controller.brokerNameStr = self.brokerNameStr
            if (self.responds(to: #selector(self.show(_:sender:)))) {
                self.show(controller, sender: self)
            } else {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    fileprivate func getPropFromServer() {
        
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        var parameterH: [String:Any] = [:]
        
        parameterH = ["op": "q3",
                          "listingID": self.listingIDPassedIn ?? ""]
        
        netWorkProvider.rx.request(.propSingleID(paras: parameterH)).subscribe { [unowned self] event in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonArray = try response.mapJSON() as? [String:Any?] {
                        if let succ = jsonArray["success"] as? String, succ == "true" {
                            if let theProp = jsonArray["property"] as? [String:Any?] {
                                self.propertyObj = theProp
                                if let _listIDh = self.propertyObj["ListingID"] as? String, _listIDh.count > 2 {
                                    self.parseNetworkDataProps()
                                } else {
                                    self.presentAlert(aTitle: nil, withMsg: LanguageProperty.listingPropNotExistStr, confirmTitle: LanguageGeneral.okStr)
                                }
                            }
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in prop detail-comm: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in prop-detai-comm: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
        // the following is full url
    }
    
    fileprivate func parseNetworkDataProps() {
        var pSource: [InputSource] = []
        let photoURLs = self.propertyObj["photourls"] as? [String?]
        if let _photoURLs = photoURLs, _photoURLs.count > 0 {
            for iPhotoURL in _photoURLs {
                if let _iPhotoURL = iPhotoURL, let _ = URL(string: _iPhotoURL) {
                    pSource.append(AlamofireSource(urlString: _iPhotoURL)!)
                }
            }
        }
        self.photoSlider.setImageInputs(pSource)
        
        let listIDh = self.propertyObj["ListingID"] as? String
        let listDateH = self.propertyObj["listdate"] as? String
        let listDaysH = self.propertyObj["listdays"] as? String
        let busitypeH = self.propertyObj["businesstype"] as? String
        let floorAreah = self.propertyObj["floorarea"] as? String
        let propTaxH = self.propertyObj["propertytax"] as? String
        let landSizeH = self.propertyObj["landsize"] as? String
        let parkingH = self.propertyObj["parking"] as? String
        let brokageH = self.propertyObj["Brokerage"] as? String
                
        self.commDataValues = [listIDh, listDateH, listDaysH, busitypeH, floorAreah, propTaxH, landSizeH, parkingH, brokageH]
        self.generalTableView.reloadData()
        self.generalTableViewHeight.constant = self.calculateTableHeight(tableView: self.generalTableView)
        
        self.descriptionConLabel.text = self.propertyObj["description"] as? String
        
     //   self.descriptionConLabel.text = "hghj jwhdjw hscjs"
        
        self.priceLabel.text = self.propertyObj["Price"] as? String
        self.saleRentLabel.text = self.propertyObj["salerent"] as? String
        
        // for broker
        self.brokerName.text = self.propertyObj["brokername"] as? String
        self.brokerPhone.text = self.propertyObj["brokerphone"] as? String
        self.brokerCompany.text = self.propertyObj["brokercompany"] as? String
        if let _bName = self.propertyObj["brokername"] as? String {
            self.brokerNameStr = _bName
        } else {
            self.brokerNameStr = ""
        }
        if let _brokerIDh = self.propertyObj["brokerID"] as? String, _brokerIDh.count > 0 {
            self.individualIDBroker = _brokerIDh
            self.emailBtn.isUserInteractionEnabled = true
        } else {
            self.individualIDBroker = ""
            self.emailBtn.isUserInteractionEnabled = false
        }
        
        var isFavoriteP = false
        for favI in self.favoriteProps {
            if let idSaved = favI.value(forKey: "listingID") as? String, idSaved == self.listingIDPassedIn {
                isFavoriteP = true
            }
        }
        if isFavoriteP {
            self.heartImg.isUserInteractionEnabled = false
            self.heartImg.image = UIImage(named: "heartfull")
        } else {
            self.heartImg.isUserInteractionEnabled = true
            self.heartImg.image = UIImage(named: "heartempty")
        }
        //
        let propIStreet = propertyObj["Address"] as? String
        let _propIStreet = propIStreet ?? ""
        let propICity = propertyObj["City"] as? String
        let _propICity = propICity ?? ""
        let propIPro = propertyObj["Province"] as? String
        let _propIPro = propIPro ?? ""
        let propIPC = propertyObj["PostalCode"] as? String
        let _propIPC = propIPC ?? ""
        
        let addH: String? = _propIStreet + " " + _propICity + " " + _propIPro + " " + _propIPC
        //
        
        self.addressPassedIn = addH
        self.addressLabel.text = addH
        
        self.latitudePassedIn = self.propertyObj["latitude"] as? String
        self.longitudePassedIn = self.propertyObj["longtitude"] as? String
        if let _propILat = self.latitudePassedIn, let _propILog = self.longitudePassedIn, _propILat.count > 0, _propILog.count > 0 {
            if let _ = Double(_propILat), let _ = Double(_propILog) {
                
            } else {
                getAddressCoordinate(addressStr: self.addressPassedIn)
            }
        } else {
            getAddressCoordinate(addressStr: self.addressPassedIn)
        }
    }
    
    fileprivate func getAddressCoordinate(addressStr: String?) {
        
        let geocoder = CLGeocoder()
        
        if let _addressStr = addressStr {
            geocoder.geocodeAddressString(_addressStr) { [unowned self] (placemarks, error) in
                //  print("1-21-12pm-id" + _addressStr)
                if error == nil {
                    if let placemark = placemarks?[0] {
                        let location0 = placemark.location!
                        self.latitudePassedIn = String(describing: location0.coordinate.latitude)
                        self.longitudePassedIn = String(describing: location0.coordinate.longitude)
                        return
                    }
                }
            }
        }
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let acts = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(acts)
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

    func creaAnalyticalAPI(eventT: String, uuidIN: String) {
        
        let parameterH: [String:Any] = ["ListingID": "",
                                        "DestinationID": "28484",
                                        "EventType": eventT,
                                        "UUID": uuidIN]
        
        netWorkProvider.rx.request(.creaAPI(paras: parameterH)).subscribe { event in
            switch event {
            case .success(let response):
                debugPrint("Mapping Error in login: \(response.debugDescription)")
            case .error(let error):
                debugPrint("Networking Error in login: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
    }
}

extension PropertyDetailsCommVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.generalTableView {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.generalTableView {
            return self.commDataCaptions.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.generalTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commGeneralTableCell", for: indexPath) as! CommGeneralTableCell
            
            cell.titleLabel.text = self.commDataCaptions[indexPath.row]
            cell.contentLabel.text = self.commDataValues[indexPath.row]
            
            return cell
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
}

extension PropertyDetailsCommVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't do anything if it's the user's location point
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        // We could display multiple types of point annotations
        if annotation.isKind(of: CustomMapPointAnnotation.self) {
            let pin = CustomMapPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.image = UIImage(named: "mappinsmall")
            return pin
        }
        
        return nil
    }
}

