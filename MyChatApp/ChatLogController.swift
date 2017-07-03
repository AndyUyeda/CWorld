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
    var dataSource: DataSource!
    var totalMessages = [ChatItemProtocol]()

    
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
            
            let message = MessageModel(uid: "\(senderId, double)", senderId: senderId, type: PhotoModel.chatItemType, isIncoming: false, date: date, status: .success)
            let photoMessage = PhotoModel(messageModel: message, imageSize: photo.size, image: photo)
            self.dataSource.addMessage(message: photoMessage)

        }
        
        return item
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...295 {
            totalMessages.append(TextModel(messageModel: MessageModel(uid: "\(i)", senderId: "\(i)", type: TextModel.chatItemType, isIncoming: false, date: Date(), status: .success), text: "\(i)"))
        }

        self.dataSource = DataSource(totalMessages: totalMessages)
        self.chatDataSource = self.dataSource
        self.chatItemsDecorator = self.decorator
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

