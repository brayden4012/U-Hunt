//
//  HomeController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/3/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class HomeController: UIViewController {
    
    //  MARK: - Properties
    var menuOpen = false
    var height: CGFloat?
    let blackView = UIView()
    let locationManager = CLLocationManager()
    var currentUser: User?
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var huntListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Auth.auth().addStateDidChangeListener { (auth, user) in
//            guard let user = user else { return }
//            currentUser = 
//            
//        }
    }
    
    // MARK: - Life Cycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        
        if let window = UIApplication.shared.keyWindow {
            height = view.frame.height
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            view.addSubview(blackView)
            blackView.frame = CGRect(x: 200, y: self.searchBar.frame.origin.x, width: window.frame.width - 200, height: height!)
            blackView.alpha = 0
        }
    }
    
    // MARK: - IBActions
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

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "huntCell", for: indexPath) as? HuntTableViewCell
        
        return cell ?? UITableViewCell()
    }
    
    
}

extension HomeController: CLLocationManagerDelegate {
    
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
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
