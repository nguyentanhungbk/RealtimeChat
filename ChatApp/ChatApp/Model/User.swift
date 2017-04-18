//
//  User.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var photoURL: String?
    
    init(data: [String: AnyObject]) {
        self.name = data["name"] as? String
        self.email = data["email"] as? String
        self.photoURL = data["photoURL"] as? String
    }
}
