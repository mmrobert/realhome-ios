//
//  LogOutVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-27.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData

class LogOutVC: UIViewController {
    
    @IBOutlet weak var thankYouLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var logOutBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.appNameLabel.text = appName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      // for localized
        self.thankYouLabel.text = LanguageGeneral.thankYouForUsingStr
        self.logOutBtn.setTitle(LanguageGeneral.logOutStr, for: .normal)
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let userPassword = UserDefaults.standard.object(forKey: uPassword) as? String
        
        if let _ = userEmail, let _ = userPassword {
            
        } else {
         //   print("logout pop")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        self.connectingServer()
    }
    
    fileprivate func connectingServer() {
        
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let userPassword = UserDefaults.standard.object(forKey: uPassword) as? String
        
        let emailH: String = userEmail ?? ""
        let pwH: String = userPassword ?? ""
        
        
        let parameterH: [String:Any] = ["op": "q25",
                                        "email": emailH,
                                        "password": pwH]
        
        netWorkProvider.rx.request(.logout(paras: parameterH)).subscribe { [unowned self] event in
            progs.hide(animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonDic = try response.mapJSON() as? [String:Any] {
                        if let succ = jsonDic["success"] as? String, succ == "true" {
                            if let _logout = jsonDic["logout"] as? String, _logout == "true" {
                                self.logoutReturned()
                            } else {
                                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgTryAgainStr, confirmTitle: LanguageGeneral.okStr)
                            }
                        } else {
                            self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgTryAgainStr, confirmTitle: LanguageGeneral.okStr)
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in login: \(error.localizedDescription)")
                }
            case .error(let error):
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgNetworkErrorStr, confirmTitle: LanguageGeneral.okStr)
                debugPrint("Networking Error in login: \(error.localizedDescription)")
            }}.disposed(by: disposeBag)
    }
    
    fileprivate func logoutReturned() {
        
        UserDefaults.standard.removeObject(forKey: uEmail)
        UserDefaults.standard.removeObject(forKey: uPassword)
        UserDefaults.standard.removeObject(forKey: uRole)
        UserDefaults.standard.removeObject(forKey: uToken)
        
        let userRole = UserDefaults.standard.object(forKey: uRole) as? String
        if let _userRole = userRole, _userRole == "buyer" {
            //  CoreDataController.deleteAgentGroupAllBuyer()
        } else {
            //  CoreDataController.deleteAgentGroupAll()
        }
        
        self.performSegue(withIdentifier: "logoutReturnToMainTab", sender: self)
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
}
