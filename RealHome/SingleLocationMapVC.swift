//
//  SingleLocationMapVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-09.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SingleLocationMapVC: UIViewController {
    
    @IBOutlet weak var locationMap: MKMapView!
    @IBOutlet weak var adressLabel: UILabel!
    
    public var location: Location?
    public var address: String?
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.adressLabel.text = self.address
        
        self.locationMap.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.annotateTheMap()
    }
    
    fileprivate func annotateTheMap() {
        
        // looks this statement has no effect, could be commited out
        self.locationManager.startUpdatingLocation()
        
        if let _loc = self.location {
            let la = _loc.latitude
            let lo = _loc.longitude
            let latitude = CLLocationDegrees(Double(la!)!)
            let longitude = CLLocationDegrees(Double(lo!)!)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let viewRegion: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
            let adjustedRegion: MKCoordinateRegion = self.locationMap.regionThatFits(viewRegion)
            self.locationMap.setRegion(adjustedRegion, animated: true)
            self.locationMap.setCenter(coordinate, animated: true)
            
            let annotation = CustomMapPointAnnotation()
            annotation.coordinate = coordinate
            
            self.locationMap.addAnnotation(annotation)
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

}

extension SingleLocationMapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Don't do anything if it's the user's location point
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        // We could display multiple types of point annotations
        if annotation.isKind(of: CustomMapPointAnnotation.self) {
            let pin = CustomMapPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.image = UIImage(named: "mappin")
            return pin
        }
        
        return nil
    }
}

