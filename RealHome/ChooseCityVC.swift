//
//  ChooseCityVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-12.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import RATreeView

class ChooseCityVC: UIViewController, RATreeViewDataSource, RATreeViewDelegate {
    
    @IBOutlet weak var cancelItemBtn: UIBarButtonItem!
    @IBOutlet weak var searchItemBtn: UIBarButtonItem!
    
    var treeView : RATreeView!
    var data : [DataObjectInTree]
    
    public var oldState: String?
    public var oldCity: String?
    var newState: String?
    var newCity: String?
    
    var selectedItem: DataObjectInTree?
    
    var searchCityLati: String?
    var searchCityLong: String?
    
    convenience init() {
        self.init(nibName : nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        data = DataObjectInTree.cityDataInit()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        data = DataObjectInTree.cityDataInit()
        super.init(coder: aDecoder)
       // fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newState = self.oldState
        self.newCity = self.oldCity

        // Do any additional setup after loading the view.
        self.setupTreeView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.cancelItemBtn.title = LanguageGeneral.cancelStr
        self.searchItemBtn.title = LanguageGeneral.searchStr
    }
    
    func setupTreeView() -> Void {
        treeView = RATreeView(frame: view.bounds)
        treeView.register(UINib(nibName: String(describing: CityTreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CityTreeTableViewCell.self))
        treeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        treeView.delegate = self
        treeView.dataSource = self
        treeView.treeFooterView = UIView()
        treeView.backgroundColor = .clear
        treeView.allowsMultipleSelection = false
        view.addSubview(treeView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: RATreeView data source
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? DataObjectInTree {
            return item.children.count
        } else {
            return self.data.count
        }
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? DataObjectInTree {
            return item.children[index]
        } else {
            return data[index] as AnyObject
        }
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: CityTreeTableViewCell.self)) as! CityTreeTableViewCell
        let item = item as! DataObjectInTree
        
        let level = treeView.levelForCell(forItem: item)
        cell.selectionStyle = .none
        
        cell.setup(withTitle: item.name, level: level)
        
        let parent = treeView.parent(forItem: item) as? DataObjectInTree
        let parentName = parent?.name ?? ""
        
        if let nCity = self.newCity, let nState = self.newState {
            if item.name == nCity && nState == parentName {
                cell.accessoryType = .checkmark
                self.selectedItem = item
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    //MARK: RATreeView delegate
    
    func treeView(_ treeView: RATreeView, didSelectRowForItem item: Any) {
        
        let item = item as! DataObjectInTree
        let level = treeView.levelForCell(forItem: item)
        if level == 0 {
            treeView.deselectRow(forItem: item, animated: true)
        } else if level == 1 {
            if let _selectedItem = self.selectedItem {
                treeView.cell(forItem: _selectedItem)?.accessoryType = .none
            }
            treeView.cell(forItem: item)?.accessoryType = .checkmark
           // print(item.name)
            let parent = treeView.parent(forItem: item) as? DataObjectInTree
        //    print(item.name + " " + (parent?.name)!)
            self.newState = parent?.name
            self.newCity = item.name
            self.searchCityLati = item.location?.latitude
            self.searchCityLong = item.location?.longitude
        }
    }
    
    func treeView(_ treeView: RATreeView, didDeselectRowForItem item: Any) {
        
        let item = item as! DataObjectInTree
        treeView.cell(forItem: item)?.accessoryType = .none
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        if self.newState != self.oldState {
            UserDefaults.standard.set(true, forKey: isSearchFilterChanged)
            UserDefaults.standard.set(self.newState, forKey: stateSearch)
            UserDefaults.standard.set(self.newCity, forKey: citySearch)
            UserDefaults.standard.set(self.searchCityLati, forKey: citySearchLati)
            UserDefaults.standard.set(self.searchCityLong, forKey: citySearchLong)
            UserDefaults.standard.synchronize()
        } else {
            if self.newCity != self.oldCity {
                UserDefaults.standard.set(true, forKey: isSearchFilterChanged)
                UserDefaults.standard.set(self.newState, forKey: stateSearch)
                UserDefaults.standard.set(self.newCity, forKey: citySearch)
                UserDefaults.standard.set(self.searchCityLati, forKey: citySearchLati)
                UserDefaults.standard.set(self.searchCityLong, forKey: citySearchLong)
                UserDefaults.standard.synchronize()
            }
        }
        
        self.performSegue(withIdentifier: "cityReturnToSearch", sender: self)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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


