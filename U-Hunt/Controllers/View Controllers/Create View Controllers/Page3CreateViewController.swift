//
//  Page3CreateViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/5/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import MapKit

class Page3CreateViewController: UIViewController {

    // MARK: - Properties
    var huntTitle: String?
    var huntDescription: String?
    var thumbnailImage: UIImage?
    var privacy: String?
    var calloutView: CustomCalloutView?
    var activityIndicator: UIActivityIndicatorView?
    var locationPlacemarks: [CLPlacemark]?
    var hunt: Hunt?
    
    // MARK: - IBOutlets
    @IBOutlet weak var stopsTableView: UITableView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var addStopButton: UIButton!
    @IBOutlet weak var addStopButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var addStopButtonTopRestraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        stopsTableView.delegate = self
        stopsTableView.isEditing = true
        instructionsLabel.adjustsFontSizeToFitWidth = true
        instructionsLabel.textColor = .white
        addStopButton.isHidden = true
        addStopButtonHeight.constant = stopsTableView.frame.height / 3.1
        
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        self.calloutView = views?[0] as? CustomCalloutView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        renameStopsIfNeeded { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    func updateViews() {
        let stops = StopController.shared.stops
        DispatchQueue.main.async {
            self.stopsTableView.reloadData()
            if stops.count > 3 {
                self.stopsTableView.scrollToRow(at: IndexPath(item: stops.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
        
        instructionsLabel.textColor = .white
        
        guard let location = LocationManager.shared.currentLocation?.coordinate else { return }
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 4000, longitudinalMeters: 4000)
        mapView.setRegion(region, animated: true)
        
        mapView.removeAnnotations(self.mapView.annotations)
        
        var index = 1
        for stop in StopController.shared.stops {
            let annotation = MKPointAnnotation()
            annotation.coordinate = stop.location.coordinate
            annotation.title = "\(index)"
            annotation.subtitle = "Remove Stop?"
            index += 1
            
            self.mapView.addAnnotation(annotation)
        }

        if StopController.shared.stops.count > 1 {
            mapView.removeOverlays(mapView.overlays)
            plotLines()
        }
        
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }

    func plotLines() {
        var coordinates: [CLLocationCoordinate2D] = []
        for stop in StopController.shared.stops {
            coordinates.append(stop.location.coordinate)
            if coordinates.count == 2 {
                drawLine(coordinates: coordinates)
                coordinates.removeFirst()
            }
        }
    }
    
    func drawLine(coordinates: [CLLocationCoordinate2D]) {
        let polyline = MKPolyline(coordinates: coordinates, count: 2)
        mapView.addOverlay(polyline)
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        activityIndicator?.style = .whiteLarge
        activityIndicator?.backgroundColor = view.backgroundColor
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)
    }
    
    func hideActivityIndicator() {
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    // MARK: - IBActions
    @IBAction func addStopButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "addStopSegue", sender: nil)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let stops = StopController.shared.stops
        
        if stops.count > 1 {
            self.performSegue(withIdentifier: "toPage4", sender: nil)
        } else {
            instructionsLabel.textColor = .red
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if hunt == nil {
            StopController.shared.deleteAllStops()
        } else {
            StopController.shared.stops.removeAll()
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func renameStopsIfNeeded(completion: @escaping (Bool) -> Void) {
        let stops = StopController.shared.stops
        
        var currIndex = 0
        for stop in stops {
            guard let name = stop.name else { completion(false); return }
            if name == "Start Location" {
                if currIndex == stops.count - 1 && stops.count > 1{
                    StopController.shared.modify(stop: stop, location: nil, name: "Final Destination", instructions: nil, info: nil, questionAndAnswer: nil, atIndex: currIndex)
                } else if currIndex > 0 {
                    StopController.shared.modify(stop: stop, location: nil, name: "Stop \(currIndex)", instructions: nil, info: nil, questionAndAnswer: nil, atIndex: currIndex)
                }
            } else if name.contains("Stop") {
                if currIndex == 0 {
                    StopController.shared.modify(stop: stop, location: nil, name: "Start Location", instructions: nil, info: nil, questionAndAnswer: nil, atIndex: currIndex)
                } else if currIndex == stops.count - 1 {
                    StopController.shared.modify(stop: stop, location: nil, name: "Final Destination", instructions: nil, info: nil, questionAndAnswer: nil, atIndex: currIndex)
                } else {
                    StopController.shared.modify(stop: stop, location: nil, name: "Stop \(currIndex)", instructions: nil, info: nil, questionAndAnswer: nil, atIndex: currIndex)
                }
            } else if name == "Final Destination" {
                if currIndex == 0 {
                    StopController.shared.modify(stop: stop, location: nil, name: "Start Location", instructions: nil, info: nil, questionAndAnswer: nil, atIndex: currIndex)
                } else if currIndex < stops.count - 1 {
                    StopController.shared.modify(stop: stop, location: nil, name: "Stop \(currIndex)", instructions: nil, info: nil, questionAndAnswer: nil, atIndex: currIndex)
                }
            }
            
            currIndex += 1
        }
        completion(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStopSegue" {
            guard let destinationVC = segue.destination as? LocationPickerViewController else { return }
            
            var indexOfStop = stopsTableView.indexPathForSelectedRow?.row
            if indexOfStop == nil {
                indexOfStop = stopsTableView.numberOfRows(inSection: 0)
            }
            
            let stops = StopController.shared.stops
            
            destinationVC.indexOfStop = indexOfStop
            destinationVC.stopsCount = stopsTableView.numberOfRows(inSection: 0)
            if indexOfStop! < stops.count {
                destinationVC.stop = stops[indexOfStop!]
            }
        }
        
        if segue.identifier == "toPage4" {
            guard let huntTitle = huntTitle,
                let privacy = privacy,
                let destinationVC = segue.destination as? Page4CreateViewController else { return }
            
            var currentStopLocation: CLLocation?
            var distance: Double = 0
            for stop in StopController.shared.stops {
                if currentStopLocation == nil {
                    currentStopLocation = stop.location
                } else {
                    let metersDistance = currentStopLocation!.distance(from: stop.location)
                    distance += Double(metersDistance) / 1609.34
                    currentStopLocation = stop.location
                }
            }
            
            destinationVC.huntDistance = distance
            destinationVC.huntTitle = huntTitle
            destinationVC.privacy = privacy
            destinationVC.stops = StopController.shared.stops
            if let description = huntDescription {
                destinationVC.huntDescription = description
            }
            if let thumbnail = thumbnailImage {
                destinationVC.thumbnailImage = thumbnail
            }
            if let hunt = hunt {
                destinationVC.hunt = hunt
            }
        }
    }

}
extension Page3CreateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addStopButtonTopRestraint.constant = 0
        switch StopController.shared.stops.count {
        case 0...1:
            addStopButton.isHidden = true
            return 2
        case 2:
            addStopButton.isHidden = false
            addStopButtonTopRestraint.constant = -(tableView.frame.height / 3)
            return 2
        default:
            addStopButton.isHidden = false
            return StopController.shared.stops.count
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        StopController.shared.moveStopFor(hunt: nil, fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row) { (didSwap) in
            if didSwap {
                self.renameStopsIfNeeded(completion: { (success) in
                    if success {
                        self.updateViews()
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        let stops = StopController.shared.stops
        
        if stops.count == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.textLabel?.text = "Start Location"
            } else {
                cell.textLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.textLabel?.text = "Final Destination"
            }
        } else if stops.count == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell.textLabel?.text = "\(indexPath.row + 1)   \(stops.first!.name!)"
            } else {
                cell.textLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell.textLabel?.text = "Final Destination"
            }
        } else {
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.textLabel?.text = "\(indexPath.row + 1)   \(stops[indexPath.row].name!)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "addStopSegue", sender: nil)
        }
    }
}
extension Page3CreateViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView()
        annotationView.markerTintColor = #colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 0)
        annotationView.image = #imageLiteral(resourceName: "marker")
        annotationView.glyphImage = #imageLiteral(resourceName: "transparent")
        annotationView.selectedGlyphImage = #imageLiteral(resourceName: "line")
        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        annotationView.titleVisibility = .visible
        annotationView.displayPriority = .required
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        
        guard let calloutView = calloutView else { return }
        calloutView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let button = UIButton(frame: calloutView.frame)

        button.setAttributedTitle(NSAttributedString(string: "🗑", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 36)]), for: .normal)
        button.layer.setValue(annotation?.title!, forKey: "title")
        button.addTarget(self, action: #selector(deleteStop), for: .touchUpInside)
        calloutView.addSubview(button)
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: 70)
        view.addSubview(calloutView)
        mapView.setCenter(view.annotation!.coordinate, animated: true)
    }
    
    @objc func deleteStop(_ sender: UIButton) {
        guard let title = sender.layer.value(forKey: "title") as? String,
            let intTitle = Int(title) else { return }
        
        var stops = StopController.shared.stops
        let index = intTitle - 1
        
        StopController.shared.delete(stop: stops[index])
        
        renameStopsIfNeeded { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let calloutView = calloutView else { return }
        
        calloutView.removeFromSuperview()
    }
    
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            polylineRenderer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            switch mapView.overlays.count % 14 {
            case 1:
                polylineRenderer.alpha = 0.75
            case 2:
                polylineRenderer.alpha = 0.7
            case 3:
                polylineRenderer.alpha = 0.65
            case 4:
                polylineRenderer.alpha = 0.6
            case 5:
                polylineRenderer.alpha = 0.55
            case 6:
                polylineRenderer.alpha = 0.5
            case 7:
                polylineRenderer.alpha = 0.45
            case 8:
                polylineRenderer.alpha = 0.4
            case 9:
                polylineRenderer.alpha = 0.35
            case 10:
                polylineRenderer.alpha = 0.3
            case 11:
                polylineRenderer.alpha = 0.25
            case 12:
                polylineRenderer.alpha = 0.2
            case 13:
                polylineRenderer.alpha = 0.15
            default:
                polylineRenderer.alpha = 0.1
            }
            
            polylineRenderer.lineWidth = 3
        }
        return polylineRenderer
    }
}

