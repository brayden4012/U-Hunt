//
//  StopTableViewCell.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/11/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

protocol StopTableViewCellDelegate: class {
    func editButtonTapped(stop: Stop, stopIndex: Int)
}

class StopTableViewCell: UITableViewCell {

    // MARK: - Properties
    var stop: Stop? {
        didSet {
            updateViews()
        }
    }
    var stopIndex: Int?
    weak var delegate: StopTableViewCellDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!

    // MARK: - IBActions
    @IBAction func editButtonTapped(_ sender: Any) {
        guard let stop = stop,
            let index = stopIndex else { return }
        
        delegate?.editButtonTapped(stop: stop, stopIndex: index)
    }

    func updateViews() {
        DispatchQueue.main.async {
            self.nameLabel.text = self.stop?.name
        }
    }
}
