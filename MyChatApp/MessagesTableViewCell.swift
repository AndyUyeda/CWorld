//
//  MessagesTableViewCell.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-07-08.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var teammate: UILabel!
    @IBOutlet weak var otherGuesser: UILabel!
    @IBOutlet weak var describingTeammate: UILabel!
    @IBOutlet weak var otherDescriber: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    @IBOutlet weak var victoryImage: UIImageView!
    @IBOutlet weak var defeatImage: UIImageView!
    var myRole: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
