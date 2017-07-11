//
//  Me.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-07-11.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import Foundation
import FirebaseAuth




class Me {


    static var uid: String {
        return Auth.auth().currentUser!.uid
    }
    
}
