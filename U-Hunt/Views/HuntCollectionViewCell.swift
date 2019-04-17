//
//  HuntCollectionViewCell.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/16/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class HuntCollectionViewCell: UICollectionViewCell {
    
    var hunt: Hunt? {
        didSet {
           updateViews()
        }
    }
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func updateViews() {
        guard let hunt = hunt else { return }
        
        thumbnailImageView.image = hunt.thumbnailImage
        titleLabel.text = hunt.title
    }
    
}
