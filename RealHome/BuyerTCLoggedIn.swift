//
//  BuyerTCLoggedIn.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class BuyerTCLoggedIn: UITabBarController {

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
        
        let storyBBuyer = UIStoryboard(name: "BuyerControllers", bundle: nil)
        let controllerBuyer = storyBBuyer.instantiateViewController(withIdentifier: "BuyerTabRootNav")
        let tabBarItemBuyer = UITabBarItem(title: agentStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
        controllerBuyer.tabBarItem = tabBarItemBuyer
        
        self.viewControllers = [controllerSearch, controllerFavorites, controllerBuyer, controllerSettings]
        
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
    
    @IBAction func returnedFromLogOutBuyerTab(segue: UIStoryboardSegue) {
        
    }

}

extension BuyerTCLoggedIn: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _title = viewController.title {
            print("Selected \(_title)")
        }
    }
}

