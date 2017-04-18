//
//  ChatViewCtrl.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatViewCtrl: UIViewController {

    @IBOutlet weak var tfChatMessage: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    var partnerUser: User!
    var currentUser: User!
    var chatGroupKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        currentUser = appDelegate.currentUser
        
        if let _ = chatGroupKey {
            btnSend.isUserInteractionEnabled = false
            let currentUid = FIRAuth.auth()?.currentUser?.uid
            var partnerUid: String = ""
            let membersRef = FIRDatabase.database().reference().child("members").child(chatGroupKey!)
            membersRef.observeSingleEvent(of: .value, with: { (snapshoot) in
                for userUid in snapshoot.children {
                    let user = userUid as! FIRDataSnapshot
                    let userUid = user.value as! String
                    if userUid != currentUid! {
                        partnerUid = user.value as! String
                        break
                    }
                }
                let userRef = FIRDatabase.database().reference().child("users").child(partnerUid)
                userRef.observeSingleEvent(of: .value, with: { (snapshoot) in
                    if let dic = snapshoot.value as? [String:AnyObject] {
                        self.partnerUser = User(data: dic)
                        self.partnerUser.id = snapshoot.key
                        self.btnSend.isUserInteractionEnabled = true
                    }
                })
            })
        }
    }

    @IBAction func sendMessage(){
        var chatGroup: FIRDatabaseReference
        if let key = chatGroupKey {
            chatGroup = FIRDatabase.database().reference().child("chat-groups").child(key)
        }
        else{
            chatGroup = FIRDatabase.database().reference().child("chat-groups").childByAutoId()
            chatGroupKey = chatGroup.key
            let currentUserChatGroup = FIRDatabase.database().reference().child("user-chat-groups").child((FIRAuth.auth()?.currentUser?.uid)!).child(chatGroup.key)
            let partnerUserChatGroup = FIRDatabase.database().reference().child("user-chat-groups").child(partnerUser.id!).child(chatGroup.key)
            let memberGroupRef = FIRDatabase.database().reference().child("members").child(chatGroup.key)
            
            currentUserChatGroup.updateChildValues(["data":1])
            partnerUserChatGroup.updateChildValues(["data":1])
            memberGroupRef.setValue([(FIRAuth.auth()?.currentUser?.uid)!, partnerUser.id!])
        }
        
        let chatMessageGroup = FIRDatabase.database().reference().child("messages").child(chatGroup.key).childByAutoId()
        
        // start update database
        chatGroup.updateChildValues(["lastMessage":tfChatMessage.text!, "photoURL":partnerUser.photoURL!, "time":"\(Date().timeIntervalSince1970)"])
        chatMessageGroup.updateChildValues(["fromId":(FIRAuth.auth()?.currentUser?.uid)!, "toId":partnerUser.id!, "message":tfChatMessage.text!, "time":"\(Date().timeIntervalSince1970)"])
    }

}
