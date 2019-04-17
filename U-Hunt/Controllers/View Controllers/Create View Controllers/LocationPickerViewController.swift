//
//  LocationPickerViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/9/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import MapKit

class LocationPickerViewController: UIViewController {

    // MARK: - Properties
    var searchResults: [MKMapItem]? {
        didSet {
            guard let searchResults = searchResults else { return }
            if searchResults.count == 0 {
                hideResults()
            } else {
                DispatchQueue.main.async {
                    self.displayResults()
                    self.searchResultsTableView.reloadData()
                }
            }
        }
    }
    // Landing Pads
    var stop: Stop?
    var indexOfStop: Int?
    var stopsCount: Int?
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var stackViewTopRestraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pin: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let location = LocationManager.shared.currentLocation?.coordinate else { return }
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 4000, longitudinalMeters: 4000)
        mapView.setRegion(region, animated: true)
        
        okButton.layer.cornerRadius = okButton.frame.width / 2
        
        if stop != nil {
            self.title = "Edit Stop"
            let region = MKCoordinateRegion(center: stop!.location.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
            mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = stop!.location.coordinate
            annotation.title = stop!.name
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pinBottomConstraint.constant = mapView.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideResults()
        pin.isHidden = true
        okButton.isHidden = true
    }
    
    // MARK: - IBActions
    @IBAction func chooseOnMapButtonTapped(_ sender: Any) {
        pin.isHidden = false
        okButton.isHidden = false
        self.mapView.removeAnnotations(self.mapView.annotations)
        searchResults = []
        self.view.endEditing(true)
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        let location = getCenterLocation(for: self.mapView)
        var name = "Start Location"
        
        guard let index = indexOfStop,
            let count = stopsCount else { return }
        
        if index == count - 1 {
            name = "Final Destination"
        } else if index < count - 1 && index > 0 {
            name = "Stop \(index)"
        }
        
        if stop == nil {
            StopController.shared.saveStopWith(location: location, name: name, instructions: "Travel to \(name) for your next clue!", info: "Welcome!", questionAndAnswer: nil)
        } else {
            StopController.shared.modify(stop: stop!, location: location, name: name, instructions: nil, info: "Welcome to \(name)!", questionAndAnswer: nil, atIndex: index)
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func displayResults() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.stackViewTopRestraint.constant = 0
            })
        }
    }
    
    func hideResults() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.stackViewTopRestraint.constant = 0 - self.searchResultsTableView.frame.height
            })
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
// MARK: - Table View Data Source Methods
extension LocationPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let searchResults = searchResults else { return 0 }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        guard let placemarkName = searchResults?[indexPath.row].placemark.name else { return cell }
        cell.textLabel?.text = placemarkName
        
        guard let placemarkTitle = searchResults?[indexPath.row].placemark.title else { return cell }
        cell.detailTextLabel?.text = returnShortenedTitle(name: placemarkName, title: placemarkTitle)
        
        return cell
    }
    
    func returnShortenedTitle(name: String, title: String) -> String {
        guard let commaIndex = title.firstIndex(of: ",") else { return title }
        var shortenedTitle = title[..<commaIndex]
        
        if name == "\(shortenedTitle)" {
            shortenedTitle = title[commaIndex...]
            shortenedTitle.removeFirst()
            return "\(shortenedTitle)"
        } else {
            return title
        }
    }
}
// MARK: - Table View Delegate Methods
extension LocationPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let placemark = searchResults?[indexPath.row].placemark,
            let name = placemark.name,
            let title = placemark.title else { return }
        
        let annotationToShow = mapView.annotations.firstIndex { (annotation) -> Bool in
            annotation.subtitle == returnShortenedTitle(name: name, title: title)
        }
        guard let index = annotationToShow else { return }
        
        mapView.showAnnotations([self.mapView.annotations[index]], animated: true)
        mapView.selectAnnotation(self.mapView.annotations[index], animated: true)
        searchBar.endEditing(true)
    }
}
// MARK: - SearchBar Delegate
extension LocationPickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pin.isHidden = true
        okButton.isHidden = true
        searchForPlacesWithText(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchForPlacesWithText(_ searchText: String) {
        if searchText.isEmpty {
            DispatchQueue.main.async {
                self.searchResults = []
            }
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let error = error {
                print("Error searching for places: \(error), \(error.localizedDescription)")
                return
            }
            
            guard let response = response else { return }
            
            self.searchResults = response.mapItems
        
            self.mapView.removeAnnotations(self.mapView.annotations)
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.placemark.name
                
                guard let placemarkTitle = item.placemark.title,
                    let commaIndex = placemarkTitle.firstIndex(of: ",") else { return }
                
                var shortenedTitle = placemarkTitle[..<commaIndex]
                
                if item.placemark.name == "\(shortenedTitle)" {
                    shortenedTitle = placemarkTitle[commaIndex...]
                    shortenedTitle.removeFirst()
                    
                    annotation.subtitle = "\(shortenedTitle)"
                } else {
                    annotation.subtitle = item.placemark.title
                }
                
                self.mapView.addAnnotation(annotation)
            }
            
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
}
// MARK: - Map View Delegate
extension LocationPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView()
        annotationView.annotation = annotation
        
        let button = UIButton(type: .contactAdd)
        annotationView.tintColor = #colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 1)
        annotationView.image = #imageLiteral(resourceName: "marker")
        annotationView.rightCalloutAccessoryView = button
        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coordinate = view.annotation?.coordinate,
            let title = view.annotation?.title,
            let index = indexOfStop else { return }
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        if stop == nil {
            let defaultValue = "your stop"
            StopController.shared.saveStopWith(location: location, name: title, instructions: "Travel to \(title ?? defaultValue) for your next clue!", info: "Welcome to \(title ?? defaultValue)!", questionAndAnswer: nil)
        } else {
            StopController.shared.modify(stop: stop!, location: location, name: title, instructions: nil, info: nil, questionAndAnswer: nil, atIndex: index)
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
