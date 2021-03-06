//
//  PhotoModel.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-06-29.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions



class PhotoModel: PhotoMessageModel<MessageModel> {


    static let chatItemType = "photo"
    
    override init(messageModel: MessageModel, imageSize: CGSize, image: UIImage) {
        super.init(messageModel: messageModel, imageSize: imageSize, image: image)
    }
    
    
    
    var status: MessageStatus {
        
        get {
            return self._messageModel.status
        } set {
            self._messageModel.status = newValue
        }
    }


}
