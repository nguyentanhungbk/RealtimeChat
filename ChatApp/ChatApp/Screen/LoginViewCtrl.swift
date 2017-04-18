//
//  LoginViewCtrl.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewCtrl: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onLoginAction(sender: UIButton){
        guard let email = tfEmail.text, let pwd = tfPass.text else {
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
            if error == nil {
                let currentUserRef = FIRDatabase.database().reference().child("users").child((user?.uid)!)
                currentUserRef.observeSingleEvent(of: .value, with: { (snapshoot) in
                    debugPrint(snapshoot)
                    if let dic = snapshoot.value as? [String:AnyObject] {
                        let user = User(data: dic)
                        user.id = snapshoot.key
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.currentUser = user
                        
                        // move to chat room
                        let chatRoomVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewCtrl") as! ChatRoomViewCtrl
                        self.navigationController?.pushViewController(chatRoomVC, animated: true)
                    }
                })
            }
        })
    }

}
