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

class ChatLogController: BaseChatViewController {

    var presenter: BasicChatInputBarPresenter!
    var decorator = Decorator()
    var dataSource = DataSource()
    
    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {
        
        let textMessageBuilder = TextMessagePresenterBuilder(viewModelBuilder: TextBuilder(), interactionHandler: TextHandler())
        
        
        return [TextModel.chatItemType : [textMessageBuilder]]
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
        item.textInputHandler = { text in
        
        let date = Date()
        let double = date.timeIntervalSinceReferenceDate
        let senderId = "me"
        
            let message = MessageModel(uid: "\(senderId, double)", senderId: senderId, type: TextModel.chatItemType, isIncoming: false, date: date, status: .success)
            let textMessage = TextModel(messageModel: message, text: text)
            self.dataSource.addMessage(message: textMessage)
        
        }
    return item
    }
    
    func handlePhoto() -> PhotosChatInputItem {
    let item = PhotosChatInputItem(presentingController: self)
        item.photoInputHandler = { photo in
         
            let date = Date()
            let double = date.timeIntervalSinceReferenceDate
            let senderId = "me"
            
            let message = MessageModel(uid: "\(senderId, double)", senderId: senderId, type: "", isIncoming: false, date: date, status: .success)
            let photoMessage = PhotoModel(messageModel: message, imageSize: photo.size, image: photo)
            self.dataSource.addMessage(message: photoMessage)

        }
        
        return item
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatDataSource = self.dataSource
        self.chatItemsDecorator = self.decorator
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

