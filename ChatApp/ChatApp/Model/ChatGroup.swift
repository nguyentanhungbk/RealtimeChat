//
//  ChatGroup.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit

class ChatGroup: NSObject {
    var id: String?
    var lastMessage: String?
    var time: String?
    var photoURL: String?
    
    init(data: [String:AnyObject]) {
        lastMessage = data["lastMessage"] as? String
        time = data["time"] as? String
        photoURL = data["photoURL"] as? String
    }
    
    func updateData(data: [String:AnyObject]) {
        lastMessage = data["lastMessage"] as? String
        time = data["time"] as? String
        photoURL = data["photoURL"] as? String
    }
}
