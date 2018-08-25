//
//  MainTabsController.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-26.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class MainTabsController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let storyBSearch = UIStoryboard(name: "SearchControllers", bundle: nil)
        let controllerSearch = storyBSearch.instantiateViewController(withIdentifier: "SearchTabRootNav") as! UINavigationController
        let tabBarItemSearch = UITabBarItem(title: LanguageGeneral.searchStr, image: UIImage(named: "searchtab"), selectedImage: UIImage(named: "searchtab"))
        controllerSearch.tabBarItem = tabBarItemSearch
        if let firstVC = controllerSearch.viewControllers[0] as? SearchTabRootVC {
            firstVC.agentGroupDelegate = self
        }
        
        let storyBFavorites = UIStoryboard(name: "FavoritesControllers", bundle: nil)
        let controllerFavorites = storyBFavorites.instantiateViewController(withIdentifier: "FavoritesTabRootNav") as! UINavigationController
        let tabBarItemFavorites = UITabBarItem(title: LanguageGeneral.favoriteStr, image: UIImage(named: "favoritetab"), selectedImage: UIImage(named: "favoritetab"))
        controllerFavorites.tabBarItem = tabBarItemFavorites
        if let firstVC = controllerFavorites.viewControllers[0] as? FavoritesTabRootVC {
            firstVC.agentGroupDelegate = self
        }
        
        let storyBSettings = UIStoryboard(name: "SettingsControllers", bundle: nil)
        let controllerSettings = storyBSettings.instantiateViewController(withIdentifier: "SettingsTabRootNav") as! UINavigationController
        let tabBarItemSettings = UITabBarItem(title: LanguageGeneral.settingStr, image: UIImage(named: "settingtab"), selectedImage: UIImage(named: "settingtab"))
        controllerSettings.tabBarItem = tabBarItemSettings
        if let firstVC = controllerSettings.viewControllers[0] as? SettingsTabRootVC {
            firstVC.agentGroupDelegate = self
        }
        
        let userEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let userPassword = UserDefaults.standard.object(forKey: uPassword) as? String
        let userRole: String? = UserDefaults.standard.object(forKey: uRole) as? String
        
        var agentGroupID: String?
        if let _userRole = userRole, _userRole == "buyer" {
            let idArrH = CoreDataController.fetchAgentGroupsBuyer()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        } else {
            let idArrH = CoreDataController.fetchAgentGroups()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        }
        
        if let em = userEmail, let pa = userPassword, em.count > 1, pa.count > 0 {
            
            if let _agentGroupID = agentGroupID, _agentGroupID.count > 2 {
                
                if let _userRole = userRole, _userRole == "buyer" {
                    let storyBBuyer = UIStoryboard(name: "BuyerControllers", bundle: nil)
                    let controllerBuyer = storyBBuyer.instantiateViewController(withIdentifier: "BuyerTabRootNav")
                    let tabBarItemBuyer = UITabBarItem(title: LanguageGeneral.agentStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
                    controllerBuyer.tabBarItem = tabBarItemBuyer
                    
                    self.viewControllers = [controllerSearch, controllerFavorites, controllerBuyer, controllerSettings]
                } else {
                    let storyBAgent = UIStoryboard(name: "AgentControllers", bundle: nil)
                    let controllerAgent = storyBAgent.instantiateViewController(withIdentifier: "AgentTabRootNav")
                    let tabBarItemAgent = UITabBarItem(title: LanguageGeneral.buyerStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
                    controllerAgent.tabBarItem = tabBarItemAgent
                    
                    self.viewControllers = [controllerSearch, controllerFavorites, controllerAgent, controllerSettings]
                }
            } else {
                self.viewControllers = [controllerSearch, controllerFavorites, controllerSettings]
            }
        } else {
            self.viewControllers = [controllerSearch, controllerFavorites, controllerSettings]
        }
        
        self.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(MainTabsController.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        let userRole: String? = UserDefaults.standard.object(forKey: uRole) as? String
        
        if let tabItemCount = self.tabBar.items?.count {
            if tabItemCount < 4 {
                self.tabBar.items?[0].title = LanguageGeneral.searchStr
                self.tabBar.items?[1].title = LanguageGeneral.favoriteStr
                self.tabBar.items?[2].title = LanguageGeneral.settingStr
            } else {
                if let _userRole = userRole, _userRole == "buyer" {
                    self.tabBar.items?[0].title = LanguageGeneral.searchStr
                    self.tabBar.items?[1].title = LanguageGeneral.favoriteStr
                    self.tabBar.items?[2].title = LanguageGeneral.agentStr
                    self.tabBar.items?[3].title = LanguageGeneral.settingStr
                } else {
                    self.tabBar.items?[0].title = LanguageGeneral.searchStr
                    self.tabBar.items?[1].title = LanguageGeneral.favoriteStr
                    self.tabBar.items?[2].title = LanguageGeneral.buyerStr
                    self.tabBar.items?[3].title = LanguageGeneral.settingStr
                }
            }
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
    
    // register also return here
    @IBAction func returnedFromLogIn(segue: UIStoryboardSegue) {
        
        let userRole: String? = UserDefaults.standard.object(forKey: uRole) as? String
        var agentGroupID: String?
        
        if let _userRole = userRole, _userRole == "buyer" {
            let idArrH = CoreDataController.fetchAgentGroupsBuyer()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        } else {
            let idArrH = CoreDataController.fetchAgentGroups()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        }
        
        if let _agentGroupID = agentGroupID, _agentGroupID.count > 2 {
        
            var existedVC = self.viewControllers
            
            var controller: UIViewController?
            var tabBarItemAdded: UITabBarItem?
            
            if let _userRole = userRole, _userRole == "buyer" {
                let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
                controller = storyB.instantiateViewController(withIdentifier: "BuyerTabRootNav")
                tabBarItemAdded = UITabBarItem(title: LanguageGeneral.agentStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
            } else {
                let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
                controller = storyB.instantiateViewController(withIdentifier: "AgentTabRootNav")
                tabBarItemAdded = UITabBarItem(title: LanguageGeneral.buyerStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
            }
            
            controller?.tabBarItem = tabBarItemAdded
            
            if let _controller = controller, let _existedVC = existedVC, _existedVC.count < 4 {
                existedVC?.insert(_controller, at: 2)
            }
            
            self.viewControllers = existedVC
        }
    }
    
    @IBAction func returnedFromLogInCancel(segue: UIStoryboardSegue) {
        
        let userRole: String? = UserDefaults.standard.object(forKey: uRole) as? String
        var agentGroupID: String?
        
        if let _userRole = userRole, _userRole == "buyer" {
            let idArrH = CoreDataController.fetchAgentGroupsBuyer()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        } else {
            let idArrH = CoreDataController.fetchAgentGroups()
            if idArrH.count > 0 {
                agentGroupID = idArrH[0].value(forKeyPath: "groupID") as? String
            }
        }
        
        if let _agentGroupID = agentGroupID, _agentGroupID.count > 2 {
            
            var existedVC = self.viewControllers
            
            var controller: UIViewController?
            var tabBarItemAdded: UITabBarItem?
            
            if let _userRole = userRole, _userRole == "buyer" {
                let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
                controller = storyB.instantiateViewController(withIdentifier: "BuyerTabRootNav")
                tabBarItemAdded = UITabBarItem(title: LanguageGeneral.agentStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
            } else {
                let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
                controller = storyB.instantiateViewController(withIdentifier: "AgentTabRootNav")
                tabBarItemAdded = UITabBarItem(title: LanguageGeneral.buyerStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
            }
            
            controller?.tabBarItem = tabBarItemAdded
            
            if let _controller = controller, let _existedVC = existedVC, _existedVC.count < 4 {
                existedVC?.insert(_controller, at: 2)
            }
            
            self.viewControllers = existedVC
        }
    }
    
    @IBAction func returnedFromLogOutMainTab(segue: UIStoryboardSegue) {
        
        if let tabItemCount = self.tabBar.items?.count {
            if tabItemCount < 4 {
               self.selectedIndex = 0
            } else {
                var existedVC = self.viewControllers
                existedVC?.remove(at: 2)
                self.viewControllers = existedVC
                
                self.selectedIndex = 0
            }
        }
    }

    deinit {
        noteCenter.removeObserver(self)
    }
}

extension MainTabsController: AddAgentGroup {
    
    func toAddAgentGroup(role: String) {
        
        var existedVC = self.viewControllers
        
        var controller: UIViewController?
        var tabBarItemAdded: UITabBarItem?
        
        if role == "buyer" {
            let storyB = UIStoryboard(name: "BuyerControllers", bundle: nil)
            controller = storyB.instantiateViewController(withIdentifier: "BuyerTabRootNav")
            tabBarItemAdded = UITabBarItem(title: LanguageGeneral.agentStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
        } else {
            let storyB = UIStoryboard(name: "AgentControllers", bundle: nil)
            controller = storyB.instantiateViewController(withIdentifier: "AgentTabRootNav")
            tabBarItemAdded = UITabBarItem(title: LanguageGeneral.buyerStr, image: UIImage(named: "agenttab"), selectedImage: UIImage(named: "agenttab"))
        }
        
        controller?.tabBarItem = tabBarItemAdded
        
        if let _controller = controller, let _existedVC = existedVC, _existedVC.count < 4 {
            existedVC?.insert(_controller, at: 2)
        }
        
        self.viewControllers = existedVC
    }
}

extension MainTabsController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.title != nil {
          //  print("Selected \(_title)")
        }
    }
}


