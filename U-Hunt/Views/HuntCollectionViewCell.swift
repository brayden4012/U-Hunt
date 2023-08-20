//
//  HuntCollectionViewCell.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/16/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

protocol HuntCollectionViewCellDelegate: class {
    func delete(hunt: Hunt)
}

class HuntCollectionViewCell: UICollectionViewCell {
    
    var hunt: Hunt? {
        didSet {
           updateViews()
        }
    }
    
    var menuOpen = false
    
    weak var delegate: HuntCollectionViewCellDelegate?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonHeightConstraint: NSLayoutConstraint!
    
    func updateViews() {
        guard let hunt = hunt else { return }
        
        thumbnailImageView.image = hunt.thumbnailImage
        titleLabel.text = hunt.title
        deleteButton.layer.setValue(hunt, forKey: "hunt")
    }
    
    @IBAction func optionsButtonTapped(_ sender: Any) {
        if menuOpen {
            deleteButtonHeightConstraint.constant = 0
            deleteButton.setTitle("", for: .normal)
            menuOpen = false
        } else {
            deleteButtonHeightConstraint.constant = 20
            deleteButton.setTitle("Delete Hunt", for: .normal)
            menuOpen = true
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let hunt = hunt else { return }
        
        delegate?.delete(hunt: hunt)
    }
}
