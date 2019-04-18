//
//  Page2CreateViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/5/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class Page2CreateViewController: UIViewController {

    // MARK: - Properties
    var titleLandingPad: String?
    var descriptionLandingPad: String?
    var thumbnailImage: UIImage?
    var privacy: String?
    
    // MARK: - IBOIutlets
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var anyoneButton: UIImageView!
    @IBOutlet weak var linkButton: UIImageView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        instructionsLabel.textColor = .white
        anyoneButton.layoutIfNeeded()
        linkButton.layoutIfNeeded()
        anyoneButton.layer.masksToBounds = true
        linkButton.layer.masksToBounds = true
        
        anyoneButton.layer.cornerRadius = anyoneButton.frame.width / 14
        linkButton.layer.cornerRadius = linkButton.frame.width / 14
    }
    
    // MARK: - IBActions
    @IBAction func anyoneButtonTapped(_ sender: Any) {
        privacy = "publicHunt"
        anyoneButton.isHighlighted = true
        linkButton.isHighlighted = false
    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        privacy = "privateHunt"
        linkButton.isHighlighted = true
        anyoneButton.isHighlighted = false
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if privacy == nil {
            instructionsLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            return
        }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toPage3", sender: nil)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let title = titleLandingPad,
            let privacy = privacy else { return }
        
        if segue.identifier == "toPage3" {
            let destinationVC = segue.destination as? Page3CreateViewController
            destinationVC?.huntTitle = title
            destinationVC?.privacy = privacy
            if let description = descriptionLandingPad {
                destinationVC?.huntDescription = description
            }
            if let thumbnail = thumbnailImage {
                destinationVC?.thumbnailImage = thumbnail
            }
        }
    }

}
