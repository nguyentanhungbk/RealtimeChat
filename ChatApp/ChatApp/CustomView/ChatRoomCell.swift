//
//  ChatRoomCell.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit

class ChatRoomCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAvatar.layer.masksToBounds = true
        imgAvatar.layer.cornerRadius = 30
    }
    
    func updateCellWithRoom(room: ChatGroup) {
        imgAvatar.kf.setImage(with: URL(string: room.photoURL!)!)
        //lblName.text = user.name
        lblLastMessage.text = room.lastMessage
    }

}
