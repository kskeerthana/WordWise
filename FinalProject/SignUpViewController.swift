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
    @IBOutlet weak var isAdminCheckbox: UILabel!
    @IBOutlet weak var isAdminSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePasswordToggle()
    }
    
    func configurePasswordToggle() {
        // Configure the toggle button for passwordTextField
        let passwordToggleButton = createToggleButton()
        passwordTextField.rightView = passwordToggleButton
        passwordTextField.rightViewMode = .always

        // Configure the toggle button for confirmPasswordTextField
        let confirmPasswordToggleButton = createToggleButton()
        confirmPasswordTextField.rightView = confirmPasswordToggleButton
        confirmPasswordTextField.rightViewMode = .always

        // Set the text fields to secure text entry by default
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }

    func createToggleButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return button
    }

    @objc func togglePasswordVisibility(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        // Identify which text field's visibility should be toggled
        if let textField = sender.superview as? UITextField {
            textField.isSecureTextEntry.toggle()
        }
    }

    
    func clearTextFields() {
        emailTextField.text = ""
        fullNameTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
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
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "fullName": fullName,
                    "lastSignIn": Timestamp(date: Date()),
                    "isAdmin": self.isAdminSwitch.isOn // Add isAdmin flag
                ]
                
                db.collection("users").document(user.uid).setData(userData, merge: true) { error in
                    if let error = error {
                        print("Error writing document in users collection: \(error)")
                        // Handle the error appropriately
                    } else {
                        // Handle successful registration
                        if self.isAdminSwitch.isOn {
                            db.collection("admins").document(user.uid).setData(userData) { error in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        self.presentAlert(title: "Admin Registration Error", message: error.localizedDescription)
                                    } else {
                                        self.presentSignupSuccessAlert(isAdmin: true)
                                        self.clearTextFields()
                                    }
                                }
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                self.presentSignupSuccessAlert(isAdmin: false)
                            }
                        }
                        
                    }
                }}}}
            
            func presentSignupSuccessAlert(isAdmin: Bool) {
                let message = isAdmin ? "Admin signup successful!" : "Signup successful!"
                let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.clearTextFields()
                    self.navigateAfterSignup(isAdmin: isAdmin)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }

            func navigateAfterSignup(isAdmin: Bool) {
                if isAdmin {
                    let adminVC = AdminController() // Replace with actual instantiation
                    adminVC.modalPresentationStyle = .fullScreen
                    self.present(adminVC, animated: true, completion: nil)
                } else {
                    let cameraVC = CameraViewController() // Replace with actual instantiation
                    cameraVC.modalPresentationStyle = .fullScreen
                    self.present(cameraVC, animated: true, completion: nil)
                }
            }
    @IBAction func signUp2Tapped(_ sender: UIButton) {
//        guard let email = emailTextField.text, !email.isEmpty,
//              let fullName = fullNameTextField.text, !fullName.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty,
//              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
//              password == confirmPassword else {
//            presentAlert(title: "Invalid Input", message: "Please check your information and try again.")
//            return
//        }
//        // Create a new user with Firebase
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.presentAlert(title: "Signup Failed", message: error.localizedDescription)
//                }
//                return
//            }
//            if let user = authResult?.user {
//                let db = Firestore.firestore()
//                let usersRef = db.collection("users")
//                let userData: [String: Any] = [
//                    "uid": user.uid,
//                    "email": user.email ?? "",
//                    "fullName" : fullName,
//                    "lastSignIn": Timestamp(date: Date()) // You can add additional user details here
//                ]
//                
//                usersRef.document(user.uid).setData(userData, merge: true) { error in
//                    if let error = error {
//                        print("Error writing document: \(error)")
//                        // Handle the error
//                    } else {
//                        DispatchQueue.main.async {
//                            let alertController = UIAlertController(title: "Success", message: "Signup successful!", preferredStyle: .alert)
//                            let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
//                                guard let self = self else { return }
//                                self.clearTextFields()
//                                // Assuming 'MainTabBarController' is the identifier of your UITabBarController in the storyboard
//                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
//                                    
//                                    // Assuming CameraViewController is at index 0, change it to the correct index if needed
//                                    mainTabBarController.selectedIndex = 0
//                                    
//                                    // Set the UITabBarController as the root view controller
//                                    if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
//                                                    sceneDelegate.window?.rootViewController = mainTabBarController
//                                                    sceneDelegate.window?.makeKeyAndVisible()
//                                                }
//                                }
//                            }
//                            alertController.addAction(okAction)
//                            self.present(alertController, animated: true, completion: nil)
//                        }
//                        
//                    }
//                }
//            }
//        }
        
        
//        guard let email = emailTextField.text, !email.isEmpty,
//                  let fullName = fullNameTextField.text, !fullName.isEmpty,
//                  let password = passwordTextField.text, !password.isEmpty,
//                  let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
//                  password == confirmPassword else {
//                presentAlert(title: "Invalid Input", message: "Please check your information and try again.")
//                return
//            }
//
//            // Create a new user with Firebase Authentication
//            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
//                guard let self = self else { return }
//
//                // Handle any errors during user creation
//                if let error = error {
//                    DispatchQueue.main.async {
//                        self.presentAlert(title: "Signup Failed", message: error.localizedDescription)
//                    }
//                    return
//                }
//
//                // Add user data to Firestore's 'users' collection
//                if let user = authResult?.user {
//                    let db = Firestore.firestore()
//                    let userData: [String: Any] = [
//                        "uid": user.uid,
//                        "email": user.email ?? "",
//                        "fullName": fullName,
//                        "lastSignIn": Timestamp(date: Date())
//                    ]
//
//                    db.collection("users").document(user.uid).setData(userData, merge: true) { error in
//                        if let error = error {
//                            print("Error writing document in users collection: \(error)")
//                            // Handle the error appropriately
//                        } else {
//                            // Check if isAdminCheckbox is selected
//                            if self.isAdminCheckbox.isSelected {
//                                // Add this user to the 'admins' collection
//                                db.collection("admins").document(user.uid).setData(userData) { error in
//                                    if let error = error {
//                                        print("Error writing document in admins collection: \(error)")
//                                        // Handle the error appropriately
//                                    } else {
//                                        print("User added to admins collection successfully")
//                                        // Perform any additional actions needed for admin users
//                                    }
//                                }
//                            }
//
//                            // Handle successful registration
//                            DispatchQueue.main.async {
//                                // Show success alert, navigate to the next screen, or perform other UI updates
//                                let alertController = UIAlertController(title: "Success", message: "Signup successful!", preferredStyle: .alert)
//                                let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
//                                    guard let self = self else { return }
//                                    self.clearTextFields()
//                                    // Assuming 'MainTabBarController' is the identifier of your UITabBarController in the storyboard
//                                    if self.isAdminCheckbox.isSelected {
//                                        // Navigate to AdminController
//                                        let adminVC = AdminController() // Replace with actual instantiation
//                                        adminVC.modalPresentationStyle = .fullScreen
//                                        self.present(adminVC, animated: true, completion: nil)}
//                                    else{
//                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                        if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
//                                            
//                                            // Assuming CameraViewController is at index 0, change it to the correct index if needed
//                                            mainTabBarController.selectedIndex = 0
//                                            
//                                            // Set the UITabBarController as the root view controller
//                                            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
//                                                sceneDelegate.window?.rootViewController = mainTabBarController
//                                                sceneDelegate.window?.makeKeyAndVisible()
//                                            }
//                                        }
//                                    }
//                                }
//                                alertController.addAction(okAction)
//                                self.present(alertController, animated: true, completion: nil)
//                            }
//                                // Optionally navigate to another view controller or reset the form
//                                self.clearTextFields()
//                            }
//                        }
//                    }
//                }
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}

