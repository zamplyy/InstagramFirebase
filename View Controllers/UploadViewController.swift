//
//  UploadViewController.swift
//  InstagramFirebase
//
//  Created by Joar Karlson on 2017-11-15.
//  Copyright © 2017 Joar Karlson. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var selectImageBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.previewImage.image = image
            postBtn.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPressed(_ sender: Any) {
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true, completion: nil)
        
    }
    @IBAction func postPressed(_ sender: Any) {
        AppDelegate.instance().showActivityIndicator()
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://instagramclone-e2166.appspot.com")
        
        let key = ref.child("posts").childByAutoId().key
        let imageReference = storage.child("posts").child(uid).child("\(key).jpg")
        
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)
        
        let uploadTask = imageReference.putData(data! , metadata: nil) { (metadata, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                AppDelegate.instance().dissmissActivityIndicator()
                return
            }
            
            imageReference.downloadURL(completion: { (url, error) in
                if let url = url {
                    let feed = ["UserId" : uid,
                                "pathToImage" : url.absoluteString,
                                "likes" : 0,
                                "author" : Auth.auth().currentUser!.displayName!,
                                "postId" : key] as [String : Any]
                    let postfeed = ["\(key)" : feed]
                    ref.child("posts").updateChildValues(postfeed)
                    AppDelegate.instance().dissmissActivityIndicator()
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                
            })
            
        }
        uploadTask.resume()
        
        
        
        
    }
}
