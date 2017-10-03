//
//  MainTCNotLoggedIn.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class MainTCNotLoggedIn: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let storyBSearch = UIStoryboard(name: "SearchControllers", bundle: nil)
        let controllerSearch = storyBSearch.instantiateViewController(withIdentifier: "SearchTabRootNav")
        let tabBarItemSearch = UITabBarItem(title: searchStr, image: UIImage(named: "searchtab"), selectedImage: UIImage(named: "searchtab"))
        controllerSearch.tabBarItem = tabBarItemSearch
        
        let storyBFavorites = UIStoryboard(name: "FavoritesControllers", bundle: nil)
        let controllerFavorites = storyBFavorites.instantiateViewController(withIdentifier: "FavoritesTabRootNav")
        let tabBarItemFavorites = UITabBarItem(title: favoriteStr, image: UIImage(named: "favoritetab"), selectedImage: UIImage(named: "favoritetab"))
        controllerFavorites.tabBarItem = tabBarItemFavorites
        
        let storyBSettings = UIStoryboard(name: "SettingsControllers", bundle: nil)
        let controllerSettings = storyBSettings.instantiateViewController(withIdentifier: "SettingsTabRootNav")
        let tabBarItemSettings = UITabBarItem(title: settingStr, image: UIImage(named: "settingtab"), selectedImage: UIImage(named: "settingtab"))
        controllerSettings.tabBarItem = tabBarItemSettings
        
        self.viewControllers = [controllerSearch, controllerFavorites, controllerSettings]
        
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // register also return here
    @IBAction func returnedFromLogIn(segue: UIStoryboardSegue) {
        
        var existedVC = self.viewControllers
        let userRole: String? = UserDefaults.standard.object(forKey: uRole) as? String
        
        var controller: UIViewController?
        var tabBarItemAdded: UITabBarItem?
        
        if let _userRole = userRole, _userRole == "buyer" {
            let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
            controller = storyB.instantiateViewController(withIdentifier: "BuyerTabRootNav")
            tabBarItemAdded = UITabBarItem(title: agentStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
        } else {
            let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
            controller = storyB.instantiateViewController(withIdentifier: "AgentTabRootNav")
            tabBarItemAdded = UITabBarItem(title: buyerStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
        }
        
        controller?.tabBarItem = tabBarItemAdded
        
        if let _controller = controller {
            existedVC?.insert(_controller, at: 2)
        }
        
        self.viewControllers = existedVC
    }
    
    @IBAction func returnedFromLogInCancel(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func returnedFromLogOutMainTab(segue: UIStoryboardSegue) {
        
    }

}

extension MainTCNotLoggedIn: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _title = viewController.title {
            print("Selected \(_title)")
        }
    }
}

