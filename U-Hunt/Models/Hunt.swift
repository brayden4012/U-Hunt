//
//  Hunt.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/4/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

enum Privacy: String {
    case publicHunt
    case privateHunt
}

class Hunt {
    
    static let titleKey = "title"
    static let descriptionKey = "description"
    static let stopsIDsKey = "stopsIDs"
    static let distanceKey = "distance"
    static let reviewIDsKey = "reviewIDs"
    static let avgRatingKey = "avgRating"
    static let creatorIDKey = "creatorID"
    static let imagePathKey = "thumbnailImagePath"
    static let privacyKey = "privacy"
    
    var ref: DatabaseReference?
    var title: String
    var description: String?
    var stopsIDs: [String]
    var distance: Double
    var reviewIDs: [String]?
    var avgRating: Double
    var creatorID: String
    var thumbnailImage: UIImage {
        get {
            guard let imageData = imageData else { return #imageLiteral(resourceName: "pirateMap") }
            
            guard let image = UIImage(data: imageData) else { return #imageLiteral(resourceName: "profileDefault") }
            
            return image
        }
        set {
            imageData = newValue.jpegData(compressionQuality: 0.8)
        }
    }
    var imageData: Data?
    var imagePath: String?
    var privacy: Privacy
    
    init(title: String, description: String?, stopsIDs: [String], distance: Double = 0, reviewIDs: [String]?, avgRating: Double = 0, creatorID: String, thumbnailImage: UIImage = #imageLiteral(resourceName: "pirateMap"), privacy: Privacy) {
        self.title = title
        self.description = description
        self.stopsIDs = stopsIDs
        self.distance = distance
        self.reviewIDs = reviewIDs
        self.avgRating = avgRating
        self.creatorID = creatorID
        self.privacy = privacy
        self.thumbnailImage = thumbnailImage
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let title = value[Hunt.titleKey] as? String,
            let stopsIDs = value[Hunt.stopsIDsKey] as? [String],
            let distance = value[Hunt.distanceKey] as? Double,
            let avgRating = value[Hunt.avgRatingKey] as? Double,
            let creatorID = value[Hunt.creatorIDKey] as? String,
            let imagePath = value[Hunt.imagePathKey] as? String,
            let privacy = value[Hunt.privacyKey] as? Privacy else { return nil }
        
        let description = value[Hunt.descriptionKey] as? String
        let reviewIDs = value[Hunt.reviewIDsKey] as? [String]
        
        self.ref = snapshot.ref
        self.title = title
        self.description = description
        self.stopsIDs = stopsIDs
        self.distance = distance
        self.reviewIDs = reviewIDs
        self.avgRating = avgRating
        self.creatorID = creatorID
        self.imagePath = imagePath
        self.privacy = privacy
    }
    
    func toAnyObject() -> Any {
        if description != nil && imagePath != nil {
            return [
                Hunt.titleKey : title,
                Hunt.descriptionKey : description!,
                Hunt.stopsIDsKey : stopsIDs,
                Hunt.distanceKey : distance,
                Hunt.avgRatingKey : avgRating,
                Hunt.creatorIDKey : creatorID,
                Hunt.privacyKey : privacy,
                Hunt.imagePathKey : imagePath!
            ]
        } else if description != nil {
            return [
                Hunt.titleKey : title,
                Hunt.descriptionKey : description!,
                Hunt.stopsIDsKey : stopsIDs,
                Hunt.distanceKey : distance,
                Hunt.avgRatingKey : avgRating,
                Hunt.creatorIDKey : creatorID,
                Hunt.privacyKey : privacy
            ]
        } else if imagePath != nil {
            return [
                Hunt.titleKey : title,
                Hunt.stopsIDsKey : stopsIDs,
                Hunt.distanceKey : distance,
                Hunt.avgRatingKey : avgRating,
                Hunt.creatorIDKey : creatorID,
                Hunt.privacyKey : privacy,
                Hunt.imagePathKey : imagePath!
            ]
        } else {
            return [
                Hunt.titleKey : title,
                Hunt.stopsIDsKey : stopsIDs,
                Hunt.distanceKey : distance,
                Hunt.avgRatingKey : avgRating,
                Hunt.creatorIDKey : creatorID,
                Hunt.privacyKey : privacy
            ]
        }
    }
}
