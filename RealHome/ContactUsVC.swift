//
//  ContactUsVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-27.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsVC: UIViewController {

    @IBOutlet weak var pleaseEmailUsLabel: UILabel!
    @IBOutlet weak var emailUsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // for localized
        self.pleaseEmailUsLabel.text = LanguageGeneral.pleaseEmailUsIssueStr
        self.emailUsBtn.setTitle(LanguageGeneral.emailUsStr, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailUsAction(_ sender: Any) {
        let emailTitle = LanguageGeneral.reportIssuesStr
        let message = LanguageGeneral.reportHereStr
        let toWhom = [emailForIssues]
        
        if MFMailComposeViewController.canSendMail() {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(message, isHTML: false)
            mc.setToRecipients(toWhom)
            
            self.present(mc, animated: true, completion: nil)
        } else {
            self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.deviceCantSendEmailStr, confirmTitle: LanguageGeneral.okStr)
        }
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

extension ContactUsVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result) {
        case .cancelled, .saved, .sent, .failed:
            break
        }
        self.dismiss(animated: true, completion: nil)
      //  controller.dismiss(animated: true, completion: nil)
    }
}

