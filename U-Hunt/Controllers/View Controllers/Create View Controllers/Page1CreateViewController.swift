//
//  Page1CreateViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/5/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class Page1CreateViewController: UIViewController {
    
    // MARK: - Properties
    var keyboardHeight: CGFloat?
    var selectedImage: UIImage?
    var hunt: Hunt?
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionCharCountLabel: UILabel!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editImageButton.layoutIfNeeded()
        editImageButton.layer.masksToBounds = true
        editImageButton.layer.cornerRadius = editImageButton.frame.width / 2
        
        instructionLabel.textColor = .white
        instructionLabel.adjustsFontSizeToFitWidth = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Observe for keyboard to show
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        let fontInt = Int((view.frame.height * 0.14) / 8)
        let fontSize = CGFloat(fontInt)
        descriptionTextView.font = UIFont.systemFont(ofSize: fontSize)
        
        if let hunt = hunt {
            thumbnailImageView.image = hunt.thumbnailImage
            titleTextField.text = hunt.title
            descriptionTextView.text = hunt.description
            descriptionCharCountLabel.text = "\(descriptionTextView.text.count) / 500"
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
        }
    }
    
    // MARK: - IBActions
    @IBAction func nextButtonTapped(_ sender: Any) {
        performSegue()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func editImageButtonTapped(_ sender: Any) {
        presentImagePickerActionSheet()
    }
    
    func performSegue() {
        guard let title = titleTextField.text, !title.isEmpty else { instructionLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1); return }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toPage2", sender: nil)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        if segue.identifier == "toPage2" {
            let destinationVC = segue.destination as? Page2CreateViewController
            destinationVC?.titleLandingPad = title
            if let description = descriptionTextView.text {
                if !description.isEmpty {
                    destinationVC?.descriptionLandingPad = description
                }
            }
            if let thumbnail = selectedImage {
                destinationVC?.thumbnailImage = thumbnail
            }
            
            if let hunt = hunt {
                destinationVC?.hunt = hunt
            }
        }
    }
}
extension Page1CreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegue()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let keyboardHeight = keyboardHeight else { return }
        let viewHeight = view.frame.height
        
        
        let textFieldPosition = textField.frame.origin.y
        
        if textFieldPosition + textField.frame.height + keyboardHeight > viewHeight {
            let amountToOffset = textFieldPosition - ((textFieldPosition + textField.frame.height + keyboardHeight) - viewHeight)
            let offsetPoint = CGPoint(x: 0, y: amountToOffset)
            
            scrollView.setContentOffset(offsetPoint, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.scrollToTop()
    }
}
extension Page1CreateViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        if numberOfChars <= 500 {
            descriptionCharCountLabel.textColor = .white
            descriptionCharCountLabel.text = "\(numberOfChars) / 500"
            
            return true
        } else {
            descriptionCharCountLabel.textColor = .red
            return false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let keyboardHeight = keyboardHeight else { return }
        let viewHeight = view.frame.height
        
        let textViewPosition = textView.frame.origin.y
        
        if textViewPosition + textView.frame.height + keyboardHeight > viewHeight {
            let amountToOffset = textViewPosition - ((textViewPosition + textView.frame.height + keyboardHeight) - viewHeight)
            let offsetPoint = CGPoint(x: 0, y: amountToOffset)
            
            scrollView.setContentOffset(offsetPoint, animated: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.scrollToTop()
    }
}
extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        self.setContentOffset(desiredOffset, animated: true)
    }
}
// MARK: - Image Picker Delegate
extension Page1CreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            thumbnailImageView.image = photo
            selectedImage = photo
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
}
