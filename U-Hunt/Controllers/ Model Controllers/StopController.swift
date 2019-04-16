//
//  StopController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/9/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class StopController {
    
    // MARK: - Singleton/Shared Instance
    static let shared = StopController()
    
    // MARK: - Properties
    let stopsRef = Database.database().reference(withPath: "stops")
    var stops: [Stop] = []
    var stopIDs: [String] = []
    var fetchedStop: Stop?
    
    // MARK: - CRUD Functions
    func saveStopWith(location: CLLocation, name: String?, instructions: String?, info: String?, questionAndAnswer: [String]?) {
        
        let newStop = Stop(location: location, name: name, instructions: instructions, info: info, questionAndAnswer: questionAndAnswer)
        
        newStop.latitudeLocation = String(newStop.location.coordinate.latitude)
        newStop.longitudeLocation = String(newStop.location.coordinate.longitude)
        
        let currentStopRef = stopsRef.childByAutoId()
        
        newStop.id = currentStopRef.key
        
        //Save locally
        stops.append(newStop)
        // Save to Firebase
        currentStopRef.setValue(newStop.toAnyObject())
    }
    
    func fetchStopWithID(_ id: String, completion: @escaping (Bool) -> Void) {
        stopsRef.child(id).observeSingleEvent(of: .value) { (snapshot) in

            guard let stop = Stop(snapshot: snapshot) else { completion(false); return }
            self.fetchedStop = stop
            
            completion(true)
        }
    }
    
    func modify(stop: Stop, location: CLLocation?, name: String?, instructions: String?, info: String?, questionAndAnswer: [String]?, atIndex index: Int) {
        guard let stopID = stop.id else { return }
        
        let currentStopRef = stopsRef.child(stopID)
        
        var updateValues: Dictionary<String, Any> = [:]
        
        if location != nil {
            stop.location = location!
            let latitudeLocation = String(location!.coordinate.latitude)
            let longitudeLocation = String(location!.coordinate.longitude)
            updateValues[Stop.latitudeLocationKey] = latitudeLocation
            updateValues[Stop.longitudeLocationKey] = longitudeLocation
        }
        if name != nil {
            stop.name = name
            updateValues[Stop.nameKey] = name!
        }
        if instructions != nil {
            stop.instructions = instructions!
            updateValues[Stop.instructionsKey] = instructions!
        }
        if info != nil {
            stop.info = info!
            updateValues[Stop.infoKey] = info!
        }
        if questionAndAnswer != nil {
            stop.questionAndAnswer = questionAndAnswer!
            updateValues[Stop.questionAndAnswerKey] = questionAndAnswer!
        }
        
        // Modify locally
        stops[index] = stop
        
        // Modify in Firebase
        currentStopRef.updateChildValues(updateValues)
    }
    
    func moveStopFor(hunt: Hunt?, fromIndex i: Int, toIndex j: Int, completion: @ escaping (Bool) -> Void) {
        if hunt != nil {
            stopIDs.removeAll()
            for stopID in hunt!.stopsIDs {
                stopIDs.append(stopID)
            }
            let removedStop = stopIDs.remove(at: i)
            stopIDs.insert(removedStop, at: j)
            // Modify in Firebase
            HuntController.shared.modify(hunt: hunt!, title: nil, description: nil, stopsIDs: stopIDs, distance: nil, reviewIDs: nil, avgRating: nil, thumbnailImage: nil, privacy: nil)
            completion(true)
        } else {
            let removedStop = stops.remove(at: i)
            stops.insert(removedStop, at: j)
            completion(true)
        }
    }
    
    func delete(stop: Stop) {
        guard let stopID = stop.id else { return }
        
        // Remove locally
        guard let indexToRemove = stops.firstIndex(where: { $0 == stop }) else { return }
        stops.remove(at: indexToRemove)
        
        // Remove from Firebase
        let currentStopRef = stopsRef.child(stopID)
        currentStopRef.removeValue()
    }
    
    func deleteAllStops() {
        for stop in stops {
            guard let stopID = stop.id else { return }
            
            // Remove from Firebase
            let currentStopRef = stopsRef.child(stopID)
            currentStopRef.removeValue()
        }
        // Remove Locally
        stops.removeAll()
    }
}
