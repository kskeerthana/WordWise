//
//  AdminController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 12/15/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AdminController: UIViewController {
    var searchBar: UISearchBar!
    var tableView: UITableView!

    var users: [User] = [] // Model for User
    var filteredUsers: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        setupTableView()
        fetchUsers()
    }

    func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search Users"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting users: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No users found")
                return
            }

            self?.users = documents.compactMap { doc -> User? in
                return User(document: doc.data())
            }

            self?.filteredUsers = self?.users ?? []
            print("Fetched users: \(self?.filteredUsers.count ?? 0)")
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

}

struct User {
    var name: String
    var email: String
    var level: Int

    init?(document: [String: Any]) {
        guard let name = document["name"] as? String,
              let email = document["email"] as? String,
              let level = document["level"] as? Int else {
            return nil
        }
        self.name = name
        self.email = email
        self.level = level
    }
}

extension AdminController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = filteredUsers[indexPath.row]
        cell.textLabel?.text = "\(user.name) - Level: \(user.level)"
        return cell
    }

    // Add other delegate methods as needed...
}

extension AdminController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { user in
                return user.name.lowercased().contains(searchText.lowercased()) ||
                       user.email.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    // Add other search bar delegate methods as needed...
}


