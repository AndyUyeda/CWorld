//
//  TextModel.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-06-19.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

class TextModel: TextMessageModel<MessageModel> {


    static let chatItemType = "text"
    
    override init(messageModel: MessageModel, text: String) {
        super.init(messageModel: messageModel, text: text)
    }

    
    var status: MessageStatus {
    
        get {
            return self._messageModel.status
        } set {
            self._messageModel.status = newValue
        }
    }
}
