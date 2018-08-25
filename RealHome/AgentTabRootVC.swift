//
//  AgentTabRootVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class AgentTabRootVC: UIViewController {
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var recommendationView: UIView!
    @IBOutlet weak var recommendationLabel: UILabel!
    
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var serviceView: UIView!
    @IBOutlet weak var serviceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpLogo()
        
        let toMsgBoxVC = UITapGestureRecognizer(target: self, action: #selector(AgentTabRootVC.messageBoxVC(tapGestureRecognizer:)))
        self.messageView.isUserInteractionEnabled = true
        self.messageView.addGestureRecognizer(toMsgBoxVC)
        
        let toRecommendationVC = UITapGestureRecognizer(target: self, action: #selector(AgentTabRootVC.recommendationVC(tapGestureRecognizer:)))
        self.recommendationView.isUserInteractionEnabled = true
        self.recommendationView.addGestureRecognizer(toRecommendationVC)
        
        let toPostVC = UITapGestureRecognizer(target: self, action: #selector(AgentTabRootVC.postVC(tapGestureRecognizer:)))
        self.postView.isUserInteractionEnabled = true
        self.postView.addGestureRecognizer(toPostVC)
        
        let toServiceVC = UITapGestureRecognizer(target: self, action: #selector(AgentTabRootVC.serviceVC(tapGestureRecognizer:)))
        self.serviceView.isUserInteractionEnabled = true
        self.serviceView.addGestureRecognizer(toServiceVC)
        
     //   let ttttqq = FirebaseNodesCreation.decodeEmail(email: "a成部@aaa.com")
     //   print("成部@aaa.com")
     //   print(ttttqq)
    }

/*
    private func getTestFIR() {
        let testArrQuery = testRef?.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // posts from the Firebase DB with ".value"
        testHandle = testArrQuery?.observe(.value, with: { [unowned self] (snapshot) -> Void in
            
            for itemSnap in snapshot.children {
                if let _itemSnap = itemSnap as? DataSnapshot {
                    let testKey = _itemSnap.key
                    let testData = _itemSnap.value as? String ?? ""
                    if testKey == "title2" {
                        print("1-23-289pm-----" + testData)
                    } else if testKey == "title3" {
                        let imgDataH = HelpFunctions.stringBase64ToPhoto(imgString: testData)
                        self.testImgV.image = UIImage(data: imgDataH!)
                    } else {
                        print("Error! Could not decode buyer data in agent msg box")
                    }
                }
            }
        })
    }
*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.messageLabel.text = LanguageGeneral.messages
        self.recommendationLabel.text = LanguageGeneral.recommendations
        self.postLabel.text = LanguageGeneral.posts
        self.serviceLabel.text = LanguageGeneral.services
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
    
    @objc fileprivate func messageBoxVC(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "msgBoxVCinAgent") as! MsgBoxAgent
        controller.hidesBottomBarWhenPushed = true
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func recommendationVC(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "recommendationVCinAgent") as! RecommendationVCAgent
        controller.hidesBottomBarWhenPushed = true
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func postVC(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "postVCinAgent") as! PostVCAgent
        controller.hidesBottomBarWhenPushed = true
        if (self.responds(to: #selector(self.show(_:sender:)))) {
            self.show(controller, sender: self)
        } else {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc fileprivate func serviceVC(tapGestureRecognizer: UITapGestureRecognizer) {
        let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "serviceVCinAgent") as! ServiceVCAgent
        controller.hidesBottomBarWhenPushed = true
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
