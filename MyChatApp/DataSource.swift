//
//  DataSource.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-06-19.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions


class DataSource: ChatDataSourceProtocol {
    
    weak var delegate: ChatDataSourceDelegateProtocol?
    
    var controller = ChatItemsController()
    
    init(initialMessages: [ChatItemProtocol]) {
        self.controller.totalMessages = initialMessages
        self.controller.loadIntoItemsArray(messagedNeeded: min(initialMessages.count, 50))
    }
    
    var chatItems: [ChatItemProtocol] {
        return controller.items
    }
    
    var hasMoreNext: Bool {
    
        return false
    }
    
    var hasMorePrevious: Bool {
        return false
    }
    
    func loadNext() {
        
    }
    
    func loadPrevious() {
        controller.loadPrevious()
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }
    
    func addMessage(message: ChatItemProtocol) {
        self.controller.insertItem(message: message)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    func updateTextMessage(uid: String, status: MessageStatus) {
        if let index = self.controller.items.index(where: { (message) -> Bool in
            return message.uid == uid
        }) {
        let message = self.controller.items[index] as! TextModel
        message.status = status
        self.delegate?.chatDataSourceDidUpdate(self)
        }
        
    
    
    
    
    }
    
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        
        if focusPosition > 0.9 {
            self.controller.adjustWindow()
            completion(true)
        } else {
            completion(false)
        }
        
    }



}
