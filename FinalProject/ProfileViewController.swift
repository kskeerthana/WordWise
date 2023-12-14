//
//  ProfileViewController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 12/14/23.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let signOutButton = UIButton()
    let deleteAccountButton = UIButton()
    let closeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
                
        // Configure UI elements
        setupProfileImageView()
        setupNameLabel()
        setupEmailLabel()
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
        
        func setupNameLabel() {
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.text = "Kobe Bryant" // Placeholder text
            nameLabel.textAlignment = .center
            view.addSubview(nameLabel)
            
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
                nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
        
        func setupEmailLabel() {
            emailLabel.translatesAutoresizingMaskIntoConstraints = false
            emailLabel.text = "test@gmail.com" // Placeholder text
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
        // Handle sign out logic here
    }
    
    @objc func deleteAccountTapped() {
        // Handle account deletion logic here
    }
    
    @objc func closeButtonTapped() {
            // Dismiss the view controller
            dismiss(animated: true, completion: nil)
        }

}
