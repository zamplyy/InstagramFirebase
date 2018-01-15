//
//  SignUpViewController.swift
//  InstagramFirebase
//
//  Created by Joar Karlson on 2017-11-13.
//  Copyright © 2017 Joar Karlson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confPassField: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    let picker = UIImagePickerController()
    //let nav = UINavigationController()
    var userStorage: StorageReference!
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        //nav.delegate = self

        let storage = Storage.storage().reference(forURL: "gs://instagramclone-e2166.appspot.com")
        userStorage = storage.child("user")
        ref = Database.database().reference()
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        guard nameField.text != "", emailField.text != "", passwordField.text != "", confPassField.text != "" else {
            return
        }
        if passwordField.text == confPassField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let user = user {
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.image.image!, 0.5)
                    
                    let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        imageRef.downloadURL(completion: { (url, erro) in
                            if erro != nil {
                                print(erro!.localizedDescription)
                            }
                            
                            if let url = url {
                                let userInfo: [String : Any] = ["uid" : user.uid, "Fullname" : self.nameField.text! , "urlToImage" : url.absoluteString]
                                
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                                let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                                self.present(VC, animated: true, completion: nil)
                            }
                        })
                    
                    })
                    uploadTask.resume()
                }
            }
        } else {
            print("Password does not match.")
        }
        
    }
    
    @IBAction func selectBtnPressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let iMage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.image.image = iMage
            nextBtn.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
}
