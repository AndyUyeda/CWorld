//
//  ChatItemsController.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-06-19.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

class ChatItemsController {

    var totalMessages = [ChatItemProtocol]()
    var items = [ChatItemProtocol]()
    
    func loadIntoItemsArray() {
        
        self.items = totalMessages
    }
    
    
    func insertItem(message: ChatItemProtocol) {
        self.items.append(message)
    }

}
