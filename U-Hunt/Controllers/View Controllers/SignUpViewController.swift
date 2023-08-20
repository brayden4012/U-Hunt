//
//  SignUpViewController.swift
//  U-Hunt
//
//  Created by Brayden Harris on 4/6/19.
//  Copyright © 2019 Brayden Harris. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    let usersRef = Database.database().reference(withPath: "users")
    let usernameRef = Database.database().reference(withPath: "username")

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard let user = user,
                let username = self.usernameTextField.text else { return }
            
            UserController.shared.saveNewUserWith(authData: user, username: username)
            
            self.performSegue(withIdentifier: "toHomeVC", sender: nil)
            self.emailTextField.text = nil
            self.usernameTextField.text = nil
            self.passwordTextField.text = nil
            self.confirmPasswordTextField.text = nil
        }
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your email...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        emailErrorLabel.adjustsFontSizeToFitWidth = true
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Choose a username...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Choose a password...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm password...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailErrorLabel.isHidden = true
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        confirmPasswordErrorLabel.isHidden = true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func emailTextFieldDidEndEditing(_ sender: Any) {
        isValidEmail { (isValid) in
            if !isValid {
                self.emailErrorLabel.isHidden = false
            }
        }
    }
    
    @IBAction func usernameTextFieldDidEndEditing(_ sender: Any) {
        isValidUsername { (isValid) in
            if !isValid {
                self.usernameErrorLabel.isHidden = false
            }
        }
    }
    
    @IBAction func passwordTextFieldDidEndEditing(_ sender: Any) {
        guard let password = passwordTextField.text else { return }
        
        if password.count < 6 {
            passwordErrorLabel.text = "Passwords must be 6 characters or more"
            passwordErrorLabel.isHidden = false
        } else {
            passwordErrorLabel.isHidden = true
        }
    }
    
    @IBAction func confirmPasswordTextFieldDidEndEditing(_ sender: Any) {
        if !passwordsMatch() {
            passwordErrorLabel.isHidden = false
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        attemptSignUp()
    }
    
    func attemptSignUp() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        if !passwordsMatch() {
            passwordErrorLabel.isHidden = false
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil { 
                Auth.auth().signIn(withEmail: email, password: password, completion: nil)
            }
        }
    }
    
    func isValidEmail(completion: @escaping (Bool) -> Void) {
        guard let email = emailTextField.text, !email.isEmpty else { self.emailErrorLabel.text = "Invalid email"; completion(false); return }
        
        // Make sure a valid email has been entered
        guard let atIndex = email.firstIndex(of: "@"),
            atIndex != email.startIndex,
            email[email.index(before: atIndex)].isNumber || email[email.index(before: atIndex)].isLetter,
            email.first!.isNumber || email.first!.isLetter,
            email[email.index(after: atIndex)].isLetter,
            let endDotIndex = email.lastIndex(of: "."),
            let validDomains = ValidDomains.shared.getValidDomains(),
            validDomains.contains(email[email.index(after: endDotIndex)...].uppercased()) else {
                self.emailErrorLabel.text = "Invalid email"
                completion(false)
                return
        }
        
        // Check if the provided email is already a user
        Auth.auth().fetchSignInMethods(forEmail: email) { (emailIDs, error) in
            if let error = error {
                print("Error fetching users from Firebase: \(error), \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let emailIDs = emailIDs, !emailIDs.isEmpty else { self.emailErrorLabel.isHidden = true; completion(true); return }
            
            self.emailErrorLabel.text = "An account for \(email) already exists."
            completion(false)
        }
    }
    
    func isValidUsername(completion: @escaping (Bool) -> Void) {
        guard let username = usernameTextField.text, !username.isEmpty else { self.usernameErrorLabel.text = "Username must be 6 characters or more"; completion(false); return }
        
        usernameRef.queryEqual(toValue: username, childKey: "username").observe(.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.usernameErrorLabel.text = "\(username) already exists"
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func passwordsMatch() -> Bool {
        guard let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else { return false }
        
        if password.lowercased() != confirmPassword.lowercased() {
            confirmPasswordErrorLabel.isHidden = false
            passwordErrorLabel.text = "Passwords don't match"
            return false
        } else {
            passwordErrorLabel.isHidden = true
            confirmPasswordErrorLabel.isHidden = true
            return true
        }
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toLogInVC", sender: nil)
    }
}
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.restorationIdentifier == "ConfirmPasswordTextField" {
            attemptSignUp()
        }
        
        return true
    }
}
