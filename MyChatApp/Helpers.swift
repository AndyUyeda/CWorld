//
//  Helpers.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-07-06.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import Foundation
import UIKit
import ChattoAdditions
import Chatto
import SwiftyJSON
import Kingfisher
extension UIViewController {
    
    
    func showingKeyboard(notification: Notification) {
        
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            self.view.frame.origin.y = -keyboardHeight
        }
        
    }
    
    func hidingKeyboard() {
        self.view.frame.origin.y = 0
    }
    
    func alert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

extension NSObject {
    
    
    func convertToChatItemProtocol(messages: [JSON]) -> [ChatItemProtocol] {
        var convertedMessages = [ChatItemProtocol]()
        
        convertedMessages = messages.map({ (message) -> ChatItemProtocol in
            let senderId = message["senderId"].stringValue
            let model = MessageModel(uid: message["uid"].stringValue, senderId: senderId, type: message["type"].stringValue, isIncoming: senderId == Me.uid ? false : true, date: Date(timeIntervalSinceReferenceDate: message["date"].doubleValue), status: message["status"] == "success" ? MessageStatus.success : MessageStatus.sending)
            if message["type"].stringValue == TextModel.chatItemType {
                let textMessage = TextModel(messageModel: model, text: message["text"].stringValue)
                return textMessage
            } else {
                
                let loading = #imageLiteral(resourceName: "loading")
                let photoMessage = PhotoModel(messageModel: model, imageSize: loading.size, image: loading)
                return photoMessage
            }
            
        })
        return convertedMessages
    }
    
    func parseURLs(UID_URL: (key: String, value: String)) {
        let uid = UID_URL.key
        let imageURL = UID_URL.value
        KingfisherManager.shared.retrieveImage(with: URL(string: imageURL)!, options: nil, progressBlock: nil) { (image, _, _, _) in
            if let image = image {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateImage"), object: nil, userInfo: ["image": image, "uid": uid])
            }
        }
    }
    
    
    
    
}




