//
//  rangeSliderViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/3/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class RangeSliderViewController: UIViewController {
    
    // MARK: Properties
    let rangeSlider = RangeSlider(frame: .zero)
    
    // MARK: - IBOutlets
    @IBOutlet weak var ratingLabel: UILabel!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(rangeSlider)
        
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)),
                              for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 15
        let width = view.bounds.width - 2 * margin
        let height: CGFloat = 30
        
        rangeSlider.frame = CGRect(x: 0, y: 0,
                                   width: width, height: height)
        rangeSlider.center = view.center
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        DispatchQueue.main.async {
            if (rangeSlider.lowerValue * 5).rounded(.up) == (rangeSlider.upperValue * 5).rounded(.up) {
                if (rangeSlider.lowerValue * 5).rounded(.up) == 1 {
                    self.ratingLabel.text = "1 star"
                } else {
                    self.ratingLabel.text = "\(Int((rangeSlider.lowerValue * 5).rounded(.up))) stars"
                }
            } else {
                self.ratingLabel.text = "\(Int((rangeSlider.lowerValue * 5).rounded(.up))) to \(Int((rangeSlider.upperValue * 5).rounded(.up))) stars"
            }
        }
        // TODO: update table view to reflect the filter
    }
    
    func clearFilters() {
        DispatchQueue.main.async {
            self.ratingLabel.text = "1 to 5 stars"
            self.rangeSlider.lowerValue = 0.05
            self.rangeSlider.upperValue = 0.95
        }
    }
}


