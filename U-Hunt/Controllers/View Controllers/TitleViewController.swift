//
//  TitleViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/8/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import NotificationCenter

class TitleViewController: UIViewController {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getLocation()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "toHomeVC", sender: nil)
            }
        }
    }
}
extension TitleViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        @unknown default:
            fatalError("CLAuthorizationStatus has additional values")
        }
        
        DispatchQueue.main.async {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            LocationManager.shared.currentLocation = currentLocation
        }
        
        if LocationManager.shared.isInAHunt {
            guard let currentLocation = locations.last,
                let targetLocation = LocationManager.shared.targetLocation else { return }
            
            if currentLocation.distance(from: targetLocation) < 10 {
                print("You have arrived")
                let notification = Notification(name: Notification.Name(rawValue: "arrived"), object: nil)
                NotificationCenter.default.post(notification)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
