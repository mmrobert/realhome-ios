//
//  FavoritesTabRootVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class FavoritesTabRootVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var signInItemBtn: UIBarButtonItem!

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let dataShowing: [String:Any?] = ["housetype": "Apt", "salerent": "For rent", "photo1": nil, "price": "$999,0001", "adress": "88 Lakeview Rd, Toronto, Canada", "listingID": "C089", "beds": "5", "baths": "5"]
    
    var dataArr: [[String:Any?]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpLogo()
        self.signInItemBtn.title = signInStr
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail)
        let userPassword = UserDefaults.standard.object(forKey: uPassword)
        if let _ = userEmail, let _ = userPassword {
            self.signInItemBtn.isEnabled = false
            self.signInItemBtn.tintColor = UIColor.clear
        }
        
        self.segControl.setTitle(residentialStr, forSegmentAt: 0)
        self.segControl.setTitle(commercialStr, forSegmentAt: 1)
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
      //  self.dataArr = [self.dataShowing]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segSelectedAction(_ sender: Any) {
        
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
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "loginNavigator")
        self.present(controller, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataArr.count > 0 {
            return self.dataArr.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.dataArr.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesListCell", for: indexPath) as! FavoritesListTableCell
            
            cell.listIDLabel.text = listingIDStr
            cell.bedRoomLabel.text = bedsStr
            cell.bathRoomLabel.text = bathsStr
            
            let dataAtThisRow = self.dataArr[indexPath.row]
            
            cell.houseTypeLabel.text = dataAtThisRow["housetype"] as? String
            cell.saleRentLabel.text = dataAtThisRow["salerent"] as? String
            cell.priceLabel.text = dataAtThisRow["price"] as? String
            cell.addressLabel.text = dataAtThisRow["adress"] as? String
            cell.listIDValueLabel.text = dataAtThisRow["listingID"] as? String
            cell.bedRoomValueLabel.text = dataAtThisRow["beds"] as? String
            cell.bathRoomValueLabel.text = dataAtThisRow["baths"] as? String
            
            cell.deleteFavoritesDelegate = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nofavoritesCell", for: indexPath) as! NoFavoritesTableCell
            cell.goBackSearchDelegate = self
            return cell
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

extension FavoritesTabRootVC: DeleteFavorites {
    func toDeleteFavorite(_ cellView: FavoritesListTableCell) {
        print(cellView.houseTypeLabel.text ?? "delete favorites")
    }
}

extension FavoritesTabRootVC: SearchFavoritesNoFavorites {
    func goBackToSearch(_ sender: UIButton) {
        print(sender.title(for: .normal) ?? "favorites search btn")
    }
}
