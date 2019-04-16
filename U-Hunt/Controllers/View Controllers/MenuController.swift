//
//  MenuController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/3/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import Firebase

class MenuController: UIViewController {
    
    // MARK: - Properties
    var rangeSliderVC: RangeSliderViewController?
    
    // MARK: - IBOutlets
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!
    @IBOutlet weak var mostRecentButton: UIButton!
    @IBOutlet weak var bottomRestraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rangeSliderVC = children.first as? RangeSliderViewController
        
        distanceSlider.setThumbImage(#imageLiteral(resourceName: "circle"), for: .normal)
        distanceSlider.setThumbImage(#imageLiteral(resourceName: "circle"), for: .highlighted)
        
        distanceSlider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        
        distanceButton.isEnabled = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomRestraint.constant = view.safeAreaInsets.bottom + 5
    }
    
    @objc func valueChanged(_ distanceSlider: UISlider) {
        DispatchQueue.main.async {
            if distanceSlider.value == 1 {
                self.distanceLabel.text = "1 mile"
            } else {
                self.distanceLabel.text = "\(Int(distanceSlider.value.rounded(.up))) miles"
            }
        }
        HuntController.shared.distanceFilter = Int(distanceSlider.value.rounded(.up))
    }
    
    // MARK: - IBActions
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        distanceSlider.setValue(30, animated: true)
        distanceLabel.text = "30 miles"
        
        guard let rangeSliderVC = rangeSliderVC else { return }
        rangeSliderVC.clearFilters()
    }
    
    @IBAction func distanceButtonTapped(_ sender: Any) {
        distanceButton.isEnabled = false
        distanceButton.setTitleColor(#colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 1), for: .normal)
        reviewsButton.isEnabled = true
        reviewsButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        mostRecentButton.isEnabled = true
        mostRecentButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        
        // TODO: Sort hunts
    }

    @IBAction func reviewsButtonTapped(_ sender: Any) {
        reviewsButton.isEnabled = false
        reviewsButton.setTitleColor(#colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 1), for: .normal)
        distanceButton.isEnabled = true
        distanceButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        mostRecentButton.isEnabled = true
        mostRecentButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        
        // TODO: Sort hunts
    }

    @IBAction func mostRecentButtonTapped(_ sender: Any) {
        mostRecentButton.isEnabled = false
        mostRecentButton.setTitleColor(#colorLiteral(red: 1, green: 0.7538185716, blue: 0.008911552839, alpha: 1), for: .normal)
        distanceButton.isEnabled = true
        distanceButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        reviewsButton.isEnabled = true
        reviewsButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        
        // TODO: Sort hunts
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let titleScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TitleScreen")
            DispatchQueue.main.async {
                self.present(titleScreen, animated: true)
            }
        } catch (let error) {
            print("Auth sign out failed: \(error)")
        }
    }
}

