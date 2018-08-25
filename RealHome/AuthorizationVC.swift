//
//  AuthorizationVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-24.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import Alamofire
import Moya
import RxSwift
import Firebase

class AuthorizationVC: UIViewController {
    
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var errorMsgLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.appNameLabel.text = appName
        
        self.errorMsgLabel.text = ""
        
        noteCenter.addObserver(self, selector: #selector(AuthorizationVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        // for test
   //     UserDefaults.standard.set("agent11@aaa.com", forKey: uEmail)
   //     UserDefaults.standard.set("12345", forKey: uPassword)
   //     UserDefaults.standard.synchronize()
        //
  //      UserDefaults.standard.set("", forKey: uEmail)
  //      UserDefaults.standard.set("", forKey: uPassword)
  //      UserDefaults.standard.synchronize()
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        let languageUsed = UserDefaults.standard.object(forKey: uLanguage)
        
        if let _language = languageUsed as? String {
            LanguageGeneral.setLang(Lang: _language)
            LanguageProperty.setLang(Lang: _language)
        } else {
            LanguageGeneral.setLang(Lang: englishStr)
            LanguageProperty.setLang(Lang: englishStr)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.errorMsgLabel.text = ""
        
        let languageUsed = UserDefaults.standard.object(forKey: uLanguage)
        
        if let _language = languageUsed as? String {
            LanguageGeneral.setLang(Lang: _language)
            LanguageProperty.setLang(Lang: _language)
        } else {
            LanguageGeneral.setLang(Lang: englishStr)
            LanguageProperty.setLang(Lang: englishStr)
        }
        
        let uTokenH = UserDefaults.standard.object(forKey: uToken) as? String
        if let _uTokenH = uTokenH, _uTokenH.count > 20 {            
            toMainTabPage()
        } else {
            updateDeviceInfoServer()
        }
    }
    
    fileprivate func updateDeviceInfoServer() {
        let progs = MBProgressHUD.showAdded(to: self.view, animated: true)
        progs.label.text = LanguageGeneral.connectServerStr
        progs.removeFromSuperViewOnHide = true
        
        let parameterH: [String:Any] = ["op": "q51"]
        
        netWorkProvider.rx.request(.getUUID(paras: parameterH)).subscribe { [unowned self] event in
            progs.hide(animated: true)
            switch event {
            case .success(let response):
                do {
                    if let jsonDic = try response.mapJSON() as? [String:Any] {
                        if let uuidH = jsonDic["uuid"] as? String, uuidH.count > 20 {
                            UserDefaults.standard.set(uuidH, forKey: uToken)
                            UserDefaults.standard.synchronize()
                        }
                    }
                } catch {
                    debugPrint("Mapping Error in login: \(error.localizedDescription)")
                }
                self.toMainTabPage()
            case .error(let error):
                debugPrint("Networking Error in login: \(error.localizedDescription)")
                self.toMainTabPage()
            }}.disposed(by: disposeBag)
    }
    
    fileprivate func toMainTabPage() {
        let storyB = UIStoryboard(name: "TabsControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "MainTabsControllerSB")
        self.present(controller, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        noteCenter.removeObserver(self)
    }
}
