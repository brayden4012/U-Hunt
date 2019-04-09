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
    static let locationKey = "location"
    static let nameKey = "name"
    static let instructionsKey = "instructions"
    static let infoKey = "info"
    static let questionAndAnswerKey = "questionAndAnswer"
    
    var id: String?
    var location: CLLocation
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
            let location = value[Stop.locationKey] as? CLLocation else { return nil }
        
        let name = value[Stop.nameKey] as? String
        let instructions = value[Stop.instructionsKey] as? String
        let info = value[Stop.infoKey] as? String
        let questionAndAnswer = value[Stop.questionAndAnswerKey] as? [String]
        
        self.location = location
        self.name = name
        self.instructions = instructions
        self.info = info
        self.questionAndAnswer = questionAndAnswer
    }
    
    func toAnyObject() -> Any {
        var returnDict: Dictionary<String, Any> = [:]
        
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
    }
    
}
