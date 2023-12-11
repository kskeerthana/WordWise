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
        print("")
        guard let email = emailTextField.text, !email.isEmpty,
              let fullName = fullNameTextFielf.text, !fullName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
              password == confirmPassword else {
            presentAlert(title: "Invalid Input", message: "Please check your information and try again.")
            return
        }
        // Create a new user with Firebase
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.presentAlert(title: "Signup Failed", message: error.localizedDescription)
                }
                return
            }
            
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Success", message: "Signup successful!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    // Navigate to the CameraViewController tab
                    if let tabBarVC = self.view.window?.rootViewController as? UITabBarController {
                        tabBarVC.selectedIndex = 0 // Replace 0 with the actual index of CameraViewController
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
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
