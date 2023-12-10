//
//  SignUpViewController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 12/10/23.
//

import UIKit
import FirebaseAuth
class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var fullNameTextFielf: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let fullName = fullNameTextFielf.text, !fullName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
              password == confirmPassword else {
            presentAlert(title: "Invalid Input", message: "Please check your information and try again.")
            return
        }
        // Create a new user with Firebase
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.presentAlert(title: "Signup Failed", message: error.localizedDescription)
                return
            }
            // You may want to add the user's full name to their profile, or save it to your database
            // Navigate to the main interface
        }
    }
    @IBAction func signInTapped(_ sender: Any) {
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}
