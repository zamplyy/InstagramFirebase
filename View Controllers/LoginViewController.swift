//
//  LoginViewController.swift
//  InstagramFirebase
//
//  Created by Joar Karlson on 2017-11-13.
//  Copyright © 2017 Joar Karlson. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var EMAIL: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailField: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
            self.present(VC, animated: false, completion: nil)
        }
    }
    
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        guard EMAIL.text != nil , passwordField.text != nil else {
            return
        }
        
        Auth.auth().signIn(withEmail: EMAIL.text!, password: passwordField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let user = user {
                let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                self.present(VC, animated: true, completion: nil)
            }
            
        }
        
        
    }
}
