//
//  HuntDetailViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/4/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class HuntDetailViewController: UIViewController {
    
    // MARK: - Properties
    var hunt: Hunt? 
    
    var stops: [Stop]?
    
    // MARK: - IBOutlets

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var gameModeView: UIView!
    @IBOutlet weak var gameModeViewTopRestraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailBackgroundImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var huntIDButton: UIButton!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var readAllReviewsButton: UIButton!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var numStopsLabel: UILabel!
    @IBOutlet weak var cancelTopRestraint: NSLayoutConstraint!
    @IBOutlet weak var letsGoButton: UIImageView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let hunt = hunt else { return }
        
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.huntIDButton.titleLabel?.adjustsFontSizeToFitWidth = true
        descriptionTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        descriptionTextView.font = UIFont.systemFont(ofSize: (view.frame.height * 0.225) / 9.5)
        ratingLabel.font = UIFont(name: "System", size: (ratingStackView.frame.height - 10))
        ratingView.starSize = Double(ratingLabel.font.pointSize)
        readAllReviewsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        totalDistanceLabel.font = UIFont(name: "System", size: ratingStackView.frame.height - 10)
        numStopsLabel.font = UIFont(name: "System", size: ratingStackView.frame.height - 10)
        letsGoButton.layer.masksToBounds = true
        letsGoButton.clipsToBounds = true
        letsGoButton.layer.cornerRadius = letsGoButton.frame.width / 8.25
        editButton.title = ""
        
        if Auth.auth().currentUser?.uid == hunt.creatorID {
            editButton.isEnabled = true
            editButton.title = "Edit"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBarHeight = self.navigationController?.navigationBar.frame.height else { return }
        gameModeViewTopRestraint.constant = -(navBarHeight)
        cancelTopRestraint.constant = navBarHeight
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let currentLocation = LocationManager.shared.currentLocation,
            let hunt = hunt,
            let huntID = hunt.id,
            let startLocation = hunt.startLocation else { return }
        
        titleLabel.text = hunt.title
        huntIDButton.setTitle("Hunt ID: \(huntID)", for: .normal)
        descriptionTextView.text = hunt.description
        totalDistanceLabel.text = "Total Distance: \(Double(round(hunt.distance * 10) / 10)) miles"
        thumbnailBackgroundImageView.image = hunt.thumbnailImage
        
        
        stops?.removeAll()
        let dispatchGroup = DispatchGroup()
        
        var fetchedStops: [Stop] = []
        for stopID in hunt.stopsIDs {
            dispatchGroup.enter()
            StopController.shared.fetchStopWithID(stopID) { (didFetch) in
                if didFetch {
                    guard let stop = StopController.shared.fetchedStop else { return }
                    fetchedStops.append(stop)
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.stops = fetchedStops
            guard let endLocation = self.stops?.last?.location,
                let stops = self.stops else { return }
            
            self.numStopsLabel.text = "\(stops.count) stops"
            
            self.mapView.centerCoordinate = startLocation.coordinate
            let viewRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(viewRegion, animated: true)
            
            let startAnnotation = MKPointAnnotation()
            startAnnotation.title = "Start"
            startAnnotation.coordinate = startLocation.coordinate
            self.mapView.addAnnotation(startAnnotation)
            
            let endAnnotation = MKPointAnnotation()
            endAnnotation.title = "Finish"
            endAnnotation.coordinate = endLocation.coordinate
            self.mapView.addAnnotation(endAnnotation)
            
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    // MARK: - IBactions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        //Segue to editVC
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toEditVC", sender: nil)
        }
    }
    
    @IBAction func huntIDButtonTapped(_ sender: Any) {
        guard let hunt = hunt, let huntID = hunt.id else { return }
        let activityVC = UIActivityViewController(activityItems: ["Come check out out this scavenger hunt on U-Hunt! Use this ID to find it once you download the app: \n \(huntID) \n https://itunes.apple.com/us/app/u-hunt/id1460180195?ls=1&mt=8"], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityVC, animated: true)
        }
    }
    
    @IBAction func letsGoButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationController?.navigationBar.layer.zPosition = -1
                self.navigationController?.navigationBar.alpha = 0
                self.gameModeView.alpha = 1
            })
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationController?.navigationBar.layer.zPosition = 0
                self.navigationController?.navigationBar.alpha = 1
                self.gameModeView.alpha = 0
            })
        }
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        self.navigationController?.navigationBar.layer.zPosition = 0
        self.navigationController?.navigationBar.alpha = 1
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStartVC" {
            guard let destinationVC = segue.destination as? HuntStartViewController,
                let hunt = hunt,
                let stops = stops else { return }
            destinationVC.hunt = hunt
            destinationVC.stops = stops
        }
        
        if segue.identifier == "toEditVC" {
            guard let destinationVC = segue.destination as? Page1CreateViewController,
                let hunt = hunt,
                let stops = stops else { return }
            destinationVC.hunt = hunt
            StopController.shared.stops = stops
        }
    }

}
extension HuntDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView()
        view.markerTintColor = #colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 0)
        view.image = #imageLiteral(resourceName: "marker")
        view.glyphImage = #imageLiteral(resourceName: "transparent")
        view.selectedGlyphImage = #imageLiteral(resourceName: "line")
        view.isEnabled = true
        view.titleVisibility = .visible
        view.displayPriority = .required
        view.canShowCallout = true
        
        view.image = #imageLiteral(resourceName: "marker")
        return view
    }
}
