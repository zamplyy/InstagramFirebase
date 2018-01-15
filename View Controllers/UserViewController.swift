//
//  UserViewController.swift
//  InstagramFirebase
//
//  Created by Joar Karlson on 2017-11-13.
//  Copyright © 2017 Joar Karlson. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        retrieveUsers()
    }
    func retrieveUsers(){
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            self.users.removeAll()
            
            for (_, value) in users {
                if let uid = value ["uid"] as? String {
                    if uid != userID{
                        let showUser = User()
                        
                        if let fullName = value["Fullname"] as? String,
                            let imagePath = value ["urlToImage"] as? String {
                            showUser.fullName = fullName
                            showUser.imagePath = imagePath
                            showUser.userID = uid
                            
                            self.users.append(showUser)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
        ref.removeAllObservers()
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        cell.nameLabel.text = self.users[indexPath.row].fullName
        cell.userID = self.users[indexPath.row].userID
        cell.userImage.downloadImage(from: users[indexPath.row].imagePath!)
        checkFollowing(indexPath: indexPath)
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            if let following = snapshot.value as? [String:AnyObject]{
                for (ke, value) in following{
                    if value as! String == self.users[indexPath.row].userID {
                        isFollower = true
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid]
                
                print(uid)
                print(self.users[indexPath.row].userID)
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.users[indexPath.row].userID).updateChildValues(followers)
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
        ref.removeAllObservers()
    }
    
    func checkFollowing(indexPath: IndexPath){
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            if let following = snapshot.value as? [String:AnyObject]{
                for (_ , value) in following{
                     if value as! String == self.users[indexPath.row].userID {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        }
        ref.removeAllObservers()
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try? Auth.auth().signOut()
            
            if Auth.auth().currentUser == nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension UIImageView {
    
    func downloadImage(from imgUrl: String!){
        let url = URLRequest(url: URL(string: imgUrl)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
