//
//  ProfileViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/16/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {

    // MARK: - Properties
    var myHunts: [Hunt]? {
        didSet {
            DispatchQueue.main.async {
                self.huntsCollectionView.reloadData()
            }
        }
    }
    var user: User?
    
    // MARK: - IBOutlets
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editProfilePicButton: UIButton!
    @IBOutlet weak var huntsCollectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingLabel.text = "Loading your profile..."
        
        profileImageView.layoutIfNeeded()
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
        editProfilePicButton.layoutIfNeeded()
        editProfilePicButton.layer.masksToBounds = true
        editProfilePicButton.layer.cornerRadius = editProfilePicButton.frame.width / 2
        
        fetchCurrentUser { (didFetch) in
            if didFetch {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.loadingView.alpha = 0
                    })
                }
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func changeProfileImageButtonTapped(_ sender: Any) {
        presentImagePickerActionSheet()
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Delete account", message: "Are you sure you want to delete your account? This will also delete any hunts you have created.", preferredStyle: .alert)
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
            self.deleteAccount()
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
        }))
        present(alert, animated: true)
    }

    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        loadingView.alpha = 1.0
        guard let uid = Auth.auth().currentUser?.uid else { completion(false); return }
        
        UserController.shared.fetchUserWithUID(uid) { (user) in
            guard let user = user else { completion(false); return }
            self.profileImageView.image = user.profileImage
            self.usernameLabel.text = "@\(user.username)"
            self.user = user
            
            HuntController.shared.fetchHuntsByUser(userID: uid, completion: { (hunts) in
                self.myHunts = hunts
                completion(true)
            })
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            guard let destinationVC = segue.destination as? HuntDetailViewController,
                let hunts = myHunts,
                let indexPathToSend = huntsCollectionView.indexPathsForSelectedItems?.first else { return }
            
            destinationVC.hunt = hunts[indexPathToSend.row]
        }
    }
}
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 30) / 2, height: (collectionView.frame.width - 30) / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let hunts = myHunts else { return 0 }
        
        return hunts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let hunts = myHunts else { return UICollectionViewCell() }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "huntCell", for: indexPath) as? HuntCollectionViewCell
        
        cell?.hunt = hunts[indexPath.row]
        
        cell?.delegate = self
        
        return cell ?? UICollectionViewCell()
    }
}
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = photo
            guard let user = user else { return }
            UserController.shared.update(user: user, username: nil, profileImage: photo)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func presentImagePickerActionSheet() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Select a Photo", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: 50, y: self.view.frame.height - 100, width: self.view.frame.width - 100, height: 100)
            actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: 50, y: self.view.frame.height - 100, width: self.view.frame.width - 100, height: 100)
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }

    private func deleteAccount() {
        if let myHunts,
           !myHunts.isEmpty {
            loadingLabel.text = "Deleting your hunts..."
            UIView.animate(withDuration: 0.5, animations: {
                self.loadingView.alpha = 1
            }) { _ in
                self.deleteAllHunts(hunts: myHunts) {
                    if let user = self.user {
                        UIView.animate(withDuration: 0.5) {
                            self.loadingLabel.text = "Deleting your account..."
                        } completion: { _ in
                            UserController.shared.delete(user: user) { error, _ in
                                if let error {
                                    print("Error: \(error.localizedDescription)")
                                    return
                                } else {
                                    UserController.shared.delete(user: user) { _, _ in
                                        self.deleteUser()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if let user {
            UIView.animate(withDuration: 0.5, animations: {
                self.loadingView.alpha = 1
            }) { _ in
                self.loadingLabel.text = "Deleting your account..."
                UserController.shared.delete(user: user) { _, _ in
                    self.deleteUser()
                }
            }
        } else {
            self.deleteUser()
        }
    }

    private func deleteAllHunts(hunts: [Hunt], completion: @escaping () -> Void) {
        guard let huntToDelete = hunts.first else {
            completion()
            return
        }

        deleteSingleHunt(huntToDelete) { _ in
            self.myHunts?.removeAll(where: { $0.id == huntToDelete.id })
            self.deleteAllHunts(hunts: self.myHunts ?? [], completion: completion)
        }
    }

    private func deleteUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        self.showFailedToDeleteAlert(title: "Confirm password to delete", message: "", showTextField: true, actionTitle: "Submit") { ac in
            if let email = currentUser.email,
               let password = ac.textFields?.first?.text {
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                currentUser.reauthenticate(with: credential) { result, error in
                    if let error {
                        self.showFailedToDeleteAlert(title: "Error", message: error.localizedDescription, actionTitle: "Try again") { _ in
                            self.deleteUser()
                        }
                    } else if result != nil {
                        currentUser.delete(completion: { error in
                            if let error {
                                self.showFailedToDeleteAlert(title: "Delete Account Failed", message: error.localizedDescription)
                            } else {
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true)
                                }
                            }
                        })
                    }
                }
            }
        }
    }

    private func showFailedToDeleteAlert(title: String, message: String, showTextField: Bool = false, actionTitle: String? = nil, actionHandler: ((UIAlertController) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if showTextField {
            alert.addTextField()
        }
        if let actionTitle {
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
                actionHandler?(alert)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        present(alert, animated: true)
    }
}

extension ProfileViewController: HuntCollectionViewCellDelegate {
    func delete(hunt: Hunt) {
        let huntToDelete = hunt
        
        let alertController = UIAlertController(title: "Delete Hunt?", message: "Are you sure you want to delete this hunt?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteTapped) in
            self.deleteSingleHunt(huntToDelete) { (didDelete) in
                if didDelete {
                    guard let myHunts = self.myHunts else { return }
                    
                    let newHunts = myHunts.filter({ (hunt) -> Bool in
                        return hunt.id != huntToDelete.id
                    })
                    
                    self.myHunts = newHunts
                    
                    DispatchQueue.main.async {
                        self.huntsCollectionView.reloadData()
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func deleteSingleHunt(_ hunt: Hunt, completion: @escaping (Bool) -> Void) {
        HuntController.shared.delete(hunt: hunt, completion: completion)
    }
}
