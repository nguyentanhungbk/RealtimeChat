//
//  UserListViewCtrl.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserListViewCtrl: UIViewController {

    @IBOutlet weak var tbvMain: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserList()
    }

    private func getUserList(){
        let usersRef = FIRDatabase.database().reference().child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapShoot) in
            for userItem in snapShoot.children {
                let userItemSnap = userItem as! FIRDataSnapshot
                if let userDic = userItemSnap.value as? [String:AnyObject] {
                    let user = User(data: userDic)
                    user.id = userItemSnap.key
                    self.users.append(user)
                }
            }
            self.tbvMain.reloadData()
        })
    }
}

extension UserListViewCtrl: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: "USER_CELL") as! UserCell
        let user = users[indexPath.row]
        userCell.updateCellWithUser(user: user)
        return userCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewCtrl") as! ChatViewCtrl
        chatVC.partnerUser = user
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
