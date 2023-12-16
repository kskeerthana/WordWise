//
//  LoginViewController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 12/10/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePasswordToggle()
    }
    
    func configurePasswordToggle() {
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye"), for: .normal) // Use an eye icon image
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .selected) // Use an eye slash icon image for selected state
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        passwordTxtField.rightView = toggleButton
        passwordTxtField.rightViewMode = .always
        passwordTxtField.isSecureTextEntry = true
    }
    
    @objc func togglePasswordVisibility(sender: UIButton) {
        sender.isSelected = !sender.isSelected // Toggle the selected state
        passwordTxtField.isSecureTextEntry.toggle()
        passwordTxtField.isSecureTextEntry.toggle()
    }
    
    func clearTextFields() {
        emailTxtField.text = ""
        passwordTxtField.text = ""
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

                // Check if the signed-in user is in the admins collection
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let db = Firestore.firestore()
                db.collection("admins").document(uid).getDocument { [weak self] (document, error) in
                    guard let self = self else { return }

                    if let document = document, document.exists {
                        // User is an admin, navigate to Admin Panel
                        self.navigateToAdminPanel()
                    } else {
                        // User is not an admin, proceed with normal user flow
                        self.navigateToUserFlow()
                    }
                }
            }
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.presentAlert(title: "Sign In Failed", message: error.localizedDescription)
//                }
//                return
//            }
//            DispatchQueue.main.async {
//                let alertController = UIAlertController(title: "Success", message: "Sign in successful!", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
//                    guard let self = self else { return }
//                    clearTextFields()
//                    // Assuming 'MainTabBarController' is the identifier of your UITabBarController in the storyboard
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
//                        
//                        // Assuming CameraViewController is at index 0, change it to the correct index if needed
//                        mainTabBarController.selectedIndex = 0
//                        
//                        // Set the UITabBarController as the root view controller
//                        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
//                            sceneDelegate.window?.rootViewController = mainTabBarController
//                            sceneDelegate.window?.makeKeyAndVisible()
//                        }
//                    }
//                }
//                alertController.addAction(okAction)
//                self.present(alertController, animated: true, completion: nil)
//            }
//        }
    }
    
    func navigateToAdminPanel() {
        let adminVC = AdminController()
        adminVC.modalPresentationStyle = .fullScreen
        self.present(adminVC, animated: true, completion: nil)
//        self.present(adminVC, animated: true)
    }

    func navigateToUserFlow() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            mainTabBarController.selectedIndex = 0 // Replace 0 with the index of CameraViewController
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = mainTabBarController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }

    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name
//            if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
//                // Present the sign-up view controller
//                signUpVC.modalPresentationStyle = .fullScreen
//                self.present(signUpVC, animated: true, completion: nil)
//            }
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

}
