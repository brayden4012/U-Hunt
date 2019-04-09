//
//  HuntDetailViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/4/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import MapKit

class HuntDetailViewController: UIViewController {
    
    @IBOutlet weak var gameModeContainerView: UIView!
    @IBOutlet weak var thumbnailBackgroundImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var readAllReviewsButton: UIButton!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var numStopsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    func updateViews() {
        self.titleLabel.adjustsFontSizeToFitWidth = true
        descriptionTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        ratingLabel.font = UIFont(name: "System", size: (ratingStackView.frame.height - 10))
        ratingView.starSize = Double(ratingLabel.font.pointSize)
        readAllReviewsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        totalDistanceLabel.font = UIFont(name: "System", size: ratingStackView.frame.height - 10)
        numStopsLabel.font = UIFont(name: "System", size: ratingStackView.frame.height - 10)
        
        guard let currentLocation = LocationManager.shared.currentLocation else { return }
        mapView.centerCoordinate = currentLocation.coordinate
        let viewRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(viewRegion, animated: true)
        mapView.isZoomEnabled = false
        
        let annotation = MKPointAnnotation()
        annotation.title = "Start"
        annotation.coordinate = currentLocation.coordinate
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func letsGoButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.bringSubviewToFront(self.gameModeContainerView)
            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension HuntDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        view.canShowCallout = true
        
        view.annotation = annotation
        view.image = #imageLiteral(resourceName: "highlightedCircle")
        return view
    }
}
