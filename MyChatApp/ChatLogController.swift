//
//  ViewController.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-06-19.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseUI
import SwiftyJSON
class ChatLogController: BaseChatViewController, FUICollectionDelegate {

    var presenter: BasicChatInputBarPresenter!
    var decorator = Decorator()
    var dataSource: DataSource!
    var userUID = String()
    var MessagesArray: FUIArray!

    
    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {
        
        let textMessageBuilder = TextMessagePresenterBuilder(viewModelBuilder: TextBuilder(), interactionHandler: TextHandler())
        let photoPresenterBuilder = PhotoMessagePresenterBuilder(viewModelBuilder: PhotoBuilder(), interactionHandler: PhotoHandler())
        
        
        return [TextModel.chatItemType : [textMessageBuilder],
                PhotoModel.chatItemType: [photoPresenterBuilder]
        ]
    }
    
    override func createChatInputView() -> UIView {
        let inputBar = ChatInputBar.loadNib()
        var appearance = ChatInputBarAppearance()
        appearance.sendButtonAppearance.title = "Send"
        appearance.textInputAppearance.placeholderText = "Type a message"
        self.presenter = BasicChatInputBarPresenter(chatInputBar: inputBar, chatInputItems: [handleSend(), handlePhoto()], chatInputBarAppearance: appearance)
        return inputBar
    }
    
    
    func handleSend() -> TextChatInputItem {
    let item = TextChatInputItem()
        item.textInputHandler = { [weak self] text in

            let date = Date()
        let double = date.timeIntervalSinceReferenceDate
        let senderId = Me.uid
        let messageUID = (senderId + "\(double)").replacingOccurrences(of: ".", with: "")
        
            let message = MessageModel(uid: messageUID, senderId: senderId, type: TextModel.chatItemType, isIncoming: false, date: date, status: .sending)
            let textMessage = TextModel(messageModel: message, text: text)
            self?.dataSource.addMessage(message: textMessage)
            self?.sendOnlineTextMessage(text: text, uid: messageUID, double: double, senderId: senderId)
            
        }
    return item
    }
    
    func handlePhoto() -> PhotosChatInputItem {
    let item = PhotosChatInputItem(presentingController: self)
        item.photoInputHandler = { [weak self] photo in
         
            let date = Date()
            let double = date.timeIntervalSinceReferenceDate
            let senderId = "me"
            
            let message = MessageModel(uid: "\(senderId, double)", senderId: senderId, type: PhotoModel.chatItemType, isIncoming: false, date: date, status: .success)
            let photoMessage = PhotoModel(messageModel: message, imageSize: photo.size, image: photo)
            self?.dataSource.addMessage(message: photoMessage)

        }
        
        return item
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatDataSource = self.dataSource
        self.chatItemsDecorator = self.decorator
        self.constants.preferredMaxMessageCount = 300
        self.MessagesArray.observeQuery()
        self.MessagesArray.delegate = self
    }

    
    func sendOnlineTextMessage(text: String, uid: String, double: Double, senderId: String) {
        let message = ["text": text, "uid": uid, "date": double, "senderId": senderId, "status": "success", "type": TextModel.chatItemType] as [String : Any]
        var friendMessage = message
        friendMessage["new"] = true
        let childUpdates = ["User-messages/\(senderId)/\(self.userUID)/\(uid)": message,
                            "User-messages/\(self.userUID)/\(senderId)/\(uid)": message,
                            "Users/\(Me.uid)/Contacts/\(self.userUID)/lastMessage": message,
                            "Users/\(self.userUID)/Contacts/\(Me.uid)/lastMessage": friendMessage,
                            ]
        
        Database.database().reference().updateChildValues(childUpdates) { (error, _) in
            
            if error != nil {
            
                self.dataSource.updateTextMessage(uid: uid, status: .failed)
                return
            }
            self.dataSource.updateTextMessage(uid: uid, status: .success)
            
        }
    
    }
 
    deinit {
    
        print("deinit")
    }


}

extension ChatLogController {

    func array(_ array: FUICollection, didAdd object: Any, at index: UInt) {
        let message = JSON((object as! DataSnapshot).value as Any)
        let senderId = message["senderId"].stringValue

        if senderId == self.userUID {
        
        Database.database().reference().child("Users").child(Me.uid).child("Contacts").child(self.userUID).child("lastMessage").updateChildValues(["new":false])
        }
        let contains = self.dataSource.controller.items.contains { (collectionViewMessage) -> Bool in
            return collectionViewMessage.uid == message["uid"].stringValue
        }
        
        if contains == false {
            let model = MessageModel(uid: message["uid"].stringValue, senderId: senderId, type: message["type"].stringValue, isIncoming: senderId == Me.uid ? false : true, date: Date(timeIntervalSinceReferenceDate: message["date"].doubleValue), status: message["status"] == "success" ? MessageStatus.success : MessageStatus.sending)
            let textMessage = TextModel(messageModel: model, text: message["text"].stringValue)
            self.dataSource.addMessage(message: textMessage)

        }
        
        
    }


}

