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


    override init(messageModel: MessageModel, text: String) {
        super.init(messageModel: messageModel, text: text)
    }

}
