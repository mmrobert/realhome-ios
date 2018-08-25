//
//  AddServiceVCAgent.swift
//  RealHome
//
//  Created by boqian cheng on 2018-01-07.
//  Copyright © 2018 boqiancheng. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices
import Firebase

class AddServiceVCAgent: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var expertiseLabel: UILabel!
    @IBOutlet weak var expertiseTxt: UITextView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cancelBtnItem: UIBarButtonItem!
    @IBOutlet weak var addBtnItem: UIBarButtonItem!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    var photoAlbum: UIImagePickerController?
    var camera: UIImagePickerController?
    
    var pickedLargeImg: UIImage?
    var imgData: Data?
    
    var myServiceRef: DatabaseReference?
    
    var agentGroupID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = LanguageGeneral.addAServiceStr
        
        self.expertiseTxt.layer.cornerRadius = 8
        self.expertiseTxt.layer.borderColor = (UIColor.lightGray.withAlphaComponent(0.7)).cgColor
        self.expertiseTxt.layer.borderWidth = 0.6
        self.expertiseTxt.layer.masksToBounds = true
        
        self.imageView.layer.cornerRadius = 10
        self.imageView.layer.masksToBounds = true
        
        let imgChangeTap = UITapGestureRecognizer(target: self, action: #selector(AddServiceVCAgent.imgTapped(regognizer:)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(imgChangeTap)
        
        self.localizedView()
        self.setCancelAddAction()
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(AddServiceVCAgent.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
        dismiss.cancelsTouchesInView = false
        
        noteCenter.addObserver(self, selector: #selector(AddServiceVCAgent.newLanguageChoosed(note:)), name: NSNotification.Name(rawValue: "LanguageChosed"), object: nil)
        
        noteCenter.addObserver(self, selector: #selector(AddServiceVCAgent.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        noteCenter.addObserver(self, selector: #selector(AddServiceVCAgent.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.agentGroupID = CoreDataController.fetchAgentGroups()[0].value(forKeyPath: "groupID") as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func newLanguageChoosed(note: NSNotification) {
        
        self.title = LanguageGeneral.addAServiceStr
        self.localizedView()
    }
    
    @objc fileprivate func dismissKeyboard() {
        //  self.view.endEditing(true)
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @objc fileprivate func imgTapped(regognizer: UITapGestureRecognizer) {
        self.dismissKeyboard()
        self.choosePhoto()
    }
    
    // pragma mark - Keyboard notifications
    
    @objc fileprivate func keyboardWillShow(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let offset = keyboardSize.size.height
                //- (self.tabBarController?.tabBar.frame.size.height)!
                self.animateOnKeyboardEvent(notification: notification, withOffset: offset)
            }
        }
        //  self.scrollToCursorForInputView(inputView: self.currentInputView!)
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification){
        self.animateOnKeyboardEvent(notification: notification, withOffset: 0.0)
    }
    
    fileprivate func animateOnKeyboardEvent(notification: NSNotification, withOffset offset: CGFloat) {
        let userInfo = notification.userInfo!
        let duration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! Int
        let options: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: UInt(curve << 16) | UIViewAnimationOptions.beginFromCurrentState.rawValue)
        
        self.view.layoutIfNeeded()
        self.scrollViewBottom.constant = offset
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
         //   self?.scrollViewBottom.constant = offset
            self?.view.layoutIfNeeded() ?? ()
            // var currentOffset = self.tableView.contentOffset
            // currentOffset.y = currentOffset.y - 100
            // self.tableView.setContentOffset(currentOffset, animated: false)
        }, completion: nil)
    }
    
    fileprivate func localizedView() {

        self.nameLabel.text = LanguageGeneral.nameStr
        self.expertiseLabel.text = LanguageGeneral.expertiseStr
        self.phoneLabel.text = LanguageGeneral.phoneStr
        self.imageLabel.text = LanguageGeneral.imageStr
        
        self.cancelBtnItem.title = LanguageGeneral.cancelStr
        self.addBtnItem.title = LanguageGeneral.addStr
        
       // self.addBtn.setTitle(LanguageGeneral.addStr, for: .normal)
    }
    
    fileprivate func setCancelAddAction() {
        
        self.cancelBtnItem.target = self
        self.cancelBtnItem.action = #selector(AddServiceVCAgent.cancelTapped(_:))
            
        self.addBtnItem.target = self
        self.addBtnItem.action = #selector(AddServiceVCAgent.addTapped(_:))
     //   self.addBtn.addTarget(self, action: #selector(AddServiceVCAgent.addTapped(_:)), for: .touchUpInside)
    }
    
    @objc fileprivate func cancelTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func addTapped(_ sender: UIBarButtonItem) {
        self.dismissKeyboard()
        let nameStr = self.nameTxt.text ?? ""
        let introStr = self.expertiseTxt.text ?? ""
        let phoneStr = self.phoneTxt.text ?? ""
        if nameStr.count > 0 && introStr.count > 0 && phoneStr.count > 0 {
            self.createService()
          //  self.navigationController?.popViewController(animated: true)
        } else {
            self.presentAlert(aTitle: LanguageGeneral.errMsgNeedAllFieldsStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr)
        }
    }
    
    func createService() {
        
        let aaEmail = UserDefaults.standard.object(forKey: uEmail) as? String
        let aaNickName = UserDefaults.standard.object(forKey: uNickName) as? String
        let aaE = aaEmail ?? ""
        let aaN = aaNickName ?? ""
        
        let emailCode = FirebaseNodesCreation.decodeEmail(email: aaE)
        let refPath: String = self.agentGroupID! + "/" + "services" + "/" + emailCode
        
        myServiceRef = FirebaseNodesCreation.getFirDBInstance().reference(withPath: refPath)
        
        if let newServiceRef = myServiceRef?.childByAutoId() {
            
            let nowStamp = Date().description
            
            var imgStr: String
            if let _imgData = self.imgData {
                imgStr = HelpFunctions.photoToStringBase64(imgData: _imgData)
            } else {
                imgStr = ""
            }
            
            let nameStr = self.nameTxt.text ?? ""
            let introStr = self.expertiseTxt.text ?? ""
            let phoneStr = self.phoneTxt.text ?? ""
            let serviceH = ["byEmail": aaE,
                            "byName": aaN,
                            "name": nameStr,
                            "introduction": introStr,
                            "phone": phoneStr,
                            "photo": imgStr,
                            "timeStamp": nowStamp]
            
            newServiceRef.setValue(serviceH)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.presentAlert(aTitle: LanguageGeneral.errMsgTryAgainStr, withMsg: nil, confirmTitle: LanguageGeneral.okStr)
        }
    }
    
    func choosePhoto() {
        
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
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let albumAct = UIAlertAction(title: LanguageGeneral.chooseFromAlbumStr, style: .default, handler: handlerAlbums)
        let cameraAct = UIAlertAction(title: LanguageGeneral.takePhotoStr, style: .default, handler: handlerCamera)
        let cancelAct = UIAlertAction(title: LanguageGeneral.cancelStr, style: .cancel, handler: nil)
        alert.addAction(albumAct)
        alert.addAction(cameraAct)
        alert.addAction(cancelAct)
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) {
            self.present(alert, animated: true, completion: nil)
        } else {
            alert.modalPresentationStyle = UIModalPresentationStyle.popover
            let popPresenter = alert.popoverPresentationController
            popPresenter!.permittedArrowDirections = UIPopoverArrowDirection.any
            popPresenter!.sourceView = self.view
            popPresenter!.sourceRect = CGRect(x: 10, y: 10, width: 10, height: 10)
            
            self.present(alert, animated: true, completion: nil)
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
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
        self.present(alert, animated: true, completion: nil)
        
    }

    deinit {
        noteCenter.removeObserver(self)
    }
}

extension AddServiceVCAgent: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == (kUTTypeImage as String) {
            //  self.pickedLargeImg = info[UIImagePickerControllerEditedImage] as! UIImage?
            self.pickedLargeImg = info[UIImagePickerControllerOriginalImage] as? UIImage
            // if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL
            if let _pickedLargeImg = self.pickedLargeImg {
                if let compressedImg = HelpFunctions.compressAndResizeImage(imageIn: _pickedLargeImg, maxWidth: 300, maxHeight: 300, compressionQuality: 0.8) {
                    self.imgData = UIImageJPEGRepresentation(compressedImg, 1.0)
                    if let _imgData = self.imgData {
                        self.imageView.image = UIImage(data: _imgData)
                    }
                } else {
                    self.imgData = UIImageJPEGRepresentation(_pickedLargeImg, 0.7)
                    if let _imgData = self.imgData {
                        self.imageView.image = UIImage(data: _imgData)
                    }
                }
            } else {
                self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgUnknow, confirmTitle: LanguageGeneral.okStr)
            }
        } else if mediaType == (kUTTypeMovie as String) {
            self.presentAlert(aTitle: nil, withMsg: LanguageGeneral.errMsgVideoNotSupportStr, confirmTitle: LanguageGeneral.okStr)
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
        viewController.navigationItem.title = LanguageGeneral.photoAlbumsStr
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        
    }
}

