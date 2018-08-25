//
//  LanguageTableVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-28.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class LanguageTableVC: UITableViewController {
    
    let languageArr = [englishStr, chineseStr]
    
    public var chosedLanguage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tempLanguage = UserDefaults.standard.object(forKey: uLanguage)
        
        if let _tempLanguage = tempLanguage as? String {
            self.chosedLanguage = _tempLanguage
        } else {
            self.chosedLanguage = englishStr
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = LanguageGeneral.selectYourLangaugeStr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return languageArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        
        cell.textLabel?.text = languageArr[indexPath.row]
        
        if let _chosedLanguage = self.chosedLanguage, _chosedLanguage == languageArr[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        // Configure the cell...

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tempCountry = languageArr[indexPath.row]
        UserDefaults.standard.set(tempCountry, forKey: uLanguage)
        UserDefaults.standard.synchronize()
        
        LanguageGeneral.setLang(Lang: tempCountry)
        LanguageProperty.setLang(Lang: tempCountry)
        
        self.broadNotify(newValue: tempCountry)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func broadNotify(newValue: String) {
        let key = "keyStr"
        let newValue = newValue
        let dictionaryInfo = [key: newValue]
        noteCenter.post(name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil, userInfo: dictionaryInfo)
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
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

}
