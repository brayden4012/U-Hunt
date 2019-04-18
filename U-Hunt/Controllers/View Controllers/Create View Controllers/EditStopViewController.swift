//
//  EditStopViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/12/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit

class EditStopViewController: UIViewController {

    // MARK: - Properties
    var stop: Stop? {
        didSet {
            self.view.layoutIfNeeded()
            updateViews()
        }
    }
    var indexOfStop: Int?
    var keyboardHeight: CGFloat?
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet weak var hintCharCountLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var infoCharCountLabel: UILabel!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        nameTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        questionTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        answerTextField.layer.borderColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        
        nameTextField.adjustsFontSizeToFitWidth = true
        questionTextField.adjustsFontSizeToFitWidth = true
        answerTextField.adjustsFontSizeToFitWidth = true
        
        let fontSize = self.hintTextView.frame.height / 8
        hintTextView.font = UIFont.systemFont(ofSize: fontSize)
        infoTextView.font = UIFont.systemFont(ofSize: fontSize)
        
        // Observe for keyboard to show
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
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
    
    func updateViews() {
        guard let stop = stop else { return }
        nameTextField.text = stop.name
        nameTextField.layer.borderWidth = 0
        
        hintTextView.text = stop.instructions
        hintCharCountLabel.text = "\(hintTextView.text.count) / 250"
        hintCharCountLabel.textColor = .white
        
        infoTextView.text = stop.info
        infoCharCountLabel.text = "\(infoTextView.text.count) / 250"
        infoCharCountLabel.textColor = .white
        
        questionTextField.text = stop.questionAndAnswer?[0]
        questionTextField.layer.borderWidth = 0
        
        if stop.questionAndAnswer != nil {
            answerLabel.isHidden = false
            answerTextField.isHidden = false
            answerTextField.text = stop.questionAndAnswer?[1]
            answerTextField.layer.borderWidth = 0
        } else {
            answerLabel.isHidden = true
            answerTextField.isHidden = true
        }
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let stop = stop,
            let index = indexOfStop,
            let name = nameTextField.text,
            let instructions = hintTextView.text,
            let info = infoTextView.text,
            let question = questionTextField.text else { return }
        
        if name.isEmpty {
            nameTextField.layer.borderWidth = 2
            return
        } else {
            StopController.shared.modify(stop: stop, location: nil, name: name, instructions: nil, info: nil, questionAndAnswer: nil, atIndex: index)
        }
        
        if !instructions.isEmpty {
            StopController.shared.modify(stop: stop, location: nil, name: nil, instructions: instructions, info: nil, questionAndAnswer: nil, atIndex: index)
        }
        
        if !info.isEmpty {
            StopController.shared.modify(stop: stop, location: nil, name: nil, instructions: nil, info: info, questionAndAnswer: nil, atIndex: index)
        }
        
        if !question.isEmpty {
            guard let answer = answerTextField.text, !answer.isEmpty else { answerTextField.layer.borderWidth = 2; return }
            
            StopController.shared.modify(stop: stop, location: nil, name: nil, instructions: nil, info: nil, questionAndAnswer: [question, answer], atIndex: index)
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func questionTextFieldDidEndEditing(_ sender: Any) {
        guard let question = questionTextField.text else { return }
        if !question.isEmpty {
            answerLabel.isHidden = false
            answerTextField.text = ""
            answerTextField.isHidden = false
        } else {
            answerLabel.isHidden = true
            answerTextField.isHidden = true
        }
    }
}

extension EditStopViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        if numberOfChars <= 500 {
            if textView.restorationIdentifier == "hintTextView" {
                hintCharCountLabel.textColor = .white
                hintCharCountLabel.text = "\(numberOfChars) / 500"
            } else {
                infoCharCountLabel.textColor = .white
                infoCharCountLabel.text = "\(numberOfChars) / 500"
            }
            return true
        } else {
            if textView.restorationIdentifier == "hintTextView" {
                hintCharCountLabel.textColor = .red
            } else {
                infoCharCountLabel.textColor = .red
            }
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
extension EditStopViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
