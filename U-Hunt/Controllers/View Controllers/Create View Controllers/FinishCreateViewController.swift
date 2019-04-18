//
//  FinishCreateViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/12/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class FinishCreateViewController: UIViewController {

    // MARK: - Properties
    var hunt: Hunt? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var huntIDButton: UIButton!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        huntIDButton.layer.cornerRadius = 10
    }
    
    // MARK: - IBActions
    @IBAction func huntIDButtonTapped(_ sender: Any) {
        guard let hunt = hunt, let huntID = hunt.id else { return }
        let activityVC = UIActivityViewController(activityItems: ["Come check out out the scavenger hunt I just created with U-Hunt! Use this ID to find it once you download the app: \n \(huntID)"], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityVC, animated: true)
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func updateViews() {
        guard let hunt = hunt,
            let huntID = hunt.id else { return }
        
        DispatchQueue.main.async {
            self.huntIDButton.setTitle(huntID, for: .normal)
        }
    }
}
