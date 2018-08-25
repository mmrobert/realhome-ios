//
//  BldgTypeChooseVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-17.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class BldgTypeChooseVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let bldgTypeSavedArray = [all, house, rowTownhouse, condoApartment, duplex, triplex, fourplex, gardenHome, mobileHome, manufacturedHome, recreationalCottage]
    var bldgTypeArray = [LanguageProperty.allStr, LanguageProperty.houseStr, LanguageProperty.rowTownhouseStr, LanguageProperty.condoApartmentStr, LanguageProperty.duplexStr, LanguageProperty.triplexStr, LanguageProperty.fourplexStr, LanguageProperty.gardenHomeStr, LanguageProperty.mobileHomeStr, LanguageProperty.manufacturedHomeStr, LanguageProperty.recreationalCottageStr]
    
    @IBOutlet weak var tableView: UITableView!
    
    public var chosedBldgType: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(BldgTypeChooseVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        bldgTypeArray = [LanguageProperty.allStr, LanguageProperty.houseStr, LanguageProperty.rowTownhouseStr, LanguageProperty.condoApartmentStr, LanguageProperty.duplexStr, LanguageProperty.triplexStr, LanguageProperty.fourplexStr, LanguageProperty.gardenHomeStr, LanguageProperty.mobileHomeStr, LanguageProperty.manufacturedHomeStr, LanguageProperty.recreationalCottageStr]
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bldgTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bldgTypeListCell", for: indexPath)
        cell.textLabel?.text = bldgTypeArray[indexPath.row]
        
        if let _chosedBldgType = self.chosedBldgType, _chosedBldgType == bldgTypeSavedArray[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tempBldgType = bldgTypeSavedArray[indexPath.row]
        
    //    UserDefaults.standard.set(tempBldgType, forKey: bldgTypeSearch)
    //    UserDefaults.standard.synchronize()
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.broadNotify(newValue: tempBldgType)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func broadNotify(newValue: String) {
        let key = "keyStr"
        let newValue = newValue
        let dictionaryInfo = [key: newValue]
        noteCenter.post(name: NSNotification.Name(rawValue: "BldgTypeChosed"), object: nil, userInfo: dictionaryInfo)
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
