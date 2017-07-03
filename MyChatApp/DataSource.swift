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
    
    var delegate: ChatDataSourceDelegateProtocol?
    
    var controller = ChatItemsController()
    
    init(totalMessages: [ChatItemProtocol]) {
        controller.totalMessages = totalMessages
        controller.loadIntoItemsArray()
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
        
    }
    
    func addMessage(message: ChatItemProtocol) {
        self.controller.insertItem(message: message)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        completion(false)
    }



}
