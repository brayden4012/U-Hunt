//
//  HuntController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/5/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseStorage

class HuntController {
    
    // MARK: - Singleton/Shared Instance
    static let shared = HuntController()
    
    // MARK: - Properties
    let huntsRef = Database.database().reference(withPath: "hunts")
    var currentHuntRef: DatabaseReference?
    let storageRef = Storage.storage().reference(withPath: "huntThumbnails")
    
    let stops: [CLLocation] = []
    
    func saveHuntWith(title: String, description: String?, stops: [CLLocation], distance: Double = 0, reviews: [Review]?, avgRating: Double = 0, creatorID: String, thumbnailImage: UIImage = #imageLiteral(resourceName: "pirateMap"), privacy: Privacy) {
        
        var newHunt = Hunt(title: title, description: description, stops: stops, distance: distance, reviews: reviews, avgRating: avgRating, creatorID: creatorID, thumbnailImage: thumbnailImage, privacy: privacy)
        
        
    }
}
