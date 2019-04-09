//
//  TitleViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/8/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import Firebase

class TitleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "toHomeVC", sender: nil)
            }
        }
    }
}
