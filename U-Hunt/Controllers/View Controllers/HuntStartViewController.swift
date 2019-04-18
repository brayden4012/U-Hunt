//
//  HuntStartViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/15/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import MapKit
import NotificationCenter

class HuntStartViewController: UIViewController {
    
    // MARK: - Properties
    var hunt: Hunt?
    var stops: [Stop]? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    var calloutView: CustomCalloutView?
    
    var numQuestions = 0
    var currentStopIndex = 0
    var progress = 0

    // MARK: - IBOutlets
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionViewTopRestraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var incorrectAnswerLabel: UILabel!
    @IBOutlet weak var correctImageView: UIImageView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.instructionsLabel.adjustsFontSizeToFitWidth = true
        LocationManager.shared.isInAHunt = true
        LocationManager.shared.targetLocation = stops?[currentStopIndex].location
        
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        self.calloutView = views?[0] as? CustomCalloutView
        
        updateViews()
        
        guard let stops = stops else { return }
        for stop in stops {
            if stop.questionAndAnswer != nil {
                numQuestions += 1
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        guard let navBarHeight = self.navigationController?.navigationBar.frame.height else { return }
//        questionViewTopRestraint.constant = navBarHeight
    }
    
    @objc func presentLocationInfo() {
        guard let stops = stops,
            let name = stops[currentStopIndex].name else { return }
        
        progress += 1
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = Float(1.0 / Double(stops.count + self.numQuestions)) * Float(self.progress)
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        if let info = stops[currentStopIndex].info {
            instructionsLabel.text = "You have arrived at \(name)! \(info)"
        } 
        
        okButton.isHidden = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("arrived"), object: nil)
    }
    
    func updateViews() {
        guard let currentLocation = LocationManager.shared.currentLocation,
            let stops = stops,
            let stopName = stops[currentStopIndex].name,
            let hunt = hunt else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = Float(1.0 / Double(stops.count + self.numQuestions)) * Float(self.progress)
        }
        
        if currentStopIndex == 0 {
            guard let instructions = stops[currentStopIndex].instructions else { return }
            instructionsLabel.text = "Welcome to \(hunt.title) scavenger hunt! \(instructions)"
        } else {
            instructionsLabel.text = stops[currentStopIndex].instructions
        }
        
        mapView.removeAnnotations(mapView.annotations)
        let viewRegion = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(viewRegion, animated: true)
        
        let startAnnotation = MKPointAnnotation()
        startAnnotation.title = stopName
        startAnnotation.coordinate = stops[currentStopIndex].location.coordinate
        self.mapView.addAnnotation(startAnnotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
        
//        mapView.addSubview(questionView)
        
        LocationManager.shared.targetLocation = stops[currentStopIndex].location
        NotificationCenter.default.addObserver(self, selector: #selector(presentLocationInfo), name: NSNotification.Name("arrived"), object: nil)
    }

    @IBAction func quitButtonTapped(_ sender: Any) {
        LocationManager.shared.isInAHunt = false
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        guard let stops = stops else { return }
        okButton.isHidden = true
        if let questionAndAnswer = stops[currentStopIndex].questionAndAnswer {
            questionLabel.text = questionAndAnswer[0]
            incorrectAnswerLabel.isHidden = true
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.navigationController?.navigationBar.layer.zPosition = -1
                    self.navigationController?.navigationBar.alpha = 0
                    self.questionView.alpha = 1
                    self.view.bringSubviewToFront(self.questionView)
                }
            }
        } else {
            currentStopIndex += 1
            if currentStopIndex == stops.count {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toFinishVC", sender: nil)
                }
            } else {
                updateViews()
            }
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        submitAnswer()
    }
    
    @IBAction func skipQuestionButtonTapped(_ sender: Any) {
        guard let stops = stops else { return }
        currentStopIndex += 1
        progress += 1
        if currentStopIndex == stops.count {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toFinishVC", sender: nil)
            }
        } else {
            updateViews()
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .transitionCrossDissolve, animations: {
                self.questionView.alpha = 0
                self.navigationController?.navigationBar.layer.zPosition = 0
                self.navigationController?.navigationBar.alpha = 1
            }, completion: nil)
        }
    }
    
    func submitAnswer() {
        // Check for correct answer, ignoring punctuation and case
        self.view.endEditing(true)
        
        guard let stops = stops,
            let questionAndAnswer = stops[currentStopIndex].questionAndAnswer,
            let answer = answerTextField.text else { return }
        
        let joinedSets = CharacterSet.punctuationCharacters.intersection(CharacterSet.alphanumerics)
        let correctAnswer = questionAndAnswer[1].lowercased().components(separatedBy: joinedSets).joined()
        let userAnswer = answer.lowercased().components(separatedBy: joinedSets).joined()
        
        if userAnswer == correctAnswer {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: {
                    self.correctImageView.alpha = 1
                })
                
                UIView.animate(withDuration: 0.5, delay: 1.0, options: .transitionCrossDissolve, animations: {
                    self.questionView.alpha = 0
                    self.correctImageView.alpha = 0
                    self.navigationController?.navigationBar.layer.zPosition = 0
                    self.navigationController?.navigationBar.alpha = 1
                }, completion: { (didAnimate) in
                    if didAnimate {
                        self.currentStopIndex += 1
                        self.progress += 1
                        if self.currentStopIndex == stops.count {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "toFinishVC", sender: nil)
                            }
                        } else {
                            self.updateViews()
                        }
                    }
                })
            }
        } else {
            incorrectAnswerLabel.isHidden = false
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFinishVC" {
            guard let hunt = hunt,
                let destinationVC = segue.destination as? HuntFinishViewController else { return }
            
            destinationVC.hunt = hunt
        }
    }

}
extension HuntStartViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title != "My Location" {
            guard let stops = stops else { return nil }
            let view = MKMarkerAnnotationView()
            view.markerTintColor = #colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 0)
            view.image = #imageLiteral(resourceName: "marker")
            view.glyphImage = #imageLiteral(resourceName: "transparent")
            view.selectedGlyphImage = #imageLiteral(resourceName: "line")
            view.isEnabled = true
            view.titleVisibility = .visible
            view.displayPriority = .required
            view.canShowCallout = true
            view.layer.setValue(stops[currentStopIndex].location, forKey: "currentStop")
            
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let calloutView = calloutView,
            let location = view.layer.value(forKey: "currentStop") as? CLLocation else { return }
        calloutView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        calloutView.imageView.image = #imageLiteral(resourceName: "appleMapsIcon")
        
        let button = UIButton(frame: calloutView.frame)
        button.layer.setValue(location, forKey: "currentStop")
        button.addTarget(self, action: #selector(navigate), for: .touchUpInside)
        calloutView.addSubview(button)
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: 70)
        view.addSubview(calloutView)
        mapView.setCenter(view.annotation!.coordinate, animated: true)
    }
    
    @objc func navigate(_ sender: UIButton) {
        guard let location = sender.layer.value(forKey: "currentStop") as? CLLocation,
            let stops = stops else { return }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        let options = [
            MKLaunchOptionsMapCenterKey : NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey : NSValue(mkCoordinateSpan: region.span)
        ]
        
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = stops[currentStopIndex].name
        mapItem.openInMaps(launchOptions: options)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let calloutView = calloutView else { return }
        
        calloutView.removeFromSuperview()
    }
}
extension HuntStartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitAnswer()
        answerTextField.text = ""
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        incorrectAnswerLabel.isHidden = true
    }
}
