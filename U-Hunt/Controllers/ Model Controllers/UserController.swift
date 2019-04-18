//
//  UserController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/8/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class UserController {
    
    static let shared = UserController()
    
    let usersRef = Database.database().reference(withPath: "users")
    var currentUserRef: DatabaseReference?
    let storageRef = Storage.storage().reference(withPath: "profilePics")
    
    func saveNewUserWith(authData: Firebase.User, username: String) {
        var newUser = User(authData: authData, username: username)
        
        guard let imageData = newUser.imageData else { return }
        
        let child = storageRef.child(username)
        child.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error storing image: \(error), \(error.localizedDescription)")
                return
            }
            
            guard let metadata = metadata else { return }
            
            newUser.imagePath = metadata.path
        
            // Save to Firebase
            self.currentUserRef = self.usersRef.child(newUser.uid)
            
            guard let currentUserRef = self.currentUserRef else { return }
            
            currentUserRef.setValue(newUser.toAnyObject())
        }
    }
    
    func update(user: User, username: String?, profileImage: UIImage?) {
        let currentUserRef = usersRef.child(user.uid)
        var user = user
        
        if username != nil {
            user.username = username!
            currentUserRef.updateChildValues(["username" : username!])
        }
        if profileImage != nil {
            user.profileImage = profileImage!
            
            guard let imageData = user.imageData else { return }
            
            let child = storageRef.child(user.username)
            
            child.delete(completion: nil)
            child.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error storing image: \(error), \(error.localizedDescription)")
                    return
                }
                
                guard let metadata = metadata else { return }
                
                user.imagePath = metadata.path
                
                currentUserRef.updateChildValues(["profileImageRef" : user.imagePath!])
            }
        }
    }
    
    func delete(user: User) {
        currentUserRef = usersRef.child(user.uid)
        currentUserRef?.removeValue()
    }
    
    func fetchUserWithUID(_ uid: String, completion: @escaping (User?) -> Void) {
        usersRef.child(uid).observe(.value) { (snapshot) in
            guard var user = User(snapshot: snapshot),
                let imagePath = user.imagePath else { completion(nil); return }
            
            Storage.storage().reference(withPath: imagePath).getData(maxSize: 1024 * 1024 * 1024, completion: { (data, error) in
                if let error = error {
                    print("Error getting image data: \(error), \(error.localizedDescription)")
                    completion(nil)
                }
                
                guard let data = data else { completion(nil); return }
                
                user.imageData = data
                completion(user)
            })
        }
    }
}

