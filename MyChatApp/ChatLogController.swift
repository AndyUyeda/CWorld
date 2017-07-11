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
class ChatLogController: BaseChatViewController {

    var presenter: BasicChatInputBarPresenter!
    var decorator = Decorator()
    var dataSource: DataSource!
    var userUID = String()

    
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
        let senderId = Auth.auth().currentUser!.uid
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
    }

    
    func sendOnlineTextMessage(text: String, uid: String, double: Double, senderId: String) {
        let message = ["text": text, "uid": uid, "date": double, "senderId": senderId, "status": "success"] as [String : Any]
        let childUpdates = ["User-messages/\(senderId)/\(self.userUID)/\(uid)": message,
                            "User-messages/\(self.userUID)/\(senderId)/\(uid)": message
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

