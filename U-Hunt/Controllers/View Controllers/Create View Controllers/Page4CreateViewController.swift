//
//  Page4CreateViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/11/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import Firebase

class Page4CreateViewController: UIViewController {

    // MARK: - Properties
    var huntTitle: String?
    var huntDescription: String?
    var thumbnailImage: UIImage?
    var privacy: String?
    var stops: [Stop]?
    var huntDistance: Double?
    var hunt: Hunt?
    
    var stopToEdit: Stop?
    var stopIndex: Int?
    
    var newHunt: Hunt?
    
    // MARK: - IBOutlets
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var stopsTableView: UITableView!
    @IBOutlet weak var tableViewHeightRestraint: NSLayoutConstraint!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var createActivityIndicator: UIActivityIndicatorView!
    
    
    // MARK:- Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        instructionsLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard var stops = stops else { return }
        
        stops = StopController.shared.stops
        
        if stops.count < 6 {
            tableViewHeightRestraint.constant = (self.view.frame.height / 12) * CGFloat(stops.count)
        } else {
            tableViewHeightRestraint.constant = (self.view.frame.height / 12) * 5
        }
        
        DispatchQueue.main.async {
            self.stopsTableView.reloadData()
        }
        
        if hunt != nil {
            createButton.setTitle("Save Hunt", for: .normal)
        }
    }
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        guard let stops = stops, stops.count > 1,
            let title = huntTitle,
            let privacy = privacy,
            let creatorID = Auth.auth().currentUser?.uid,
            let distance = huntDistance else { return }
        
        createButton.isEnabled = false
        createButton.setTitle("", for: .normal)
        createActivityIndicator.isHidden = false
        
        var stopIDs: [String] = []
        for stop in stops {
            if let id = stop.id {
                stopIDs.append(id)
            }
        }
        
        if let hunt = hunt {
            HuntController.shared.modify(hunt: hunt, title: title, description: huntDescription, stopsIDs: stopIDs, distance: distance, reviewIDs: nil, avgRating: nil, thumbnailImage: thumbnailImage, privacy: privacy)
            
            for vc in navigationController!.viewControllers {
                if vc.restorationIdentifier == "HuntDetailVC" {
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            }
            
        } else if let thumbnail = thumbnailImage {
            HuntController.shared.saveHuntWith(title: title, description: huntDescription, stopsIDs: stopIDs, distance: distance, reviewIDs: nil, creatorID: creatorID, thumbnailImage: thumbnail, privacy: privacy) { (hunt) in
                
                guard let hunt = hunt else { return }
                self.newHunt = hunt
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toFinishVC", sender: nil)
                }
            }
        } else {
            HuntController.shared.saveHuntWith(title: title, description: huntDescription, stopsIDs: stopIDs, distance: distance, reviewIDs: nil, creatorID: creatorID, privacy: privacy) { (hunt) in
                
                guard let hunt = hunt else { return }
                self.newHunt = hunt
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toFinishVC", sender: nil)
                }
            }
        }
        
        StopController.shared.stops.removeAll()
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditStopVC" {
            guard let destinationVC = segue.destination as? EditStopViewController,
                let stop = stopToEdit,
                let index = stopIndex else { return }
            
            destinationVC.stop = stop
            destinationVC.indexOfStop = index
        }
        
        if segue.identifier == "toFinishVC" {
            guard let destinationVC = segue.destination as? FinishCreateViewController,
                let hunt = newHunt else { return }

            destinationVC.hunt = hunt
        }
    }
    
}
extension Page4CreateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let stops = stops else { return 50 }
        
        return tableView.frame.height / CGFloat(stops.count) + 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopCell", for: indexPath) as? StopTableViewCell
        
        cell?.stop = stops?[indexPath.row]
        cell?.stopIndex = indexPath.row
        
        cell?.delegate = self
        
        return cell ?? UITableViewCell()
    }
    
    
}
extension Page4CreateViewController: StopTableViewCellDelegate {
    func editButtonTapped(stop: Stop, stopIndex: Int) {
        stopToEdit = stop
        self.stopIndex = stopIndex
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toEditStopVC", sender: nil)
        }
    }
}
