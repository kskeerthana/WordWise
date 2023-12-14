//
//  SignUpViewController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 12/13/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class SignUpViewController: UIViewController {
    
    
   
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
        print("")
        guard let email = emailTextField.text, !email.isEmpty,
              let fullName = fullNameTextField.text, !fullName.isEmpty,
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
            if let user = authResult?.user {
                let db = Firestore.firestore()
                let usersRef = db.collection("users")
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "fullName" : fullName,
                    "lastSignIn": Timestamp(date: Date()) // You can add additional user details here
                ]
                
                usersRef.document(user.uid).setData(userData, merge: true) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                        // Handle the error
                    } else {
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
            }
        }
//        guard let email = emailTextField.text, !email.isEmpty,
//              let fullName = fullNameTextField.text, !fullName.isEmpty,
//                  let password = passwordTextField.text, !password.isEmpty else {
//                presentAlert(title: "Missing Information", message: "Please enter both email and password.")
//                return
//            }
//            // Sign in with Firebase
//            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
//                guard let self = self else { return }
//
//                if let error = error {
//                    DispatchQueue.main.async {
//                        self.presentAlert(title: "Sign In Failed", message: error.localizedDescription)
//                    }
//                    return
//                }
//
//                // Save user details to Firestore (excluding password)
//                if let user = authResult?.user {
//                    let db = Firestore.firestore()
//                    let usersRef = db.collection("users")
//                    let userData: [String: Any] = [
//                        "uid": user.uid,
//                        "email": user.email ?? "",
//                        "fullName" : fullName,
//                        "lastSignIn": Timestamp(date: Date()) // You can add additional user details here
//                    ]
//
//                    usersRef.document(user.uid).setData(userData, merge: true) { error in
//                        if let error = error {
//                            print("Error writing document: \(error)")
//                            // Handle the error
//                        } else {
//                            DispatchQueue.main.async {
//                                // Present the success alert and navigate
//                                let alertController = UIAlertController(title: "Success", message: "Sign In successful!", preferredStyle: .alert)
//                                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
//                                    self.dismiss(animated: true) {
//                                        if let tabBarVC = self.view.window?.rootViewController as? UITabBarController {
//                                            tabBarVC.selectedIndex = 0 // Replace 0 with the actual index of CameraViewController
//                                        }
//                                    }
//                                }
//                                alertController.addAction(okAction)
//                                self.present(alertController, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                }
//            }
    }
    
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}

