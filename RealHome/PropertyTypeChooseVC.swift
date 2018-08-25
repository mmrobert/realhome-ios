//
//  PropertyTypeChooseVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-19.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class PropertyTypeChooseVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let propertyTypeSavedArray = [all, business, retail, office, industrial, hospitality, institutional, agriculture, vacantLand]
    var propertyTypeArray = [LanguageProperty.allStr, LanguageProperty.businessStr, LanguageProperty.retailStr, LanguageProperty.officeStr, LanguageProperty.industrialStr, LanguageProperty.hospitalityStr, LanguageProperty.institutionalStr, LanguageProperty.agricultureStr, LanguageProperty.vacantLandStr]
    
    @IBOutlet weak var tableView: UITableView!
    
    public var chosedPropType: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(PropertyTypeChooseVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        propertyTypeArray = [LanguageProperty.allStr, LanguageProperty.businessStr, LanguageProperty.retailStr, LanguageProperty.officeStr, LanguageProperty.industrialStr, LanguageProperty.hospitalityStr, LanguageProperty.institutionalStr, LanguageProperty.agricultureStr, LanguageProperty.vacantLandStr]
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return propertyTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "propTypeListCell", for: indexPath)
        cell.textLabel?.text = propertyTypeArray[indexPath.row]
        
        if let _chosedPropType = self.chosedPropType, _chosedPropType == propertyTypeSavedArray[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tempPropType = propertyTypeSavedArray[indexPath.row]
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.broadNotify(newValue: tempPropType)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func broadNotify(newValue: String) {
        let key = "keyStr"
        let newValue = newValue
        let dictionaryInfo = [key: newValue]
        noteCenter.post(name: NSNotification.Name(rawValue: "PropTypeChosed"), object: nil, userInfo: dictionaryInfo)
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
