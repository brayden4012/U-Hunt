//
//  Stop.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/9/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class Stop {
    
    static let idKey = "id"
    static let latitudeLocationKey = "latitudeLocation"
    static let longitudeLocationKey = "longitudeLocation"
    static let nameKey = "name"
    static let instructionsKey = "instructions"
    static let infoKey = "info"
    static let questionAndAnswerKey = "questionAndAnswer"
    
    var ref: DatabaseReference?
    var id: String?
    var location: CLLocation
    var latitudeLocation: String?
    var longitudeLocation: String?
    var name: String?
    var instructions: String?
    var info: String?
    var questionAndAnswer: [String]?
    
    init(location: CLLocation, name: String?, instructions: String?, info: String?, questionAndAnswer: [String]?) {
        self.location = location
        self.name = name
        self.instructions = instructions
        self.info = info
        self.questionAndAnswer = questionAndAnswer
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String : AnyObject],
            let latitudeLocation = value[Stop.latitudeLocationKey] as? String,
            let longitudeLocation = value[Stop.longitudeLocationKey] as? String,
            let latitude = CLLocationDegrees(latitudeLocation),
            let longitude = CLLocationDegrees(longitudeLocation) else { return nil }
        
        let name = value[Stop.nameKey] as? String
        let instructions = value[Stop.instructionsKey] as? String
        let info = value[Stop.infoKey] as? String
        let questionAndAnswer = value[Stop.questionAndAnswerKey] as? [String]
        
        // Convert latitude and longitude strings into CLLocation
        self.latitudeLocation = latitudeLocation
        self.longitudeLocation = longitudeLocation
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        
        self.ref = snapshot.ref
        self.id = snapshot.key
        self.name = name
        self.instructions = instructions
        self.info = info
        self.questionAndAnswer = questionAndAnswer

    }
    
    func toAnyObject() -> [String : Any] {
        guard let latitudeLocation = latitudeLocation,
            let longitudeLocation = longitudeLocation else { return [:] }
        
        var returnDict: Dictionary<String, Any> = [Stop.latitudeLocationKey : latitudeLocation, Stop.longitudeLocationKey : longitudeLocation]
        
        if id != nil {
            returnDict[Stop.idKey] = id!
        }
        if name != nil {
            returnDict[Stop.nameKey] = name!
        }
        if instructions != nil {
            returnDict[Stop.instructionsKey] = instructions!
        }
        if info != nil {
            returnDict[Stop.infoKey] = info!
        }
        if questionAndAnswer != nil {
            returnDict[Stop.questionAndAnswerKey] = questionAndAnswer!
        }
        
        return returnDict
    }
    
}
extension Stop: Equatable {
    static func == (lhs: Stop, rhs: Stop) -> Bool {
        return lhs.id == rhs.id
    }
}
