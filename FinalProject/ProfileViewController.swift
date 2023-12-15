//
//  ProfileViewController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 12/14/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let signOutButton = UIButton()
    let deleteAccountButton = UIButton()
    let closeButton = UIButton()
    var userName: String? {
            didSet {
                print("Setting userName: \(userName ?? "nil")")
                nameLabel.text = userName
            }
        }
        var userEmail: String? {
            didSet {
                emailLabel.text = userEmail
            }
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
                
        // Configure UI elements
        setupProfileImageView()
        setupNameLabel(with: userName ?? "No Name")  // userName needs to be defined in this class
        setupEmailLabel(with: userEmail ?? "No Email")  // u
        setupSignOutButton()
        setupDeleteAccountButton()
        setUpcloseButton()
    }
    

    func setupProfileImageView() {
            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.layer.cornerRadius = 40 // Adjust for your desired size
            profileImageView.clipsToBounds = true
            profileImageView.backgroundColor = .gray // Placeholder color
            profileImageView.contentMode = .scaleAspectFill
            // Set an actual image for the profileImageView if you have one
            view.addSubview(profileImageView)
            
            NSLayoutConstraint.activate([
                profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 80), // Diameter of the circular image
                profileImageView.heightAnchor.constraint(equalToConstant: 80)
            ])
        }
        
        func setupNameLabel(with name: String) {
//            nameLabel.translatesAutoresizingMaskIntoConstraints = false
//            nameLabel.text = userName ?? "No Name" // Placeholder text
//            nameLabel.textAlignment = .center
//            view.addSubview(nameLabel)
//            
//            NSLayoutConstraint.activate([
//                nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
//                nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//            ])
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
                nameLabel.text = name
                nameLabel.textAlignment = .center
                view.addSubview(nameLabel)
                
                NSLayoutConstraint.activate([
                    nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
                    nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
        }
        
        func setupEmailLabel(with email: String) {
//            emailLabel.translatesAutoresizingMaskIntoConstraints = false
//            emailLabel.text = userEmail ?? "No Email" // Placeholder text
//            emailLabel.textAlignment = .center
//            view.addSubview(emailLabel)
//            
//            NSLayoutConstraint.activate([
//                emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
//                emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//            ])
            emailLabel.translatesAutoresizingMaskIntoConstraints = false
                emailLabel.text = email
                emailLabel.textAlignment = .center
                view.addSubview(emailLabel)
                
                NSLayoutConstraint.activate([
                    emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
                    emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
        }
        
        func setupSignOutButton() {
            signOutButton.translatesAutoresizingMaskIntoConstraints = false
            signOutButton.setTitle("Sign Out", for: .normal)
            signOutButton.setTitleColor(.red, for: .normal)
            signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
            view.addSubview(signOutButton)
            
            NSLayoutConstraint.activate([
                signOutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
                signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
        
        func setupDeleteAccountButton() {
            deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
            deleteAccountButton.setTitle("Delete Account", for: .normal)
            deleteAccountButton.setTitleColor(.red, for: .normal)
            deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
            view.addSubview(deleteAccountButton)
            
            NSLayoutConstraint.activate([
                deleteAccountButton.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: 10),
                deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
        
    func setUpcloseButton(){
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.blue, for: .normal) // Set the color as needed
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // Add the close button to the view hierarchy
        view.addSubview(closeButton)
        
        // Set constraints or frame
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
    }
        
    @objc func signOutTapped() {
        do {
            try Auth.auth().signOut()
            navigateToSignInScreen()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // Optionally show an error message to the user
        }
    }
    
    func navigateToSignInScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signInVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true, completion: nil)
        }
    }
    
    @objc func deleteAccountTapped() {
        // Handle account deletion logic here
        guard let user = Auth.auth().currentUser else {
                print("No user is currently signed in")
                return
            }
            
        let userId = user.uid
        deleteUserFromFirestore(userId: userId) {
            self.deleteUserFromAuth(user: user as FirebaseAuth.User)
        }
    }
    
    func deleteUserFromFirestore(userId: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).delete() { error in
            if let error = error {
                print("Error removing user document: \(error)")
                // Handle the error appropriately
            } else {
                print("User document successfully removed")
                completion()
            }
        }
    }

    func deleteUserFromAuth(user: FirebaseAuth.User) {
        user.delete { error in
            if let error = error {
                print("Error removing user: \(error)")
                // Handle the error appropriately
            } else {
                print("User successfully removed")
                self.navigateToSignInScreen()
            }
        }
    }
    
    @objc func closeButtonTapped() {
            // Dismiss the view controller
            dismiss(animated: true, completion: nil)
        }

}
