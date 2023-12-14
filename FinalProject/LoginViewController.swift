//
//  LoginViewController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 12/10/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        guard let email = emailTxtField.text, !email.isEmpty,
              let password = passwordTxtField.text, !password.isEmpty else {
            presentAlert(title: "Missing Information", message: "Please enter both email and password.")
            return
        }
        // Sign in with Firebase
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.presentAlert(title: "Sign In Failed", message: error.localizedDescription)
                }
                return
            }

            DispatchQueue.main.async {
                // Success Alert
                let alertController = UIAlertController(title: "Success", message: "Sign In successful!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    // Navigate to the CameraViewController tab
                    self.dismiss(animated: true)
                    if let tabBarVC = self.view.window?.rootViewController as? UITabBarController {
                        tabBarVC.selectedIndex = 0 // Replace 0 with the actual index of CameraViewController
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

}
