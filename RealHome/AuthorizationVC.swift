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

class AuthorizationVC: UIViewController {
    
    @IBOutlet weak var errorMsgLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.errorMsgLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.errorMsgLabel.text = ""
        /*
         NSString *email = @"aa@bb.ca";
         [[NSUserDefaults standardUserDefaults] setObject:email forKey:myEmail];
         NSString *password = @"12345";
         [[NSUserDefaults standardUserDefaults] setObject:password forKey:myPassword];
         NSString *role = @"customer";
         [[NSUserDefaults standardUserDefaults] setObject:role forKey:myRole];
         [[NSUserDefaults standardUserDefaults] synchronize];
         */
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail)
        let userPassword = UserDefaults.standard.object(forKey: uPassword)
        
        //  [[NSUserDefaults standardUserDefaults] removeObjectForKey:myCountry];
        
        if let _ = userEmail, let _ = userPassword {
            self.connectingServer()
        } else {
        
            let storyB = UIStoryboard(name: "TabsControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "MainTabsNotLoggedIn")
            self.present(controller, animated: true, completion: nil)
 /*
            let storyB = UIStoryboard(name: "TabsControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "BuyerTabsLoggedIn")
            self.present(controller, animated: true, completion: nil)
 */
        }
    }
    
// networking
    
    fileprivate func connectingServer() -> Void {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = connectServerStr
        
        let userToken = UserDefaults.standard.object(forKey: uToken)
        let allowNotification = UserDefaults.standard.object(forKey: uNotificationAllow)
        let dToken = UserDefaults.standard.object(forKey: uDeviceToken)
        
        netWorkProvider.requestWithProgress(.index).subscribe { [unowned self] event in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch event {
            case .next(let response):
                if response.completed {
                    do {
                        if let jsonArray = try response.response?.mapJSON() as? Array<Any> {
                            if jsonArray.count > 0 {
                                for medJSON: [String : Any] in jsonArray as! [[String : Any]] {
                                    //   let medStruct = Medicine(object: medJSON)
                                    //   self.medListStruct.append(medStruct)
                                }
                            }
                        }
                    } catch {
                        debugPrint("Mapping Error: \(error.localizedDescription)")
                    }
                    // to-do
                    self.toLoggedInPages()
                }
            case .error(let error):
                debugPrint("Mapping Error: \(error.localizedDescription)")
                self.errorMsgLabel.text = errMsgRestartApp
            default:
                break
            }}.addDisposableTo(disposeBag)
    }
    
    fileprivate func toLoggedInPages() {
        
        let userRole: String? = UserDefaults.standard.object(forKey: uRole) as? String
        
        if let _userRole = userRole, _userRole == "buyer" {
            let storyB = UIStoryboard(name: "TabsControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "BuyerTabsLoggedIn")
            self.present(controller, animated: true, completion: nil)
        } else {
            let storyB = UIStoryboard(name: "TabsControllers", bundle: nil)
            let controller = storyB.instantiateViewController(withIdentifier: "AgentTabsLoggedIn")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let enterPWHandler: Handler = {action in
            
            /*
             NSString *tagStr = [NSString stringWithFormat:@"%ld", (long)tapGestureRecognizer.view.tag];
             //    NSLog(@"uuuuuuuuTTT---%@", tagStr);
             controller.viewTag = tagStr;
             */
            /*
             if (self.responds(to: #selector(self.show(_:sender:)))) {
             self.show(controller, sender: self)
             } else {
             self.navigationController?.pushViewController(controller, animated: true)
             }
             */
            //  self.present(controller, animated: true, completion: nil)
        }
        /*
         let closeAppHandler: Handler = {action in
         exit(0)
         }
         */
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert);
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: enterPWHandler)
        alert.addAction(enterPWAct);
        //   let closeAppAct = UIAlertAction(title: "Close App", style: .default, handler: closeAppHandler)
        //   alert.addAction(closeAppAct)
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
