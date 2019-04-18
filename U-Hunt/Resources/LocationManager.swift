//
//  LocationManager.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/4/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    // MARK: - Singleton/Shared Instance
    static let shared = LocationManager()
    
    var currentLocation: CLLocation?
    var isInAHunt = false
    var targetLocation: CLLocation?
}
