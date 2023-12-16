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
    let profileButton = UIButton(type: .custom)
    let levelsHeadingLabel = UILabel()
    let addLevelButton = UIButton(type: .system)


    var users: [User] = [] // Model for User
    var filteredUsers: [User] = []
    var userGames: [String: (gameName: String, currentLevel: Int)] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupProfileButton()
        setupSearchBar()
        setupTableView()
        fetchUsers()
        setupLevelsHeadingAndButton()
    }

    func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search Users"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupLevelsHeadingAndButton() {
        // Create the footer view that will contain the heading and button
        let footerView = UIView()
        
        // Set up the heading label
        levelsHeadingLabel.text = "Add Levels To Memory Game"
        levelsHeadingLabel.textAlignment = .center
        levelsHeadingLabel.font = UIFont.boldSystemFont(ofSize: 18)
        footerView.addSubview(levelsHeadingLabel)
        
        // Set up the add level button
        addLevelButton.setTitle("Add Level", for: .normal)
        addLevelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        addLevelButton.addTarget(self, action: #selector(addLevelButtonTapped), for: .touchUpInside)
        footerView.addSubview(addLevelButton)
        
        // Disable autoresizing masks and set constraints for both
        levelsHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        addLevelButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Set the constraints for levelsHeadingLabel
            levelsHeadingLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            levelsHeadingLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            levelsHeadingLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),

            // Set the constraints for addLevelButton
            addLevelButton.topAnchor.constraint(equalTo: levelsHeadingLabel.bottomAnchor, constant: 8),
            addLevelButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            addLevelButton.heightAnchor.constraint(equalToConstant: 44),
            addLevelButton.widthAnchor.constraint(equalToConstant: 200),
            // This is the bottom anchor constraint for the footerView
            addLevelButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -20)
        ])

        // You don't need to setNeedsLayout or layoutIfNeeded because you're setting the frame directly.
        // Determine the height of the footer view based on the button's bottom position.
        // You must set a frame for the footerView otherwise it won't display.
        let footerHeight = 20 + levelsHeadingLabel.intrinsicContentSize.height + 8 + 44 + 20 // Top padding + label height + spacing + button height + bottom padding
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: footerHeight)

        // Set the footer view as the table view's footer
        tableView.tableFooterView = footerView
    }



    @objc func addLevelButtonTapped() {
        // Action to handle the Add Level button tap
    }
    
    func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error getting users: \(error)")
                return
            } else if let snapshot = snapshot, snapshot.documents.isEmpty {
                print("The users collection is empty.")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No users found")
                return
            }

            self?.users = documents.compactMap { doc -> User? in
                return User(document: doc.data())
            }

            // New code to fetch game data for each user
            let group = DispatchGroup()
            self?.users.forEach { user in
                group.enter()
                db.collection("games").whereField("userId", isEqualTo: user.uid).getDocuments { (gameSnapshot, gameError) in
                    if let gameError = gameError {
                        print("Error getting game data: \(gameError)")
                    } else if let gameData = gameSnapshot?.documents.first?.data() {
                        let gameName = gameData["gameName"] as? String ?? "N/A"
                        let currentLevel = gameData["currentLevel"] as? Int ?? 0
                        self?.userGames[user.uid] = (gameName, currentLevel)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                print("Fetched users and games")
                self?.filteredUsers = self?.users ?? []
                self?.tableView.reloadData()
            }
        }
    }

}

struct User {
    var uid: String
    var fullName: String
    var email: String
    var isAdmin: Bool

    init?(document: [String: Any]) {
        guard let uid = document["uid"] as? String,
              let fullName = document["fullName"] as? String,
              let email = document["email"] as? String,
              let lastSignIn = document["lastSignIn"] as? Timestamp else {
            return nil
        }
        self.uid = uid
        self.fullName = fullName
        self.email = email
        self.isAdmin = document["isAdmin"] as? Bool ?? false
    }
}
class CustomTableViewCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let gameLabel = UILabel() // New label
    let levelLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Add subviews
        [nameLabel, emailLabel, gameLabel, levelLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        // Constraints
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/4, constant: -15),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
            emailLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/4, constant: -15),
            emailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            gameLabel.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 10),
            gameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/4, constant: -15),
            gameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            levelLabel.leadingAnchor.constraint(equalTo: gameLabel.trailingAnchor, constant: 10),
            levelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            levelLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension AdminController: UITableViewDelegate, UITableViewDataSource {
    func setupProfileButton() {
        profileButton.setTitle("P", for: .normal) // Set the text for the button
        profileButton.titleLabel?.font = UIFont.systemFont(ofSize: 24) // Adjust the font size as needed

        profileButton.backgroundColor = .white // Or any color you prefer
        profileButton.layer.borderColor = UIColor(hexString: "#7B81F7").cgColor
        profileButton.layer.borderWidth = 3
        profileButton.setTitleColor(.black, for: .normal) // Set the text color
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)

        // Add the button to the view hierarchy
        view.addSubview(profileButton)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            profileButton.widthAnchor.constraint(equalToConstant: 60),
            profileButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Make the button circular
        profileButton.layer.cornerRadius = 30 // Half of width or height
        profileButton.clipsToBounds = true
    }
    @objc func profileButtonTapped() {
        // Handle the button tap
        print("Profile button tapped")
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently signed in")
            return
        }

        let db = Firestore.firestore()
        db.collection("admins").document(userId).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching admin data: \(error)")
                return
            }

            if let document = document, document.exists {
                let adminData = document.data()
                print("adminData", adminData)
                let adminName = adminData?["fullName"] as? String ?? "No Name"
                let adminEmail = adminData?["email"] as? String ?? "No Email"
                
                DispatchQueue.main.async {
                    let profileVC = ProfileViewController()
                    profileVC.userName = adminName
                    profileVC.userEmail = adminEmail
                    profileVC.modalPresentationStyle = .fullScreen
                    self?.present(profileVC, animated: true, completion: nil)
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hexString: "#7B81F7")

        let nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.textColor = UIColor(hexString: "#FFFFFF")
        nameLabel.textAlignment = .center

        let emailLabel = UILabel()
        emailLabel.text = "Email"
        emailLabel.textColor = UIColor(hexString: "#FFFFFF")
        emailLabel.textAlignment = .center
        
        let gameLabel = UILabel()
        gameLabel.text = "Game Name"
        gameLabel.textColor = UIColor(hexString: "#FFFFFF")
        gameLabel.textAlignment = .center
        
        let levelLabel = UILabel()
        levelLabel.text = "Level"
        levelLabel.textColor = UIColor(hexString: "#FFFFFF")
        levelLabel.textAlignment = .center

        [nameLabel, emailLabel, gameLabel, levelLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }

        // Constraints
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            nameLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 1/4, constant: -10),
            nameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
            emailLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 1/4, constant: -10),
            emailLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            gameLabel.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 10),
            gameLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 1/4, constant: -10),
            gameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            levelLabel.leadingAnchor.constraint(equalTo: gameLabel.trailingAnchor, constant: 10),
            levelLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            levelLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Adjust the height as needed
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let user = users[indexPath.row]
        cell.nameLabel.text = user.fullName
        cell.emailLabel.text = user.email

        if let gameData = userGames[user.uid] {
            cell.gameLabel.text = gameData.gameName
            cell.levelLabel.text = "Level \(gameData.currentLevel)"
        } else {
            cell.gameLabel.text = "N/A"
            cell.levelLabel.text = "N/A"
        }

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
                return user.fullName.lowercased().contains(searchText.lowercased()) ||
                       user.email.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}


