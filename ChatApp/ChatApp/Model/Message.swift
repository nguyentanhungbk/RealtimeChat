//
//  Message.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit

class Message: NSObject {
    var fromId: String?
    var toId: String?
    var message: String?
    var time: String?
    
    init(data: [String:AnyObject]) {
        fromId = data["fromId"] as? String
        toId = data["toId"] as? String
        message = data["message"] as? String
        time = data["time"] as? String
    }
}
