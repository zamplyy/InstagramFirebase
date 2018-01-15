//
//  FeedViewController.swift
//  InstagramFirebase
//
//  Created by Joar Karlson on 2017-11-15.
//  Copyright © 2017 Joar Karlson. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts = [Post]()
    var following = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchPosts()
    }
    
    func fetchPosts(){
        let ref = Database.database().reference()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            let users = snapshot.value as! [String : AnyObject]
            
            for(_,value) in users {
                if let uid = value["uid"] as? String {
                    if uid == Auth.auth().currentUser?.uid {
                        if let followingUsers = value["following"] as? [String : String] {
                            for (_ , user) in followingUsers{
                                self.following.append(user)
                            }
                        }
                        self.following.append(Auth.auth().currentUser!.uid)
                        
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value , with: { (snap) in
                            let postsSnap = snap.value as! [String : AnyObject]
                                for(_ , post) in postsSnap {
                                    if let userId = post["UserId"] as? String {
                                        for each in self.following {
                                            if each == userId {
                                                let posst = Post()
                                                if let author = post["author"] as? String, let likes = post["likes"] as? Int , let pathToImg = post["pathToImage"] as? String, let postId = post["postId"] as? String {

                                                    posst.author = author
                                                    posst.likes = "\(likes)"
                                                    posst.pathToImage = pathToImg
                                                    posst.userid = userId
                                                    posst.postId = postId

                                                    self.posts.append(posst)
                                                }
                                            }
                                        }
                                    }
                                    self.collectionView.reloadData()
                                    }
                                })
                            }
                        }
                    }
                }
        ref.removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count ?? 0
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.autherLbl.text = self.posts[indexPath.row].author
        cell.likesLabel.text = "\(self.posts[indexPath.row].likes!) Likes"
        
        
        return cell
    }
}
