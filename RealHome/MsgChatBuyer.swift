//
//  MsgChatBuyer.swift
//  RealHome
//
//  Created by boqian cheng on 2017-12-22.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import JSQMessagesViewController
import CoreData
import MobileCoreServices
import SwiftGifOrigin

class MsgChatBuyer: JSQMessagesViewController { // UIGestureRecognizerDelegate
    
    public var agentGroupID: String?
    public var nickNameIn: String?
    
    var firstAgentEmail: String?
    
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: fireBaseStoreURL)
    private let imageURLNotSetKey = "NOTSET"
    
    var agentGroupRef: DatabaseReference?
    var messagesGroupRef: DatabaseReference?
    
    var agentsArr: [[String:String]] = []
    var agentsArrRef: DatabaseReference?
    var agentsArrHandle: DatabaseHandle?
    
    var msgFirstAgentRef: DatabaseReference?
    var msgMyRef: DatabaseReference?
    var msgMyRefHandle: DatabaseHandle?
    
  //  var newMsgRef: DatabaseReference?
    
    var msgsJSQ = [JSQMessage]()
    
    var updatedMessageRefHandle: DatabaseHandle?
    
    var photoAlbum: UIImagePickerController?
    var camera: UIImagePickerController?
    
    var pickedLargeImg: UIImage?
    var imgData: Data?
    
    var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.nickNameIn

        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
     //   self.showLoadEarlierMessagesHeader = true
     //   self.topContentAdditionalInset = 0
        
      //  self.agentGroupID = CoreDataController.fetchAgentGroups()[0].value(forKeyPath: "groupID") as? String
        
        let emailH = UserDefaults.standard.object(forKey: uEmail) as? String
        self.senderId = emailH ?? ""
        let nickNameH = UserDefaults.standard.object(forKey: uNickName) as? String
        self.senderDisplayName = nickNameH ?? ""
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        if let _agentGroupID = self.agentGroupID {
            agentGroupRef = FirebaseNodesCreation.getAgentGroup(agentGroupID: _agentGroupID)
            if let _agentGroupRef = agentGroupRef {
                agentsArrRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "agents")
                messagesGroupRef = FirebaseNodesCreation.getSubNode(parentNode: _agentGroupRef, node: "messages")
                self.getAgentsFIR()
            }
        }
        
      //  let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MsgChatBuyer.handleCollectionTapRecognizer(recognizer:)))
     //   self.collectionView.addGestureRecognizer(tapRecognizer)
     //   self.view.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func getAgentsFIR() {
        let agentsArrQuery = agentsArrRef?.queryLimited(toLast: 200)
        // We can use the observe method to listen for all
        // posts from the Firebase DB with ".value"
        agentsArrHandle = agentsArrQuery?.observe(.value, with: { [unowned self] (snapshot) -> Void in
            
            self.agentsArr.removeAll()
            
            for itemSnap in snapshot.children {
                if let _itemSnap = itemSnap as? DataSnapshot {
                    let agentData = _itemSnap.value as? [String : String] ?? [:]
                    if let emailH = agentData["email"] {
                        let nameH = agentData["name"] ?? ""
                        let nicknameH = agentData["nickname"] ?? ""
                        let photoH = agentData["photo"] ?? ""
                        
                        let theAgent = ["email": emailH, "name": nameH, "nickname": nicknameH, "photo": photoH]
                        self.agentsArr.append(theAgent)
                    } else {
                        print("Error! Could not decode agent data in buyer msg")
                    }
                }
            }
            
            if let _messagesGroupRef = self.messagesGroupRef, self.agentsArr.count > 0 {
                self.firstAgentEmail = self.agentsArr[0]["email"]
                let firstAgentE = self.firstAgentEmail ?? ""
                let emailCodedFirstAgent = FirebaseNodesCreation.decodeEmail(email: firstAgentE)
                self.msgFirstAgentRef = FirebaseNodesCreation.getSubNode(parentNode: _messagesGroupRef, node: emailCodedFirstAgent)
                if let _msgFirstAgentRef = self.msgFirstAgentRef {
                    let emailCodedMy = FirebaseNodesCreation.decodeEmail(email: self.senderId)
                    self.msgMyRef = FirebaseNodesCreation.getSubNode(parentNode: _msgFirstAgentRef, node: emailCodedMy)
                    if self.msgMyRef != nil {
                        self.observeMessages()
                    }
                }
            }
        })
    }
    
    func handleCollectionTapRecognizer(recognizer: UITapGestureRecognizer) {
        if(recognizer.state == .ended) {
            if (self.inputToolbar.contentView.textView.isFirstResponder) {
                self.inputToolbar.contentView.textView.resignFirstResponder()
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        self.keyboardController.endListeningForKeyboard()
        if (self.inputToolbar.contentView.textView.isFirstResponder) {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.keyboardController.beginListeningForKeyboard()
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.keyboardController.beginListeningForKeyboard()
    }
    
/*
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
*/
    private func observeMessages() {
        let messageQuery = msgMyRef?.queryLimited(toLast: 1000)
        
     //   msgMyMsgRef?.queryOrdered(byChild: "sender").queryLimited(toLast: 25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        msgMyRefHandle = messageQuery?.observe(.childAdded, with: { [unowned self] (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as? [String : String] ?? [:]
         // senderID is email
            if let id = messageData["senderID"],
               let name = messageData["senderName"],
               let text = messageData["text"], text.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                // 5
                self.finishReceivingMessage()
            } else if let id = messageData["senderID"],
                      let photoURL = messageData["photoURL"],
                      let name = messageData["senderName"] {
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    
                    self.addPhotoMessage(withId: id, name: name, key: snapshot.key, mediaItem: mediaItem)
                    
                    if (photoURL.hasPrefix("gs://") || photoURL.hasPrefix("http://") || photoURL.hasPrefix("https://")) {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: snapshot.key)
                    }
                 //   }  else if let URL = URL(string: photoURL), let data = try? Data(contentsOf: URL) {
                 //       mediaItem.image = UIImage.init(data: data)
                 //       self.collectionView.reloadData()
                 //   }
                }
            } else {
                print("Error! Could not decode message data in buyer")
            }
        })
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = msgMyRef!.observe(.childChanged, with: { [unowned self] (snapshot) in
            let key = snapshot.key
          //  let messageData = snapshot.value as! Dictionary<String, String>
            let messageData = snapshot.value as? [String : String] ?? [:]
            
            if let photoURL = messageData["photoURL"] {
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] {
                    if (photoURL.hasPrefix("gs://") || photoURL.hasPrefix("http://") || photoURL.hasPrefix("https://")) {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                    }
                }
            }
        })
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            msgsJSQ.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, name: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: name, media: mediaItem) {
            msgsJSQ.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        // 2
        storageRef.getData(maxSize: INT64_MAX, completion: { [unowned self] (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            // 3
            storageRef.getMetadata(completion: { [unowned self] (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                // 4
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gif(data: data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return msgsJSQ.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return msgsJSQ[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = msgsJSQ[indexPath.item] // 1
     // senderID is email
        if message.senderId == senderId { // 2
            return outgoingBubble
        } else { // 3
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
     // senderID is email
        return msgsJSQ[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: msgsJSQ[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
     // senderID is email
        return msgsJSQ[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = msgsJSQ[indexPath.item]
     // senderID is email
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        if (self.inputToolbar.contentView.textView.isFirstResponder) {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
        
        let msgH = msgsJSQ[indexPath.item]
        if msgH.isMediaMessage {
            let mediaH = msgH.media
            if mediaH is JSQPhotoMediaItem {
                let photoH = mediaH as? JSQPhotoMediaItem
                if let imgH = photoH?.image {
                    let imageV = UIImageView(image: imgH)
                    imageV.frame = self.view.frame
                    imageV.backgroundColor = UIColor.lightGray
                    imageV.contentMode = .scaleAspectFit
                    imageV.isUserInteractionEnabled = true
                    
                    let tapH = UITapGestureRecognizer(target: self, action: #selector(MsgChatBuyer.dismissFullImage(recognizer:)))
                    imageV.addGestureRecognizer(tapH)
                    
                    self.view.addSubview(imageV)
                }
            }
        }
    }
    
    func dismissFullImage(recognizer: UITapGestureRecognizer) {
        recognizer.view?.removeFromSuperview()
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        let emailCodedMy = FirebaseNodesCreation.decodeEmail(email: self.senderId)
        let firstAgentE = self.firstAgentEmail ?? ""
        let emailCodedFirstAgent = FirebaseNodesCreation.decodeEmail(email: firstAgentE)
        let refPath: String = self.agentGroupID! + "/" + "messages" + "/" + emailCodedFirstAgent + "/" + emailCodedMy
        
        let msgRefHH = FirebaseNodesCreation.getFirDBInstance().reference(withPath: refPath)
        
        
        let newMsgRef = msgRefHH.childByAutoId()
        
        let nowStamp = Date().description
    // senderID is email
        let message = ["senderID": senderId,
                       "senderName": senderDisplayName,
                       "text": text,
                       "timeStamp": nowStamp]
        
        newMsgRef.setValue(message)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        choosePhoto()
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
            popPresenter!.sourceRect = self.view.bounds
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendPhotoMessage() -> String? {
        
        let emailCodedMy = FirebaseNodesCreation.decodeEmail(email: self.senderId)
        let firstAgentE = self.firstAgentEmail ?? ""
        let emailCodedFirstAgent = FirebaseNodesCreation.decodeEmail(email: firstAgentE)
        let refPath: String = self.agentGroupID! + "/" + "messages" + "/" + emailCodedFirstAgent + "/" + emailCodedMy
        
        let msgRefHH = FirebaseNodesCreation.getFirDBInstance().reference(withPath: refPath)
        
        let itemImgRef = msgRefHH.childByAutoId()
        let nowStamp = Date().description
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderID": senderId,
            "senderName": senderDisplayName,
            "timeStamp": nowStamp]
        
        itemImgRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemImgRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemImgRef = msgMyRef!.child(key)
        itemImgRef.updateChildValues(["photoURL": url])
    }
    
    fileprivate func presentAlert(aTitle: String?, withMsg: String?, confirmTitle: String?) {
        
        let alert = UIAlertController(title: aTitle, message: withMsg, preferredStyle: .alert)
        let enterPWAct = UIAlertAction(title: confirmTitle, style: .default, handler: nil)
        alert.addAction(enterPWAct)
        self.present(alert, animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        if let refHandle = agentsArrHandle {
            agentsArrRef?.removeObserver(withHandle: refHandle)
        }
        if let refHandle = msgMyRefHandle {
            msgMyRef?.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            msgMyRef?.removeObserver(withHandle: refHandle)
        }
    }
}

extension MsgChatBuyer: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == (kUTTypeImage as String) {
  //  self.pickedLargeImg = info[UIImagePickerControllerEditedImage] as! UIImage?
            self.pickedLargeImg = info[UIImagePickerControllerOriginalImage] as? UIImage
  // if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL
            if let _pickedLargeImg = self.pickedLargeImg {
                if let compressedImg = HelpFunctions.compressAndResizeImage(imageIn: _pickedLargeImg, maxWidth: 500, maxHeight: 400, compressionQuality: 0.8) {
                    self.imgData = UIImageJPEGRepresentation(compressedImg, 1.0)
                    if let key = sendPhotoMessage() {
                            // 5
                        let path = "\(key)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                            // 6
                        self.storageRef.child(path).putData(self.imgData!, metadata: metadata, completion: { [unowned self] (metadata, error) in
                            if let error = error {
                                print("Error upload photo buyer: \(error.localizedDescription)")
                                return
                            }
                            self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                        })
                    }
                } else {
                    self.imgData = UIImageJPEGRepresentation(_pickedLargeImg, 0.7)
                    if let key = sendPhotoMessage() {
                        // 5
                        let path = "\(key)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        // 6
                        self.storageRef.child(path).putData(self.imgData!, metadata: metadata, completion: { [unowned self] (metadata, error) in
                            if let error = error {
                                print("Error uploading photo: \(error.localizedDescription)")
                                return
                            }
                            self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                        })
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
