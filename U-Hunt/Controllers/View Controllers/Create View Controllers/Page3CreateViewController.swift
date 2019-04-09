//
//  Page3CreateViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/5/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class Page3CreateViewController: UIViewController {

    @IBOutlet weak var stopsTableView: UITableView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopsTableView.isEditing = true
        instructionsLabel.adjustsFontSizeToFitWidth = true
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
extension Page3CreateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch HuntController.shared.stops.count {
        case 0...2:
            return 3
        default:
            return HuntController.shared.stops.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Switch the locations
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as? LocationTableViewCell
        
        cell?.locationTitle = "Start"
        
        return cell ?? UITableViewCell()
    }
    
    
}
