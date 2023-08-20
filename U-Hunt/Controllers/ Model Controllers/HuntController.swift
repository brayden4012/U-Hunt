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
    let stopsRef = Database.database().reference(withPath: "stops")
    let storageRef = Storage.storage().reference(withPath: "huntThumbnails")
    var localHunts: [Hunt] = []
    var distanceFilter = 30
    var newHuntCreated = false
    
    // MARK: - CRUD Functions
    func saveHuntWith(title: String, description: String?, stopsIDs: [String], distance: Double = 0, reviewIDs: [String]?, avgRating: Double = 0, creatorID: String, thumbnailImage: UIImage = #imageLiteral(resourceName: "pirateMap"), privacy: String, completion: @escaping (Hunt?) -> Void) {
        
        let newHunt = Hunt(title: title, description: description, stopsIDs: stopsIDs, distance: distance, reviewIDs: reviewIDs, avgRating: avgRating, creatorID: creatorID, thumbnailImage: thumbnailImage, privacy: privacy)
        
        // Assign the hunt a start locartion using the stops array
        guard let startLocationID = newHunt.stopsIDs.first else { completion(nil); return }
        self.stopsRef.child(startLocationID).observeSingleEvent(of: .value) { (snapshot) in
            guard let stop = Stop(snapshot: snapshot) else { return }
            newHunt.startLocation = stop.location
            newHunt.startLatitudeLocation = stop.latitudeLocation
            newHunt.startLongitudeLocation = stop.longitudeLocation
        } 
        
        // Store the thumbnail image on FireStore
        let currentHuntRef = huntsRef.childByAutoId()
        
        guard let refKey = currentHuntRef.key,
            let imageData = newHunt.imageData else { completion(nil); return }
        
        newHunt.id = refKey

        storageRef.child(refKey).putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error storing image: \(error), \(error.localizedDescription)")
                return
            }
            
            guard let metadata = metadata else { completion(nil); return }
            
            newHunt.imagePath = metadata.path
            
            // Set the values of the hunt on realtime database
            currentHuntRef.setValue(newHunt.toAnyObject())
            
            self.newHuntCreated = true
            completion(newHunt)
        }
    }
    
    func fetchHuntWithID(_ id: String, completion: @escaping (Bool) -> Void) {
        huntsRef.child(id).observe(.value) { (snapshot) in
            guard let hunt = Hunt(snapshot: snapshot),
                let imagePath = hunt.imagePath,
                let startLocation = hunt.startLocation,
                let distanceInMeters = LocationManager.shared.currentLocation?.distance(from: startLocation) else { completion(false); return }
            
            let distanceInMiles = Double(distanceInMeters) / 1609.34
            hunt.distance = distanceInMiles
            
            self.fetchThumbnailImageFor(hunt: hunt, imagePath: imagePath, completion: { (data) in
                guard let data = data else { completion(false); return }
                hunt.imageData = data
                self.localHunts = [hunt]
                completion(true)
            })
        } 
    }
    
    func fetchpublicHuntsWithinDistanceInMiles(_ distance: Int, completion: @escaping (Bool) -> Void) {
        
        var localHunts: [Hunt] = []

        huntsRef.queryOrdered(byChild: Hunt.privacyKey).observe(.value) { (snapshot) in
            let dispatchGroup = DispatchGroup()

            for child in snapshot.children.reversed() {
                dispatchGroup.enter()
                if let snapshot = child as? DataSnapshot,
                    let hunt = Hunt(snapshot: snapshot),
                    hunt.privacy == "publicHunt",
                    let startLocation = hunt.startLocation,
                    let imagePath = hunt.imagePath {
                    
                    guard let distanceInMeters = LocationManager.shared.currentLocation?.distance(from: startLocation) else { completion(false); return }
                    let distanceInMiles = Double(distanceInMeters) / 1609.34
                    if distanceInMiles < Double(distance) {
                        // Fetch thumbnail image
                        self.fetchThumbnailImageFor(hunt: hunt, imagePath: imagePath, completion: { (data) in
                            guard let data = data else { completion(false); return }
                            hunt.imageData = data
                            localHunts.append(hunt)
                            dispatchGroup.leave()
                        })
                    } else {
                        dispatchGroup.leave()
                    }
                    
                } else {
                    dispatchGroup.leave()
                    break
                }
            }
            dispatchGroup.notify(queue: .main) {
                guard let currentLocation = LocationManager.shared.currentLocation else { completion(false); return }
                DispatchQueue.main.async {
                    let sortedHunts = localHunts.sorted(by: { (lhs, rhs) -> Bool in
                        guard let lhsStart = lhs.startLocation,
                            let rhsStart = rhs.startLocation else { completion(false); return false }
                        return currentLocation.distance(from: lhsStart) < currentLocation.distance(from: rhsStart)
                    })
                    self.localHunts = sortedHunts
                    completion(true)
                }
            }
        }
    }
    
    func fetchHuntsByUser(userID: String, completion: @escaping ([Hunt]?) -> Void) {
        var userHunts: [Hunt] = []
        huntsRef.queryOrdered(byChild: Hunt.creatorIDKey).observeSingleEvent(of: .value) { (snapshot) in
            let dispatchGroup = DispatchGroup()
            var foundUserID = false
            for child in snapshot.children {
                dispatchGroup.enter()
                if let snapshot = child as? DataSnapshot {
                    if foundUserID {
                        if let value = snapshot.value as? [String: AnyObject],
                            value[Hunt.creatorIDKey] as? String == userID {
                            guard let hunt = Hunt(snapshot: snapshot),
                                let imagePath = hunt.imagePath else { completion(nil); return }

                            self.fetchThumbnailImageFor(hunt: hunt, imagePath: imagePath, completion: { (data) in
                                guard let data = data else { completion(nil); return }
                                hunt.imageData = data
                                userHunts.append(hunt)
                                dispatchGroup.leave()
                            })
                        } else {
                            dispatchGroup.leave()
                            break
                        }
                    } else {
                        if let value = snapshot.value as? [String: AnyObject],
                            value[Hunt.creatorIDKey] as? String == userID {
                            
                            foundUserID = true
                            guard let hunt = Hunt(snapshot: snapshot),
                                let imagePath = hunt.imagePath else { completion(nil); return }
                            
                            self.fetchThumbnailImageFor(hunt: hunt, imagePath: imagePath, completion: { (data) in
                                guard let data = data else { completion(nil); return }
                                hunt.imageData = data
                                userHunts.append(hunt)
                                dispatchGroup.leave()
                            })
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            dispatchGroup.notify(queue: .main, execute: {
                let sorted = userHunts.sorted(by: { $0.title < $1.title })
                completion(sorted)
            })
        }
    }
    
    func fetchThumbnailImageFor(hunt: Hunt, imagePath: String, completion: @escaping (Data?) -> Void) {
        Storage.storage().reference(withPath: imagePath).getData(maxSize: 1024 * 1024 * 1024, completion: { (data, error) in
            if let error = error {
                print("Error fetching thumbnail image: \(error), \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else { completion(nil); return }
            
            completion(data)
        })
    }
    
    func modify(hunt: Hunt, title: String?, description: String?, stopsIDs: [String]?, distance: Double?, reviewIDs: [String]?, avgRating: Double?, thumbnailImage: UIImage?, privacy: String?) {
        guard let huntID = hunt.id else { return }
        
        let currentHuntRef = huntsRef.child(huntID)
        
        var updateValues: Dictionary<String, Any> = [:]
        
        if title != nil {
            hunt.title = title!
            updateValues[Hunt.titleKey] = title!
        }
        if description != nil {
            hunt.description = description!
            updateValues[Hunt.descriptionKey] = description!
        }
        if stopsIDs != nil {
            hunt.stopsIDs = stopsIDs!
            StopController.shared.fetchStopWithID(stopsIDs!.first!) { (didFetch) in
                if didFetch {
                    guard let stop = StopController.shared.fetchedStop else { return }
                    updateValues[Hunt.startLatitudeLocationKey] = stop.latitudeLocation
                    updateValues[Hunt.startLongitudeLocationKey] = stop.longitudeLocation
                }
            }
            
            updateValues[Hunt.stopsIDsKey] = stopsIDs!
        }
        if distance != nil {
            hunt.distance = distance!
            updateValues[Hunt.distanceKey] = distance!
        }
        if reviewIDs != nil {
            hunt.reviewIDs = reviewIDs!
            updateValues[Hunt.reviewIDsKey] = reviewIDs!
        }
        if avgRating != nil {
            hunt.avgRating = avgRating!
            updateValues[Hunt.avgRatingKey] = avgRating!
        }
        if thumbnailImage != nil {
            hunt.thumbnailImage = thumbnailImage!
            
            // Store the thumbnail image on FireStore
            let currentHuntRef = huntsRef.child(huntID)
            
            guard let refKey = currentHuntRef.key,
                let imageData = hunt.imageData else { return }
            
            // Remove previous imageData from Firestore
            storageRef.child(refKey).delete { (error) in
                if let error = error {
                    print("Error deleting previous image data: \(error), \(error.localizedDescription)")
                    return
                }
            }
            
            // Put new imageData in FireStore
            storageRef.child(refKey).putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error storing image: \(error), \(error.localizedDescription)")
                    return
                }
                
                guard let metadata = metadata else { return }
                
                hunt.imagePath = metadata.path
                
                updateValues[Hunt.imagePathKey] = hunt.imagePath
            }
        }
        if privacy != nil {
            hunt.privacy = privacy!
            updateValues[Hunt.privacyKey] = privacy!
        }
        
        currentHuntRef.updateChildValues(updateValues)
    }
    
    func delete(hunt: Hunt, completion: @escaping (Bool) -> Void) {
        guard let huntID = hunt.id else { completion(false); return }
        
        for stopID in hunt.stopsIDs {
            stopsRef.child(stopID).removeValue()
        }
        
        huntsRef.child(huntID).removeValue()
        
        completion(true)
    }
}
