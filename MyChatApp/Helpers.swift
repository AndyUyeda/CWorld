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
        for message in messages {
        
            let senderId = message["senderId"].stringValue
            let model = MessageModel(uid: message["uid"].stringValue, senderId: senderId, type: message["type"].stringValue, isIncoming: senderId == Me.uid ? false : true, date: Date(timeIntervalSinceReferenceDate: message["date"].doubleValue), status: message["status"] == "success" ? MessageStatus.success : MessageStatus.sending)
            let textMessage = TextModel(messageModel: model, text: message["text"].stringValue)
            convertedMessages.append(textMessage)
        }
    return convertedMessages
    }



}
