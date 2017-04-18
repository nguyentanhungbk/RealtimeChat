//
//  RegisterViewCtrl.swift
//  ChatApp
//
//  Created by Robert Nguyen on 4/18/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class RegisterViewCtrl: UIViewController {

    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPass: UITextField!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    var avatar: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func chooseAvatar(){
        let imagePickerCtrl = UIImagePickerController()
        imagePickerCtrl.delegate = self
        imagePickerCtrl.sourceType = .photoLibrary
        self.present(imagePickerCtrl, animated: true, completion: nil)
    }
    
    @IBAction func onRegisterAction(sender: UIButton){
        guard let name = tfName.text, let email = tfEmail.text,
            let pwd = tfPass.text, let image = avatar  else {
                return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
            if error == nil {
                let imageData = UIImageJPEGRepresentation(image, 0.5)
                let refer = FIRStorage.storage().reference().child("UserProfiles").child(NSUUID().uuidString)
                refer.put(imageData!, metadata: nil, completion: { (metaData, error) in
                    if error == nil {
                        let photoUrl = metaData?.downloadURL()?.absoluteString
                        let userRef = FIRDatabase.database().reference().child("users").child((user?.uid)!)
                        userRef.updateChildValues(["name":name, "email":email, "photoURL":photoUrl!], withCompletionBlock: { (error, reference) in
                            if error == nil {
                                let chatRoomVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewCtrl") as! ChatRoomViewCtrl
                                self.navigationController?.pushViewController(chatRoomVC, animated: true)
                            }
                        })
                    }
                })
            }
        })
    }
}

extension RegisterViewCtrl: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let img = image {
            self.avatar = img
            self.imgAvatar.image = image
        }
    }
}


