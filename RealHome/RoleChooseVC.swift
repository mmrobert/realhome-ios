//
//  RoleChooseVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-25.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class RoleChooseVC: UIViewController {
    
    @IBOutlet weak var buyerImg: UIImageView!
    @IBOutlet weak var agentImg: UIImageView!
    @IBOutlet weak var buyerLabel: UILabel!
    @IBOutlet weak var agentLabel: UILabel!
    @IBOutlet weak var registerAsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.buyerImg.layer.cornerRadius = 10.0
        self.buyerImg.clipsToBounds = true
        self.agentImg.layer.cornerRadius = 10.0
        self.agentImg.clipsToBounds = true
        
        let toSignUpBuyer = UITapGestureRecognizer(target: self, action: #selector(RoleChooseVC.registerBuyer(tapGestureRecognizer:)))
        self.buyerImg.isUserInteractionEnabled = true
        self.buyerImg.addGestureRecognizer(toSignUpBuyer)
        
        let toSignUpBuyerL = UITapGestureRecognizer(target: self, action: #selector(RoleChooseVC.registerBuyerLabel(tapGestureRecognizer:)))
        self.buyerLabel.isUserInteractionEnabled = true
        self.buyerLabel.addGestureRecognizer(toSignUpBuyerL)
        
        let toSignUpAgent = UITapGestureRecognizer(target: self, action: #selector(RoleChooseVC.registerAgent(tapGestureRecognizer:)))
        self.agentImg.isUserInteractionEnabled = true
        self.agentImg.addGestureRecognizer(toSignUpAgent)
        
        let toSignUpAgentL = UITapGestureRecognizer(target: self, action: #selector(RoleChooseVC.registerAgentLabel(tapGestureRecognizer:)))
        self.agentLabel.isUserInteractionEnabled = true
        self.agentLabel.addGestureRecognizer(toSignUpAgentL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      // for localized
        self.registerAsLabel.text = LanguageGeneral.registerAsStr
        self.buyerLabel.text = LanguageGeneral.buyerSingleStr
        self.agentLabel.text = LanguageGeneral.agentStr
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func registerBuyer(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "registerpage") as! RegisterVC
        controller.role = "buyer"
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func registerAgent(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "registerpage") as! RegisterVC
        controller.role = "agent"
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func registerBuyerLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "registerpage") as! RegisterVC
        controller.role = "buyer"
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func registerAgentLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "registerpage") as! RegisterVC
        controller.role = "agent"
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
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
