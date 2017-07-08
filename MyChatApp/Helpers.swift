//
//  Helpers.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-07-06.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import Foundation
import UIKit



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
