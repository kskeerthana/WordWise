//
//  AllGamesTableViewController.swift
//  FinalProject
//
//  Created by Nikethana N N on 12/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AllGamesTableViewController: UITableViewController {
    // Hardcoded game data
    
    var games: [Game] = []
//            Game(name: "Memory Game", currentLevel: 1, totalLevels: 10),
//            Game(name: "Puzzle Game", currentLevel: 2, totalLevels: 10)
//        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.reloadData()
        fetchGamesForCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGamesForCurrentUser()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row with animation
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Assuming you have an array of games with their names
        let gameName = games[indexPath.row].name
        if gameName == "Memory Game" {
            performSegue(withIdentifier: "memoryGame", sender: indexPath)
        } else if gameName == "Puzzle Game" {
            performSegue(withIdentifier: "puzzleGame", sender: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return games.count
        }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! GameTableViewCell

            let game = games[indexPath.row]
            cell.gameNameLabel.text = game.name
            cell.levelLabel.text = "Level: \(game.currentLevel)"
            // Calculate the progress based on the current level and the total levels
            cell.progressView.progress = Float(game.currentLevel) / Float(game.totalLevels)

            return cell
        }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10 // This will create a 10pt space between sections
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            let selectedGame = games[indexPath.row]
            switch segue.identifier {
                case "memoryGame":
                    if let memoryVC = segue.destination as? MemoryGameViewController {
                        // Configure memoryVC with selectedGame data
                        memoryVC.gameName = selectedGame.name
//                        memoryVC.level = selectedGame.level
                    }
                case "puzzleGame":
                    if let puzzleVC = segue.destination as? PuzzleViewController {
                        // Configure puzzleVC with selectedGame data
                        puzzleVC.gameName = selectedGame.name
//                        puzzleVC.level = selectedGame.level
                    }
                default:
                    break
            }
        }
    }
    
    func fetchGamesForCurrentUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let gamesRef = db.collection("games")

        gamesRef.whereField("userId", isEqualTo: userId).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                self.games = documents.compactMap { doc -> Game? in
                    let data = doc.data()
                    guard let name = data["gameName"] as? String,
                          let currentLevel = data["currentLevel"] as? Int,
                          let totalLevels = data["totalLevels"] as? Int else {
                        return nil
                    }
                    return Game(id: doc.documentID, name: name, currentLevel: currentLevel, totalLevels: totalLevels)
                }
            } else {
                // No documents found, create new ones
                self.createInitialGamesForUser(userId: userId)
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func createInitialGamesForUser(userId: String) {
        let db = Firestore.firestore()
        let gamesRef = db.collection("games")

        // Example games to add
        let initialGames = [
            Game(id : "1",name: "Memory Game", currentLevel: 1, totalLevels: 10),
            Game(id : "2",name: "Puzzle Game", currentLevel: 1, totalLevels: 10)
        ]

        for game in initialGames {
            var gameData: [String: Any] = [
                "userId": userId,
                "gameName": game.name,
                "currentLevel": game.currentLevel,
                "totalLevels": game.totalLevels
            ]

            let gameDocId = "\(userId)_\(game.name)"
            gamesRef.document(gameDocId).setData(gameData) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                }
            }
        }

        // Set the initial games as the current games
        self.games = initialGames
    }





    }
// Game struct with an added property for total levels
struct Game {
    let id: String
    let name: String
    let currentLevel: Int
    let totalLevels: Int
}

// Custom UITableViewCell subclass with outlets for labels and progress view
class GameTableViewCell: UITableViewCell {
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
}
