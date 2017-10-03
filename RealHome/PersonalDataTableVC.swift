//
//  PersonalDataTableVC.swift
//  RealHome
//
//  Created by boqian cheng on 2017-09-28.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

class PersonalDataTableVC: UITableViewController {
    
    var photoAlbum: UIImagePickerController?
    var camera: UIImagePickerController?
    
    var pickedLargeImg: UIImage?
    var imgData: Data?
    
    var oldPhoto: Data?
    var oldFirstName: String?
    var oldLastName: String?
    var oldNickName: String?
    var oldGender: String?
    var oldEmail: String?
    var oldPhone: String?
    
    var newPhoto: Data?
    var newFirstName: String?
    var newLastName: String?
    var newNickName: String?
    var newGender: String?
    var newEmail: String?
    var newPhone: String?
    
    var isDataChanged: Bool = false
    
    let namesCaptions = [firstNameStr, lastNameStr, nickNameStr]
    let contactCaptions = [emailStr, phoneStr]
    
    var namesFieldValueArr: [String?] = []
    var contactFieldValueArr: [String?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBackArrow()
        
        self.prepareData()
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.title = yourPersonalInfoStr

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        let dismiss = UITapGestureRecognizer(target: self, action: #selector(PersonalDataTableVC.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        //  dismiss.cancelsTouchesInView = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func prepareData() {
        
        self.oldPhoto = UserDefaults.standard.object(forKey: uPhoto) as? Data
        self.oldGender = UserDefaults.standard.object(forKey: uGender) as? String
        
        if let fn = UserDefaults.standard.object(forKey: uFirstName) as? String {
            self.oldFirstName = fn
        } else {
            self.oldFirstName = ""
        }
        if let ln = UserDefaults.standard.object(forKey: uLastName) as? String {
            self.oldLastName = ln
        } else {
            self.oldLastName = ""
        }
        if let nn = UserDefaults.standard.object(forKey: uNickName) as? String {
            self.oldNickName = nn
        } else {
            self.oldNickName = ""
        }
        if let em = UserDefaults.standard.object(forKey: uEmail) as? String {
            self.oldEmail = em
        } else {
            self.oldEmail = ""
        }
        if let ph = UserDefaults.standard.object(forKey: uPhone) as? String {
            self.oldPhone = ph
        } else {
            self.oldPhone = ""
        }
        
        self.newFirstName = self.oldFirstName
        self.newLastName = self.oldLastName
        self.newNickName = self.oldNickName
        self.newGender = self.oldGender
        self.newEmail = self.oldEmail
        self.newPhone = self.oldPhone
        self.newPhoto = self.oldPhoto
        
        self.namesFieldValueArr = [self.newFirstName, self.newLastName, self.newNickName]
        self.contactFieldValueArr = [self.newEmail, self.newPhone]
    }
    
    fileprivate func addBackArrow() {
        
        self.navigationItem.hidesBackButton = true
        
        let navController = self.navigationController
        var bannerHeight: CGFloat = 0
        
        if let _navController = navController {
            //  let bannerWidth = _navController.navigationBar.frame.size.width
            bannerHeight = _navController.navigationBar.frame.size.height
        }
        
        let reducedHeight = bannerHeight - 22
        
        let logoImage = UIImage(named: "iosleftarrow")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.frame = CGRect(x: 0, y: 0, width: reducedHeight, height: reducedHeight)
        logoImageView.contentMode = .scaleAspectFit
        
        let logoLabel = UILabel()
        logoLabel.text = backStr
        logoLabel.font = UIFont.systemFont(ofSize: 18)
        logoLabel.textAlignment = .left
        logoLabel.textColor = UIColor(red: 4/255, green: 124/255, blue: 252/255, alpha: 1.0)
        logoLabel.frame = CGRect(x: reducedHeight, y: 0, width: 42, height: reducedHeight)
        
        let logoView = UIView(frame: CGRect(x: 0, y: 0, width: reducedHeight + 42, height: reducedHeight))
        logoView.addSubview(logoImageView)
        logoView.addSubview(logoLabel)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(PersonalDataTableVC.backBtnPressed(regognizer:)))
        logoView.isUserInteractionEnabled = true
        logoView.addGestureRecognizer(backTap)
        
        let newBackBtn = UIBarButtonItem(customView: logoView)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -11
        
        self.navigationItem.leftBarButtonItems = [negativeSpacer, newBackBtn]
    }
    
    @objc fileprivate func backBtnPressed(regognizer: UITapGestureRecognizer) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        if (self.newPhoto != self.oldPhoto || self.newFirstName != self.oldFirstName || self.newLastName != self.oldLastName || self.newNickName != self.oldNickName || self.newGender != self.oldGender || self.newEmail != self.oldEmail || self.newPhone != self.oldPhone) {
            let notSave: Handler = { [unowned self] action in
                self.navigationController?.popViewController(animated: true)
            }
            let toSave: Handler = { [unowned self] action in
                self.connectingServer()
                self.navigationController?.popViewController(animated: true)
            }
            
            let alert = UIAlertController(title: nil, message: errMsgLeavingWithoutSaveStr, preferredStyle: .alert)
            let notSaveAct = UIAlertAction(title: notSaveStr, style: .default, handler: notSave)
            let toSaveAct = UIAlertAction(title: saveStr, style: .default, handler: toSave)
            let cancelAct = UIAlertAction(title: cancelStr, style: .default, handler: nil)
            
            alert.addAction(toSaveAct)
            alert.addAction(notSaveAct)
            alert.addAction(cancelAct)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func dismissKeyboard() {
        //  self.view.endEditing(true)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    fileprivate func saveChanges() {
        
        UserDefaults.standard.set(self.newPhoto, forKey: uPhoto)
        UserDefaults.standard.set(self.newFirstName, forKey: uFirstName)
        UserDefaults.standard.set(self.newLastName, forKey: uLastName)
        UserDefaults.standard.set(self.newNickName, forKey: uNickName)
        UserDefaults.standard.set(self.newGender, forKey: uGender)
        UserDefaults.standard.set(self.newEmail, forKey: uEmail)
        UserDefaults.standard.set(self.newPhone, forKey: uPhone)
        
        UserDefaults.standard.synchronize()
        
        self.oldPhoto = self.newPhoto
        self.oldFirstName = self.newFirstName
        self.oldLastName = self.newLastName
        self.oldNickName = self.newNickName
        self.oldGender = self.newGender
        self.oldEmail = self.newEmail
        self.oldPhone = self.newPhone
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 1
        case 3:
            return 2
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let firstC = String(indexPath.section + 1)
        let secondC = String(indexPath.row)
        let theStr = firstC + secondC
        
        let tagInt = Int(theStr)!
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userimgcellSettings", for: indexPath) as! UserImgSettingsTableCell
            cell.changePhotoDelegate = self
            if let _newPhotoData = self.newPhoto, let _newImg = UIImage(data: _newPhotoData) {
                cell.userImg.image = _newImg
            } else {
                cell.userImg.image = UIImage(named: "userimg")
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCellSettings", for: indexPath) as! TextFieldSettingsTableCell
            cell.fieldNameLabel.text = self.namesCaptions[indexPath.row]
            cell.textField.text = self.namesFieldValueArr[indexPath.row]
            cell.textField.tag = tagInt
            cell.changeTextDelegate = self
          //  print(cell.textField.frame.size.width)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "genderCell", for: indexPath) as! GenderChoiceTableCell
            cell.fieldNameLabel.text = genderStr
            if let _newGender = self.newGender, _newGender == "male" {
                cell.maleBtn.isSelected = true
            } else if let _newGender = self.newGender, _newGender == "female" {
                cell.femaleBtn.isSelected = true
            }
            cell.genderChoiceDelegate = self
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCellSettings", for: indexPath) as! TextFieldSettingsTableCell
            cell.fieldNameLabel.text = self.contactCaptions[indexPath.row]
            cell.textField.text = self.contactFieldValueArr[indexPath.row]
            cell.textField.tag = tagInt
            cell.changeTextDelegate = self
            if indexPath.row == 0 {
                cell.textField.isUserInteractionEnabled = false
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "errorMsgCell", for: indexPath) as! ErrorMsgTableCell
            cell.errMsgLabel.text = errMsgUnknow
            return cell
        }

        // Configure the cell...
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 8.0
        }
        return 6.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 3) {
            return 8.0
        }
        return 6.0
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        if (self.newPhoto != self.oldPhoto || self.newFirstName != self.oldFirstName || self.newLastName != self.oldLastName || self.newNickName != self.oldNickName || self.newGender != self.oldGender || self.newEmail != self.oldEmail || self.newPhone != self.oldPhone) {
            
            self.connectingServer()
        }
    }
    
    fileprivate func connectingServer() {
        self.saveChanges()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension PersonalDataTableVC: ChangePhotoSettings {
    
    func toChangePhoto(_ cellView: UserImgSettingsTableCell) {
       // print("delegate carry on")
        self.choosePhoto(cellView: cellView)
    }
    
    func choosePhoto(cellView: UserImgSettingsTableCell) {
        
        typealias Handler = (UIAlertAction?) -> Void
        
        let handlerAlbums: Handler = {action in
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum)) {
                self.photoAlbum = UIImagePickerController()
                self.photoAlbum!.allowsEditing = true
                self.photoAlbum!.mediaTypes = [kUTTypeImage as String]
                self.photoAlbum!.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.photoAlbum!.delegate = self
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
                    self.present(self.photoAlbum!, animated: true, completion: nil)
                } else {
                    self.photoAlbum!.modalPresentationStyle = UIModalPresentationStyle.popover
                    self.present(self.photoAlbum!, animated: true, completion: nil)
                    
                    let popController = self.photoAlbum!.popoverPresentationController
                    popController!.permittedArrowDirections = UIPopoverArrowDirection.any
                    popController!.sourceView = self.view
                    popController!.sourceRect = CGRect(x: 10, y: 10, width: 10, height: 10)
                    popController!.delegate = self
                    
                }
            }
        }
        
        let handlerCamera: Handler = {action in
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                self.camera = UIImagePickerController()
                self.camera!.allowsEditing = true
                self.camera!.mediaTypes = [kUTTypeImage as String]
                self.camera!.sourceType = UIImagePickerControllerSourceType.camera
                self.camera!.delegate = self
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
                    self.present(self.camera!, animated: true, completion: nil)
                } else {
                    self.camera!.modalPresentationStyle = UIModalPresentationStyle.popover
                    self.present(self.camera!, animated: true, completion: nil)
                    
                    let popController = self.camera!.popoverPresentationController
                    popController!.permittedArrowDirections = UIPopoverArrowDirection.any
                    popController!.sourceView = self.view
                    popController!.sourceRect = CGRect(x: 10, y: 10, width: 10, height: 10)
                    popController!.delegate = self
                    
                }
            }
        }
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        let albumAct = UIAlertAction(title: chooseFromAlbumStr, style: .default, handler: handlerAlbums)
        let cameraAct = UIAlertAction(title: takePhotoStr, style: .default, handler: handlerCamera)
        let cancelAct = UIAlertAction(title: cancelStr, style: .cancel, handler: nil)
        alert.addAction(albumAct);
        alert.addAction(cameraAct)
        alert.addAction(cancelAct)
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            self.present(alert, animated: true, completion: nil)
        } else {
            alert.modalPresentationStyle = UIModalPresentationStyle.popover
            let popPresenter = alert.popoverPresentationController
            popPresenter!.permittedArrowDirections = UIPopoverArrowDirection.any
            popPresenter!.sourceView = cellView
            popPresenter!.sourceRect = cellView.bounds
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension PersonalDataTableVC: GenderChoiceSettings {
    func toChangeGender(_ cellView: GenderChoiceTableCell, gender: String) {
        self.newGender = gender
    }
}

extension PersonalDataTableVC: ChangeTextSettings {
    
    func toChangeText(_ cellView: TextFieldSettingsTableCell, _ newtxValue: String?, _ viewTag: Int) {
        
        let tagStr = String(viewTag)
        let firstCh = tagStr[tagStr.startIndex]
        let secondCh = tagStr[tagStr.index(after: tagStr.startIndex)]
        
        if let _sectionInt = Int(String(firstCh)), _sectionInt - 1 == 1 {
            if let _rowInt = Int(String(secondCh)), _rowInt == 0 {
                self.newFirstName = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.namesFieldValueArr[0] = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if let _rowInt = Int(String(secondCh)), _rowInt == 1 {
                self.newLastName = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.namesFieldValueArr[1] = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if let _rowInt = Int(String(secondCh)), _rowInt == 2 {
                self.newNickName = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.namesFieldValueArr[2] = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else if let _sectionInt = Int(String(firstCh)), _sectionInt - 1 == 3 {
            if let _rowInt = Int(String(secondCh)), _rowInt == 0 {
                self.newEmail = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.contactFieldValueArr[0] = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if let _rowInt = Int(String(secondCh)), _rowInt == 1 {
                self.newPhone = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.contactFieldValueArr[1] = newtxValue?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
}

extension PersonalDataTableVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == (kUTTypeImage as String) {
            //  self.pickedLargeImg = info[UIImagePickerControllerEditedImage] as! UIImage?
            self.pickedLargeImg = info[UIImagePickerControllerOriginalImage] as? UIImage
            if let _pickedLargeImg = self.pickedLargeImg {
                if let compressedImg = HelpFunctions.compressAndResizeImage(imageIn: _pickedLargeImg, maxWidth: 500, maxHeight: 500, compressionQuality: 0.8) {
                    self.imgData = UIImageJPEGRepresentation(compressedImg, 1.0)
                } else {
                    self.imgData = UIImageJPEGRepresentation(_pickedLargeImg, 0.5)
                }
            } else {
                self.presentAlert(aTitle: nil, withMsg: errMsgUnknow, confirmTitle: okStr)
            }
            self.newPhoto = self.imgData
        } else if mediaType == (kUTTypeMovie as String) {
            self.presentAlert(aTitle: nil, withMsg: errMsgVideoNotSupportStr, confirmTitle: okStr)
        }
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            picker.dismiss(animated: true, completion: nil)
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            picker.dismiss(animated: true, completion: nil)
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.title = photoAlbumsStr
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        
    }
}


 
