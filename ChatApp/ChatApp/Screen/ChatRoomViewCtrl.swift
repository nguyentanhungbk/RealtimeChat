//
//  ChatRoomViewCtrl.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatRoomViewCtrl: UIViewController {

    @IBOutlet weak var tbvMain: UITableView!
    
    var chatRooms = [ChatGroup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchAllChatRoom()
    }
    
    private func fetchAllChatRoom(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        let userChatRoomsRef = FIRDatabase.database().reference().child("user-chat-groups").child(uid!)
        userChatRoomsRef.observe(.childAdded, with: { (snapShoot) in
            let groupRef = FIRDatabase.database().reference().child("chat-groups").child(snapShoot.key)
            groupRef.observe(.value, with: { (snapShoot) in
                if let groupDic = snapShoot.value as? [String: AnyObject] {
                    if self.isGroupExist(groupId: snapShoot.key) {
                        let group = self.chatRooms.filter({ (chatGroup) -> Bool in
                            return chatGroup.id! == snapShoot.key
                        }).first
                        group!.updateData(data: groupDic)
                    }
                    else{
                        let group = ChatGroup(data: groupDic)
                        group.id = snapShoot.key
                        self.chatRooms.append(group)
                    }
                    self.tbvMain.reloadData()
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }

    private func isGroupExist(groupId: String) -> Bool {
        return chatRooms.filter({ (group) -> Bool in
            return group.id! == groupId
        }).count >= 1
    }
    
}

extension ChatRoomViewCtrl: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let roomCell = tableView.dequeueReusableCell(withIdentifier: "ROOM_CELL") as! ChatRoomCell
        let room = chatRooms[indexPath.row]
        roomCell.updateCellWithRoom(room: room)
        return roomCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = chatRooms[indexPath.row]
        let chatVC = ChatViewCtrl()
        chatVC.chatGroupKey = room.id
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
