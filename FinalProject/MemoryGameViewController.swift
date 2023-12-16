//
//  MemoryGameViewController.swift
//  FinalProject
//
//  Created by Nikethana N N on 11/28/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MemoryGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var gameName: String?
    var level: String?
    var firstSelectedIndexPath: IndexPath?
    var firstSelectedValue: Int?
        var gameTimer: Timer?
        var timerValue: Int = 0
    var finalTimerValue: Int = 0
        var numberOfMatchesFound = 0
    
    @IBOutlet weak var gameNameLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gameSubNameLbl: UILabel!
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // When the view transitions (rotates), invalidate the layout to trigger an update
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    // Implement the UICollectionViewDelegateFlowLayout method
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the size of the cells based on the current view size
        let numberOfCellsInRow: CGFloat = self.view.frame.width > self.view.frame.height ? 3 : 2
        let spacing: CGFloat = 10 // Adjust the spacing as needed
        let totalSpacing: CGFloat = (numberOfCellsInRow - 1) * spacing + spacing * 2 // Left and right spacing
        let width = (collectionView.bounds.width - totalSpacing) / numberOfCellsInRow
        let height = width // Or however you want to calculate the height

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        randomNumbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        cell.number.text = String(randomNumbers[indexPath.row])
        cell.number.isHidden = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PostCell else { return }
        // Perform the flip animation
        UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromRight, animations: {
            // Toggle visibility of the number during the flip
            cell.number.isHidden = !cell.number.isHidden
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
                            if let firstCell = collectionView.cellForItem(at: firstIndexPath) as? PostCell {
                                UIView.transition(with: firstCell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                    firstCell.layer.borderColor = UIColor(hexString: "#159947").cgColor
                                    firstCell.layer.backgroundColor = UIColor(hexString: "#DDFFEA").cgColor
                                })
                            }
                           
                        } else {
                            // If values don't match, hide the numbers after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                    cell.number.isHidden = true
                                })
                                if let firstCell = collectionView.cellForItem(at: firstIndexPath) as? PostCell {
                                    UIView.transition(with: firstCell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                        firstCell.number.isHidden = true
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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startGameTimer()
    }

    func fetchLevelTwo() {
        let db = Firestore.firestore()
        let levelsCollection = db.collection("levels")

        // Assuming you know the ID of the specific document you want to fetch
        let documentId = "specific_document_id"

        levelsCollection.document(documentId).getDocument { (document, error) in
            if let error = error {
                // Handle any errors
                print("Error fetching document: \(error)")
            } else {
                if let document = document, document.exists {
                    // Document data may be nil if the document exists but has no data
                    if let levelTwoValue = document.data()?["levelTwo"] as? Int {
                        // Now you have the levelTwo value
                        print("Level Two: \(levelTwoValue)")
                    } else {
                        print("Document does not contain levelTwo")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    func startGameTimer() {
        self.gameTimer?.invalidate() // Invalidate any existing timer
        self.timerValue = 0 // Reset the timer value
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async { // Make sure to update UI on the main thread
                strongSelf.timerValue += 1
                if let timerLabel = strongSelf.timerLabel {
                    timerLabel.text = "\(strongSelf.timerValue)"
                }
            }
        }
    }

    func stopGameTimer() {
        self.gameTimer?.invalidate()
    }

//    func checkForCompletion() {
//        // Check if all tiles are matched
//        if numberOfMatchesFound == randomNumbers.count / 2 {
//            print("Game Completed")
//            stopGameTimer() // Stop the timer
//            let message = "Woohoo! You've completed the game in \(self.timerValue) seconds. Do you want to go to the next level?"
//            let alert = UIAlertController(title: "Game Complete", message: message, preferredStyle: .alert)
//
//            // Add a "Yes" action
//            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                if let nextLevelVC = storyboard.instantiateViewController(withIdentifier: "MemoryLevel2ViewController") as? MemoryLevel2ViewController {
//                    self?.present(nextLevelVC, animated: true, completion: nil)
//                }
//            }))
//
//            // Add a "Maybe Later" action
//            alert.addAction(UIAlertAction(title: "Maybe Later", style: .cancel, handler: { _ in
//                // Handle the action for postponing to the next level
//                self.dismiss(animated: true, completion: nil)
//            }))
//
//            // Present the alert
//            DispatchQueue.main.async {
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
//    func checkForCompletion() {
//        // Check if all tiles are matched
//        if numberOfMatchesFound == randomNumbers.count / 2 {
//            print("Game Completed")
//            stopGameTimer() // Stop the timer
//            
//            // Access Firestore
//            let db = Firestore.firestore()
//            let userId = Auth.auth().currentUser?.uid ?? ""
//            
//            // Assuming 'levels' collection contains a document per user
//            db.collection("levels").document(userId).getDocument { [weak self] (document, error) in
//                var message = "Woohoo! You've completed the game in \(self?.timerValue ?? 0) seconds."
//                var shouldShowNextLevelOption = false
//
//                if let document = document, document.exists, let levelTwo = document.data()?["levelTwo"] as? Bool {
//                    shouldShowNextLevelOption = levelTwo
//                    message += shouldShowNextLevelOption ? " Do you want to go to the next level?" : ""
//                } else {
//                    // Handle error or document does not exist case
//                    message += " Yay you've completed!"
//                }
//                
//                // Now show the alert based on the shouldShowNextLevelOption flag
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "Game Complete", message: message, preferredStyle: .alert)
//                    
//                    if shouldShowNextLevelOption {
//                        // Add a "Yes" action to move to the next level
//                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            if let nextLevelVC = storyboard.instantiateViewController(withIdentifier: "MemoryLevel2ViewController") as? MemoryLevel2ViewController {
////                                let adminVC = AdminController()
//                                nextLevelVC.modalPresentationStyle = .fullScreen
//                                self?.present(nextLevelVC, animated: true, completion: nil)
//                            }
//                        }))
//                    }
//                    
//                    // Add a "Maybe Later" action
//                    alert.addAction(UIAlertAction(title: "Maybe Later", style: .cancel, handler: { _ in
//                        self?.dismiss(animated: true, completion: nil)
//                    }))
//                    
//                    // Present the alert
//                    self?.present(alert, animated: true, completion: nil)
//                }
//            }
//        }
//    }
    func checkForCompletion() {
        // Check if all tiles are matched
        if numberOfMatchesFound == randomNumbers.count / 2 {
            print("Game Completed")
            stopGameTimer() // Stop the timer

            // Access Firestore
            let db = Firestore.firestore()

            // If 'levels' collection contains a global setting document, use a known document ID
            let levelsDocumentId = "i742LLE6dwFsN1jmo6TX"  // Replace with your actual document ID
            db.collection("levels").document(levelsDocumentId).getDocument { [weak self] (document, error) in
                var message = "Woohoo! You've completed the game in \(self?.timerValue ?? 0) seconds."

                if let error = error {
                    // Handle any errors here
                    print("Error fetching levels document: \(error)")
                    message += " Yay you've completed!"
                } else if let document = document, document.exists, let levelTwo = document.data()?["levelTwo"] as? Bool {
                    // Check the value of levelTwo
                    if levelTwo {
                        // levelTwo is true, offer to go to the next level
                        message += " Do you want to go to the next level?"
                    } else {
                        // levelTwo is false, just congratulate
                        message += " Yay you've completed!"
                    }
                } else {
                    print("Document does not exist or levelTwo field is not present")
                    message += " Yay you've completed!"
                }
                
                // Now show the alert
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Game Complete", message: message, preferredStyle: .alert)
                    
                    if let levelTwo = document?.data()?["levelTwo"] as? Bool, levelTwo {
                        // Add a "Yes" action to move to the next level
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                            // Go to the next level
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if let nextLevelVC = storyboard.instantiateViewController(withIdentifier: "MemoryLevel2ViewController") as? MemoryLevel2ViewController {
                                nextLevelVC.modalPresentationStyle = .fullScreen
                                self?.present(nextLevelVC, animated: true, completion: nil)
                            }
                        }))
                    }
                    
                    // Add a "Maybe Later" action
                    alert.addAction(UIAlertAction(title: "Maybe Later", style: .cancel, handler: { _ in
                        // Dismiss the current view controller
                        self?.dismiss(animated: true, completion: nil)
                    }))
                    
                    // Present the alert
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }


    
    func generateRandomNumbers() {
        var random1: Int
        var random2: Int
        var random3: Int
        
        repeat {
            random1 = Int.random(in: 1...9)
            random2 = Int.random(in: 1...9)
            random3 = Int.random(in: 1...9)
        } while random1 == random2 || random1 == random3 || random2 == random3 // Ensure all are different
        
        // Create the 2x3 matrix by repeating the numbers twice and then shuffling
        randomNumbers = [random1, random1, random2, random2, random3, random3].shuffled()
    }
}

class PostCell: UICollectionViewCell {
    @IBOutlet weak var number: UILabel!

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
            number.font = UIFont.systemFont(ofSize: 32, weight: .bold)

            number.textColor = UIColor.darkGray

            // Background color
            self.backgroundColor = UIColor.white
        }
}
