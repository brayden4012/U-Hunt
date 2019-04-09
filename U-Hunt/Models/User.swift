//
//  User.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/4/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

struct User {
    
    static let uidKey = "uid"
    static let emailKey = "email"
    static let usernameKey = "username"
    static let imagePathKey = "imagePath"
    
    let ref: DatabaseReference?
    let uid: String
    let email: String
    var username: String
    var profileImage: UIImage {
        get {
            guard let imageData = imageData else { return #imageLiteral(resourceName: "profileDefault") }
            
            guard let image = UIImage(data: imageData) else { return #imageLiteral(resourceName: "profileDefault") }
            
            return image
        }
        set {
            imageData = newValue.jpegData(compressionQuality: 0.8)
        }
    }
    var imageData: Data?
    var imagePath: String?
    
    init(authData: Firebase.User, username: String, profileImage: UIImage = #imageLiteral(resourceName: "profileDefault")) {
        ref = nil
        uid = authData.uid
        email = authData.email!
        self.username = username
        self.profileImage = profileImage
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let uid = value["uid"] as? String,
            let email = value["email"] as? String,
            let username = value["username"] as? String,
            let imagePath = value["profileImagePath"] as? String else { return nil }
        
        self.ref = snapshot.ref
        self.uid = uid
        self.email = email
        self.username = username
        self.imagePath = imagePath
    }
    
    func toAnyObject() -> Any {
        return [
            "uid": uid,
            "email": email,
            "username": username,
            "profileImagePath": imagePath
        ]
    }
}
