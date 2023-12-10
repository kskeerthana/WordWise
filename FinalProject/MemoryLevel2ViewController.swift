//
//  MemoryLevel2ViewController.swift
//  FinalProject
//
//  Created by Nikethana N N on 12/10/23.
//

import UIKit

class MemoryLevel2ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var firstSelectedIndexPath: IndexPath?
    var firstSelectedValue: Int?
        var gameTimer: Timer?
        var timerValue: Int = 0
    var finalTimerValue: Int = 0
        var numberOfMatchesFound = 0
    
    @IBOutlet weak var gameNameLbl: UILabel!
    
    @IBOutlet weak var levelTwoView: UICollectionView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gameSubNameLbl: UILabel!
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // When the view transitions (rotates), invalidate the layout to trigger an update
        coordinator.animate(alongsideTransition: { _ in
            self.levelTwoView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        randomNumbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! PostCellLevelTwo
        cell.puzzleNumber.text = String(randomNumbers[indexPath.row])
        cell.puzzleNumber.isHidden = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PostCellLevelTwo else { return }
        // Perform the flip animation
        UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromRight, animations: {
            // Toggle visibility of the number during the flip
            cell.puzzleNumber.isHidden = !cell.puzzleNumber.isHidden
        }, completion: { _ in
            // After the flip, check if it's the first or second tap
                    if self.firstSelectedIndexPath == nil {
                        // It's the first tap
                        self.firstSelectedIndexPath = indexPath
                        self.firstSelectedValue = self.randomNumbers[indexPath.row]
                    } else if let firstIndexPath = self.firstSelectedIndexPath, firstIndexPath != indexPath {
                        // It's the second tap and not the same cell as the first
                        let secondSelectedValue = self.randomNumbers[indexPath.row]

                        if self.firstSelectedValue == secondSelectedValue {
                            self.numberOfMatchesFound += 1 // Increment the matches found
                            self.checkForCompletion()
                            UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                cell.layer.borderColor = UIColor(hexString: "#159947").cgColor
                                cell.layer.backgroundColor = UIColor(hexString: "#DDFFEA").cgColor
                            })
                            if let firstCell = collectionView.cellForItem(at: firstIndexPath) as? PostCellLevelTwo {
                                UIView.transition(with: firstCell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                    firstCell.layer.borderColor = UIColor(hexString: "#159947").cgColor
                                    firstCell.layer.backgroundColor = UIColor(hexString: "#DDFFEA").cgColor
                                })
                            }
                           
                        } else {
                            // If values don't match, hide the numbers after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                    cell.puzzleNumber.isHidden = true
                                })
                                if let firstCell = collectionView.cellForItem(at: firstIndexPath) as? PostCellLevelTwo {
                                    UIView.transition(with: firstCell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                        firstCell.puzzleNumber.isHidden = true
                                    })
                                }
                            }
                        }
                        // Reset the selected cell and value
                        self.firstSelectedIndexPath = nil
                        self.firstSelectedValue = nil
                    }
                })
                collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    var randomNumbers: [Int] = []
    
    var random1: Int = 0
    var random2: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateRandomNumbers()
        self.startGameTimer()
    }
    func startGameTimer() {
        self.gameTimer?.invalidate() // Invalidate any existing timer
        self.timerValue = 0 // Reset the timer value
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerValue += 1
            self?.timerLabel.text = "\(self?.timerValue ?? 0)"
            // You can also format this to display minutes and seconds if you prefer
        }
    }
    func stopGameTimer() {
        self.gameTimer?.invalidate()
        // At this point, timerValue contains the total time taken
        // You can store it or use it as needed
    }

    func checkForCompletion() {
        // Check if all tiles are matched
        if numberOfMatchesFound == randomNumbers.count / 2 {
            print("Game Completed")
            stopGameTimer() // Stop the timer
            let message = "Woohoo! You've completed the game in \(self.timerValue) seconds. Do you want to go to the next level?"
            let alert = UIAlertController(title: "Game Complete", message: message, preferredStyle: .alert)

            // Add a "Yes" action
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                // Handle the action for moving to the next level
                print("Moving to next level")
            }))

            // Add a "Maybe Later" action
            alert.addAction(UIAlertAction(title: "Maybe Later", style: .cancel, handler: { _ in
                // Handle the action for postponing to the next level
                self.dismiss(animated: true, completion: nil)
            }))

            // Present the alert
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func generateRandomNumbers() {
        var random1: Int
        var random2: Int
        var random3: Int
        var random4: Int
        
        repeat {
            random1 = Int.random(in: 1...9)
            random2 = Int.random(in: 1...9)
            random3 = Int.random(in: 1...9)
            random4 = Int.random(in: 1...9)
        } while random1 == random2 || random1 == random3 || random1 == random4 ||
                    random2 == random3 || random2 == random4 ||
                    random3 == random4 // Ensure all are different
        
        // Create the 2x3 matrix by repeating the numbers twice and then shuffling
        randomNumbers = [random1, random1, random2, random2, random3, random3, random4, random4].shuffled()
    }
}

class PostCellLevelTwo: UICollectionViewCell {
    
    @IBOutlet weak var puzzleNumber: UILabel!
    override func awakeFromNib() {
            super.awakeFromNib()
            setupCell()
        }

        private func setupCell() {
            // Rounded corners
            self.layer.cornerRadius = 10
            self.clipsToBounds = true

            // Borders
            self.layer.borderWidth = 5.0
            self.layer.borderColor = UIColor(hexString: "#4F3CC9").cgColor //dark purple
            self.layer.backgroundColor = UIColor(hexString: "#C0BBDE").cgColor // light purple
            

            // Shadow
            self.layer.shadowOpacity = 0.1
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.masksToBounds = false

            // Set the font and color of the label
            puzzleNumber.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            puzzleNumber.textColor = UIColor.darkGray

            // Background color
            self.backgroundColor = UIColor.white
        }


}
