//
//  MapViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/3/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    //  MARK: - Properties
    var menuOpen = false
    var height: CGFloat?
    let blackView = UIView()
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentLocation = LocationManager.shared.currentLocation else { return }
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

//        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 6.0)
//        let view = GMSMapView.map(withFrame: mapView.frame, camera: camera)
//        mapView = view
//
//        mapView.isMyLocationEnabled = true
//
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        
        if let window = UIApplication.shared.keyWindow {
            height = view.frame.height - window.safeAreaInsets.top
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            view.addSubview(blackView)
            blackView.frame = CGRect(x: 200, y: self.searchBar.frame.origin.x, width: window.frame.width - 200, height: height!)
            blackView.alpha = 0
        }
    }
    
    // MARK: - IBActions
    @IBAction func listButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
            
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        if menuOpen {
            closeMenu()
        } else {
            openMenu()
        }
    }
    
    @objc func handleDismiss() {
        closeMenu()
    }
    
    func openMenu() {
        guard let height = height else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.menuContainerView.frame = CGRect(x: 0, y: self.searchBar.frame.origin.x, width: 200, height: height)
        }
        self.menuOpen = true
    }
    
    func closeMenu() {
        guard let height = height else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.menuContainerView.frame = CGRect(x: -200, y: self.searchBar.frame.origin.x, width: 200, height: height)
            self.blackView.alpha = 0
        }
        
        self.menuOpen = false
    }
}
// CLLocationManager Delegate Methods
extension MapViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            print("Current location: \(currentLocation)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
