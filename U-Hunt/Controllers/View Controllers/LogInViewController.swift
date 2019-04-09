//
//  LogInViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/6/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your email...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter your password...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        attemptSignIn()
    }
    
    func attemptSignIn() {
        guard let email = emailTextField.text,
        let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
        if let error = error, user == nil {
            let alert = UIAlertController(title: "Sign In Failed",
            message: error.localizedDescription,
            preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        guard let _ = user else { return }
        
        self.performSegue(withIdentifier: "toHomeVC", sender: nil)
        }
    }
}
extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.restorationIdentifier == "PasswordTextField" {
            attemptSignIn()
        }
        
        return true
    }
}
