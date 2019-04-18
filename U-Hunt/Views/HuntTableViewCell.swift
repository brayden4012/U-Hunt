//
//  HuntTableViewCell.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/4/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class HuntTableViewCell: UITableViewCell {

    // MARK: - Propterties
    var hunt: Hunt? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func updateViews() {
        guard let hunt = hunt,
            let startLocation = hunt.startLocation,
            let distanceInMeters = LocationManager.shared.currentLocation?.distance(from: startLocation) else { return }

        let distanceInMiles = Double(distanceInMeters) / 1609.34
        
        thumbnailImageView.image = hunt.thumbnailImage
        titleLabel.text = hunt.title
        descriptionLabel.text = hunt.description
        distanceLabel.text = "\(Int(distanceInMiles)) miles away"
    }

}
