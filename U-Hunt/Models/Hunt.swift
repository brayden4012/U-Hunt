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
    
    static let idKey = "id"
    static let titleKey = "title"
    static let descriptionKey = "description"
    static let startLatitudeLocationKey = "startLatitudeLocation"
    static let startLongitudeLocationKey = "startLongitudeLocation"
    static let stopsIDsKey = "stopsIDs"
    static let distanceKey = "distance"
    static let reviewIDsKey = "reviewIDs"
    static let avgRatingKey = "avgRating"
    static let creatorIDKey = "creatorID"
    static let imagePathKey = "thumbnailImagePath"
    static let privacyKey = "privacy"
    
    var ref: DatabaseReference?
    var id: String?
    var title: String
    var description: String?
    var startLocation: CLLocation?
    var startLatitudeLocation: String?
    var startLongitudeLocation: String?
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
    var privacy: String
    
    init(title: String, description: String?, stopsIDs: [String], distance: Double = 0, reviewIDs: [String]?, avgRating: Double = 0, creatorID: String, thumbnailImage: UIImage = #imageLiteral(resourceName: "pirateMap"), privacy: String) {
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
            let startLatitudeLocation = value[Hunt.startLatitudeLocationKey] as? String,
            let startLongitudeLocation = value[Hunt.startLongitudeLocationKey] as? String,
            let startLatitude = CLLocationDegrees(startLatitudeLocation),
            let startLongitude = CLLocationDegrees(startLongitudeLocation),
            let stopsIDs = value[Hunt.stopsIDsKey] as? [String],
            let distance = value[Hunt.distanceKey] as? Double,
            let avgRating = value[Hunt.avgRatingKey] as? Double,
            let creatorID = value[Hunt.creatorIDKey] as? String,
            let imagePath = value[Hunt.imagePathKey] as? String,
            let privacy = value[Hunt.privacyKey] as? String else { return nil }
        
        
        let description = value[Hunt.descriptionKey] as? String
        let reviewIDs = value[Hunt.reviewIDsKey] as? [String]
        
        // Convert latitude and longitude strings into CLLocation
        let startLocation = CLLocation(latitude: startLatitude, longitude: startLongitude)
        
        self.ref = snapshot.ref
        self.id = snapshot.key
        self.title = title
        self.description = description
        self.startLocation = startLocation
        self.stopsIDs = stopsIDs
        self.distance = distance
        self.reviewIDs = reviewIDs
        self.avgRating = avgRating
        self.creatorID = creatorID
        self.imagePath = imagePath
        self.privacy = privacy
    }
    
    func toAnyObject() -> Any {
        var returnDict: Dictionary<String, Any> = [Hunt.titleKey : title, Hunt.stopsIDsKey : stopsIDs, Hunt.distanceKey : distance, Hunt.avgRatingKey : avgRating, Hunt.creatorIDKey : creatorID, Hunt.privacyKey : privacy]
        
        if id != nil {
            returnDict[Hunt.idKey] = id!
        }
        if description != nil {
            returnDict[Hunt.descriptionKey] = description!
        }
        if imagePath != nil {
            returnDict[Hunt.imagePathKey] = imagePath!
        }
        if startLatitudeLocation != nil && startLongitudeLocation != nil {
            returnDict[Hunt.startLatitudeLocationKey] = startLatitudeLocation
            returnDict[Hunt.startLongitudeLocationKey] = startLongitudeLocation
        }
        
        return returnDict
    }
}
