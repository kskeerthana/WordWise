//
//  AllGamesTableViewController.swift
//  FinalProject
//
//  Created by Nikethana N N on 12/12/23.
//

import UIKit

class AllGamesTableViewController: UITableViewController {
    // Hardcoded game data
    
    var games: [Game] = [
            Game(name: "Memory Game", currentLevel: 1, totalLevels: 10),
            Game(name: "Puzzle Game", currentLevel: 2, totalLevels: 10)
        ]

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.reloadData()
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



    }
// Game struct with an added property for total levels
struct Game {
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
