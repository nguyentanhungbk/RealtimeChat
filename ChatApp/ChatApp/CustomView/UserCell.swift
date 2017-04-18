//
//  UserCell.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit
import Kingfisher

class UserCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAvatar.layer.masksToBounds = true
        imgAvatar.layer.cornerRadius = 30
    }

    func updateCellWithUser(user: User) {
        imgAvatar.kf.setImage(with: URL(string: user.photoURL!)!)
        lblName.text = user.name
        lblEmail.text = user.email
    }

}
