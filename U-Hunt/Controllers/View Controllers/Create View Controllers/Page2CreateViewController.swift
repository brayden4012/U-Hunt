//
//  Page2CreateViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/5/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class Page2CreateViewController: UIViewController {

    @IBOutlet weak var anyoneButton: UIImageView!
    @IBOutlet weak var linkButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        anyoneButton.layoutIfNeeded()
        linkButton.layoutIfNeeded()
        anyoneButton.layer.masksToBounds = true
        linkButton.layer.masksToBounds = true
        
        anyoneButton.layer.cornerRadius = anyoneButton.frame.width / 14
        linkButton.layer.cornerRadius = linkButton.frame.width / 14
    }
    
    @IBAction func anyoneButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
