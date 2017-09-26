//
//  SettingsTabRootVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class SettingsTabRootVC: UIViewController {
    
    @IBOutlet weak var signInItemBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpLogo()
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail)
        let userPassword = UserDefaults.standard.object(forKey: uPassword)
        if let _ = userEmail, let _ = userPassword {
            self.signInItemBtn.isEnabled = false
            self.signInItemBtn.tintColor = UIColor.clear
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
    
    @IBAction func signinAction(_ sender: Any) {
        let storyB = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyB.instantiateViewController(withIdentifier: "loginNavigator")
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

}
