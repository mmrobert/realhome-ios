//
//  BasementChooseVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-19.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit

class BasementChooseVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let basementSavedArray = [all, finished, unfinished, none, partial, separated_entrance, walk_out, crawl_space, walk_up, slab]
    
    var basementArray = [LanguageProperty.allStr, LanguageProperty.finishedStr, LanguageProperty.unfinishedStr, LanguageProperty.noneStr, LanguageProperty.partialStr, LanguageProperty.separated_entranceStr, LanguageProperty.walk_outStr, LanguageProperty.crawl_spaceStr, LanguageProperty.walk_upStr, LanguageProperty.slabStr]

    @IBOutlet weak var tableView: UITableView!
    
    public var chosedBasement: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        noteCenter.addObserver(self, selector: #selector(BasementChooseVC.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        basementArray = [LanguageProperty.allStr, LanguageProperty.finishedStr, LanguageProperty.unfinishedStr, LanguageProperty.noneStr, LanguageProperty.partialStr, LanguageProperty.separated_entranceStr, LanguageProperty.walk_outStr, LanguageProperty.crawl_spaceStr, LanguageProperty.walk_upStr, LanguageProperty.slabStr]
        
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basementArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basementListCell", for: indexPath)
        cell.textLabel?.text = basementArray[indexPath.row]
        
        if let _chosedBasement = self.chosedBasement, _chosedBasement == basementSavedArray[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tempBasement = basementSavedArray[indexPath.row]
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.broadNotify(newValue: tempBasement)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func broadNotify(newValue: String) {
        let key = "keyStr"
        let newValue = newValue
        let dictionaryInfo = [key: newValue]
        noteCenter.post(name: NSNotification.Name(rawValue: "BasementChosed"), object: nil, userInfo: dictionaryInfo)
    }
    
    deinit {
        noteCenter.removeObserver(self)
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
