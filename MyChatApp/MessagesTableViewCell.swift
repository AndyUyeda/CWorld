//
//  MessagesTableViewCell.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-07-08.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var newMessage: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
