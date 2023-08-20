//
//  MapViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/3/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications

class MapViewController: UIViewController {

    //  MARK: - Properties
    var menuOpen = false
    var height: CGFloat?
    let blackView = UIView()
    var distanceFilter = 30
    var huntDetailCalloutView: HuntDetailCalloutView?
    var hasNotRefreshed = true
    
    // MARK: - IBOutlets
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var locationPermissionView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let views = Bundle.main.loadNibNamed("HuntDetailCalloutView", owner: nil, options: nil)
        self.huntDetailCalloutView = views?[0] as? HuntDetailCalloutView
        
        NotificationCenter.default.addObserver(self, selector: #selector(segueToProfile), name: NSNotification.Name("profileButtonTappedFromMap"), object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notification = Notification(name: Notification.Name(rawValue: "mapPageAppeared"), object: nil)
        NotificationCenter.default.post(notification)
        
        distanceFilter = HuntController.shared.distanceFilter
        refreshHunts()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            if let error = error {
                print(error)
            }
            if granted == false {
                DispatchQueue.main.async {
                    self.locationPermissionView.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    self.locationPermissionView.isHidden = true
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        LocationManager.shared.currentLocation = mapView.userLocation.location
        menuOpen = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        
        if let window = UIApplication.shared.keyWindow {
            height = view.frame.height
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            view.addSubview(blackView)
            blackView.frame = CGRect(x: 0, y: self.searchBar.frame.origin.x, width: window.frame.width, height: height!)
            blackView.alpha = 0
            view.bringSubviewToFront(menuContainerView)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func segueToProfile() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toProfileVC", sender: nil)
        }
    }
    
    // MARK: - IBActions
    @IBAction func listButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
            
        }
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
        if distanceFilter != HuntController.shared.distanceFilter {
            distanceFilter = HuntController.shared.distanceFilter
            refreshHunts()
        }
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
    
    func refreshHunts() {
        self.loadingView.alpha = 1
        
        HuntController.shared.fetchpublicHuntsWithinDistanceInMiles(HuntController.shared.distanceFilter) { (didFetch) in
            if didFetch {
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.mapView.annotations)
   
                    for hunt in HuntController.shared.localHunts {
                        let annotation = MKPointAnnotation()
                        guard let location = hunt.startLocation else { return }
                        annotation.coordinate = location.coordinate
                        annotation.title = "\(hunt.title)"
                        
                        self.mapView.addAnnotation(annotation)
                    }
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.loadingView.alpha = 0
                    })
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            guard let sender = sender as? UIButton,
                let hunt = sender.layer.value(forKey: "hunt") as? Hunt,
                let destinationVC = segue.destination as? HuntDetailViewController else { return }
            
            destinationVC.hunt = hunt
        }
    }
}
// MARK: - Map View Delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.title != "My Location" {
            let annotationHunt = HuntController.shared.localHunts.first { (hunt) -> Bool in
                return hunt.title == annotation.title
            }
            guard let hunt = annotationHunt else { return nil }
            let annotationView = MKMarkerAnnotationView()
            annotationView.markerTintColor = #colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 0)
            annotationView.image = #imageLiteral(resourceName: "marker")
            annotationView.glyphImage = #imageLiteral(resourceName: "transparent")
            annotationView.selectedGlyphImage = #imageLiteral(resourceName: "line")
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            annotationView.titleVisibility = .visible
            annotationView.displayPriority = .required
            annotationView.layer.setValue(hunt, forKey: "hunt")
            return annotationView
        }
   
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let calloutView = huntDetailCalloutView,
            let hunt = view.layer.value(forKey: "hunt") as? Hunt,
            let startLocation = hunt.startLocation,
            let distanceInMeters = LocationManager.shared.currentLocation?.distance(from: startLocation) else {  return }
        
        let distanceInMiles = Double(distanceInMeters) / 1609.34
        if Int(distanceInMiles) < 2 {
            calloutView.distanceLabel.text = "\(Int(distanceInMiles)) mile away"
        } else {
            calloutView.distanceLabel.text = "\(Int(distanceInMiles)) miles away"
        }
        
        calloutView.huntImageView.image = hunt.thumbnailImage
        
        let button = UIButton(frame: calloutView.buttonView.frame)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 1)
        button.layer.cornerRadius = button.frame.width / 2
        
        button.setAttributedTitle(NSAttributedString(string: "GO", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold)]), for: .normal)
        button.layer.setValue(hunt, forKey: "hunt")
        button.addTarget(self, action: #selector(toDetail), for: .touchUpInside)
        calloutView.addSubview(button)
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height + 70)
        view.addSubview(calloutView)
        mapView.setCenter(view.annotation!.coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let calloutView = huntDetailCalloutView else { return }
        calloutView.removeFromSuperview()
    }
    
    @objc func toDetail(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HuntDetailVC") as! HuntDetailViewController
            guard let hunt = sender.layer.value(forKey: "hunt") as? Hunt else { return }
            vc.hunt = hunt
            self.performSegue(withIdentifier: "toDetailVC", sender: sender)
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if hasNotRefreshed {
            LocationManager.shared.currentLocation = userLocation.location
            refreshHunts()
            hasNotRefreshed = false
        }
    }
}

extension MKAnnotationView {
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubviewToFront(self)
        }
        return hitView
    }
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point)
                if isInside
                {
                    break
                }
            }
        }
        return isInside
    }
}
// MARK: - Search Bar Delegate
extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        HuntController.shared.fetchHuntWithID(searchText) { (didFetch) in
            if didFetch {
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    
                    for hunt in HuntController.shared.localHunts {
                        let annotation = MKPointAnnotation()
                        guard let location = hunt.startLocation else { return }
                        annotation.coordinate = location.coordinate
                        annotation.title = "\(hunt.title)"
                        
                        self.mapView.addAnnotation(annotation)
                        self.mapView.showAnnotations([annotation], animated: true)
                    }
                }
            }
        }
        
        searchBar.resignFirstResponder()
    }
}

