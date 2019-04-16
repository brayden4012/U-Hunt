//
//  HomeController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/3/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class HomeController: UIViewController {
    
    //  MARK: - Properties
    var menuOpen = false
    var height: CGFloat?
    let blackView = UIView()
    let locationManager = CLLocationManager()
    var currentUser: User?
    var distanceFilter = 30
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var huntListTableView: UITableView!
    
    // MARK: - Life Cycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupRefreshControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if distanceFilter != HuntController.shared.distanceFilter {
            distanceFilter = HuntController.shared.distanceFilter
            setupRefreshControl()
            refreshHunts()
        } else if HuntController.shared.newHuntCreated {
            refreshHunts()
            HuntController.shared.newHuntCreated = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        
        if let window = UIApplication.shared.keyWindow {
            height = view.frame.height
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            view.addSubview(blackView)
            blackView.frame = CGRect(x: 0, y: self.searchBar.frame.origin.x, width: window.frame.width, height: height!)
            blackView.alpha = 0
            view.bringSubviewToFront(menuContainerView)
        }
        
    }
    
    // MARK: - IBActions    
    @IBAction func menuButtonTapped(_ sender: Any) {
        if menuOpen {
            closeMenu()
        } else {
            openMenu()
        }
    }
    
    @objc func handleDismiss() {
        closeMenu()
    }
    
    @IBAction func mapButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func openMenu() {
        guard let height = height else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 1
            self.menuContainerView.frame = CGRect(x: 0, y: self.searchBar.frame.origin.x, width: 200, height: height)
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            
        }, completion: nil)
            
        self.menuOpen = true
    }
    
    func closeMenu() {
        guard let height = height else { return }

        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.menuContainerView.frame = CGRect(x: -200, y: self.searchBar.frame.origin.x, width: 200, height: height)
        }
        
        if distanceFilter != HuntController.shared.distanceFilter {
            distanceFilter = HuntController.shared.distanceFilter
            refreshHunts()
        }
        
        self.menuOpen = false
    }
    
    func setupRefreshControl() {
        huntListTableView.layoutIfNeeded()
        huntListTableView.refreshControl = UIRefreshControl()
        huntListTableView.refreshControl?.tintColor = #colorLiteral(red: 0.9991734624, green: 0.754496038, blue: 0.008968658745, alpha: 1)
        huntListTableView.refreshControl?.attributedTitle = NSAttributedString(string: "Loading local hunts", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 93, green: 188, blue: 210, alpha: 1.0)])
        
        huntListTableView.refreshControl?.addTarget(self, action: #selector(refreshHunts), for: .valueChanged)
    }
    
    @objc func refreshHunts() {
        huntListTableView.refreshControl?.beginRefreshing()
        HuntController.shared.fetchpublicHuntsWithinDistanceInMiles(HuntController.shared.distanceFilter) { (didFetch) in
            if didFetch {
                DispatchQueue.main.async {
                    self.huntListTableView.reloadData()
                    self.huntListTableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            guard let destinationVC = segue.destination as? HuntDetailViewController,
                let indexToSend = huntListTableView.indexPathForSelectedRow?.row else { return }
            
            destinationVC.hunt = HuntController.shared.localHunts[indexToSend]
        }
    }
}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if HuntController.shared.localHunts.isEmpty {
            return 1
        } else {
            return HuntController.shared.localHunts.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if HuntController.shared.localHunts.isEmpty {
            let cell = UITableViewCell()
            
            cell.backgroundColor = .clear
            
            if distanceFilter == 0 {
                cell.textLabel?.text = "No local hunts within \(HuntController.shared.distanceFilter) mile"
                cell.textLabel?.textColor = .white
                cell.selectionStyle = .none

            } else {
                cell.textLabel?.text = "No local hunts within \(HuntController.shared.distanceFilter) miles"
                cell.textLabel?.textColor = .white
                cell.selectionStyle = .none
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "huntCell", for: indexPath) as? HuntTableViewCell
            
            cell?.hunt = HuntController.shared.localHunts[indexPath.row]
            
            return cell ?? UITableViewCell()
        }
    }
}
extension HomeController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        HuntController.shared.fetchHuntWithID(searchText) { (didFetch) in
            if didFetch {
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                    self.huntListTableView.reloadData()
                }
            }
        }
    }
}
