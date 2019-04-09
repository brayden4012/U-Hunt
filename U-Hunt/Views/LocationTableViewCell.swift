//
//  LocationTableViewCell.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/5/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    var locationTitle: String? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var locationButton: UIButton!
    
    func updateViews() {
        locationButton.setTitle(locationTitle, for: .normal)
    }

    @IBAction func locationButtonTapped(_ sender: Any) {
        
    }
}
