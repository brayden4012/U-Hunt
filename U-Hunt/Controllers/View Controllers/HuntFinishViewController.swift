//
//  HuntFinishViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/16/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class HuntFinishViewController: UIViewController {

    // MARK: - Properties
    var hunt: Hunt?
    
    // MARK: - IBOutlets
    @IBOutlet weak var CongratulationsLabel: UILabel!
    @IBOutlet weak var YouHaveFinishedLabel: UILabel!
    @IBOutlet weak var DidYouEnjoyLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var idButton: UIButton!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        CongratulationsLabel.adjustsFontSizeToFitWidth = true
        YouHaveFinishedLabel.adjustsFontSizeToFitWidth = true
        DidYouEnjoyLabel.adjustsFontSizeToFitWidth = true
        shareLabel.adjustsFontSizeToFitWidth = true
        idButton.setTitle(hunt?.id, for: .normal)
    }

    // MARK: - IBActions
    @IBAction func idButtonTapped(_ sender: Any) {
        guard let hunt = hunt, let huntID = hunt.id else { return }
        let activityVC = UIActivityViewController(activityItems: ["Come check out out the scavenger hunt I just completed with U-Hunt! Use this ID to find it once you download the app: \n \(huntID) \n https://itunes.apple.com/us/app/u-hunt/id1460180195?ls=1&mt=8"], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityVC, animated: true)
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        LocationManager.shared.isInAHunt = false
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
