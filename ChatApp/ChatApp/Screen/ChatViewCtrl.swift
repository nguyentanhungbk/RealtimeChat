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
import JSQMessagesViewController

class ChatViewCtrl: JSQMessagesViewController {
    
    var partnerUser: User!
    var currentUser: User!
    var chatGroupKey: String?
    
//    var senderAvatar: JSQMessagesAvatarImage?
//    var receiverAvatar: JSQMessagesAvatarImage?
    
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        currentUser = appDelegate.currentUser
        
//        DispatchQueue.global().async { 
//            let senderData = try! Data(contentsOf: URL(string: self.currentUser.photoURL!)!)
//            let receiverData = try! Data(contentsOf: URL(string: self.partnerUser.photoURL!)!)
//            
//            let senderImage = UIImage(data: senderData)
//            let receiverImage = UIImage(data: receiverData)
//            
//            self.senderAvatar = JSQMessagesAvatarImage(avatarImage: senderImage, highlightedImage: senderImage, placeholderImage: senderImage)
//            self.receiverAvatar = JSQMessagesAvatarImage(avatarImage: receiverImage, highlightedImage: receiverImage, placeholderImage: receiverImage)
//        }
        
        self.senderDisplayName = currentUser.name!
        self.senderId = currentUser.id!
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        if let _ = chatGroupKey {
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
                        self.loadUserMessage()
                    }
                })
            })
        }
    }

    private func loadUserMessage(){
        if let groupKey = chatGroupKey {
            let groupMessagesRef = FIRDatabase.database().reference().child("messages").child(groupKey)
            groupMessagesRef.observe(.childAdded, with: { (snapshoot) in
                if let messageDic = snapshoot.value as? [String:AnyObject] {
                    let messageObj = Message(data: messageDic)
                    let message = JSQMessage(senderId: messageObj.fromId, displayName: self.partnerUser.name, text: messageObj.message!)
                    self.messages.append(message!)
                    self.finishReceivingMessage()
                }
            }, withCancel: nil)
        }
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
//        if let _ = self.senderAvatar {
//            let message = messages[indexPath.item] // 1
//            if message.senderId == senderId { // 2
//                return senderAvatar
//            } else { // 3
//                return receiverAvatar
//            }
//        }
//        else{
//            return nil
//        }
        return nil
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
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
            self.loadUserMessage()
        }
        
        let chatMessageGroup = FIRDatabase.database().reference().child("messages").child(chatGroup.key).childByAutoId()
        
        // start update database
        chatGroup.updateChildValues(["lastMessage":text, "photoURL":partnerUser.photoURL!, "time":"\(date.timeIntervalSince1970)"])
        chatMessageGroup.updateChildValues(["fromId":senderId, "toId":partnerUser.id!, "message":text, "time":"\(date.timeIntervalSince1970)"])
    }
}

extension ChatViewCtrl {
}
