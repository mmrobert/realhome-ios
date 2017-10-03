//
//  SettingsTabRootVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-27.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class SettingsTabRootVC: UITableViewController {

    @IBOutlet weak var signInItemBtn: UIBarButtonItem!
    
// for localized
    @IBOutlet weak var languagelabel: UILabel!
    @IBOutlet weak var languageContentLabel: UILabel!
    @IBOutlet weak var contactUsLabel: UILabel!
    @IBOutlet weak var logOutLabel: UILabel!
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.languagelabel.text = languageStr
        self.contactUsLabel.text = contactUsStr
        self.logOutLabel.text = logOutStr
        
      //  self.tableView.estimatedRowHeight = 50.0
      //  self.tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.setUpLogo()
        self.signInItemBtn.title = signInStr
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail)
        let userPassword = UserDefaults.standard.object(forKey: uPassword)
        if let _ = userEmail, let _ = userPassword {
            self.signInItemBtn.isEnabled = false
            self.signInItemBtn.tintColor = UIColor.clear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tempLanguage = UserDefaults.standard.object(forKey: uLanguage)
        
        if let _tempLanguage = tempLanguage as? String {
            self.languageContentLabel.text = _tempLanguage
        } else {
            self.languageContentLabel.text = english
        }
        
        let imgData = UserDefaults.standard.object(forKey: uPhoto) as? Data
        if let _imgData = imgData, let _img = UIImage(data: _imgData) {
            self.userImgView.image = _img
        } else {
            self.userImgView.image = UIImage(named: "userimg")
        }
        
        let nameFirst = UserDefaults.standard.object(forKey: uFirstName) as? String
        if let _nameFirst = nameFirst, (_nameFirst.trimmingCharacters(in: .whitespacesAndNewlines)).characters.count > 0 {
            self.userNameLabel.text = _nameFirst
        } else {
            let nameLast = UserDefaults.standard.object(forKey: uLastName) as? String
            if let _nameLast = nameLast, (_nameLast.trimmingCharacters(in: .whitespacesAndNewlines)).characters.count > 0 {
                self.userNameLabel.text = _nameLast
            } else {
                let nameNick = UserDefaults.standard.object(forKey: uNickName) as? String
                if let _nameNick = nameNick, (_nameNick.trimmingCharacters(in: .whitespacesAndNewlines)).characters.count > 0 {
                    self.userNameLabel.text = _nameNick
                } else {
                    self.userNameLabel.text = ""
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 10.0
        }
        return 8.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 3) {
            return 10.0
        }
        return 8.0
    }
/*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
*/
    // MARK: - Table view data source
/*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/
/*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
*/
/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
*/
    
    @IBAction func signinAction(_ sender: Any) {
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "loginNavigator")
        self.present(controller, animated: true, completion: nil)
    }
    

}
