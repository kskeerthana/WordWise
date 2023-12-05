//
//  MemoryGameViewController.swift
//  FinalProject
//
//  Created by Nikethana N N on 11/28/23.
//

import UIKit

class MemoryGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var firstSelectedIndexPath: IndexPath?
    var firstSelectedValue: Int?
    
    @IBOutlet weak var collectionView: UICollectionView!
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
                            // If values match, change the background color and disable interaction
                            UIView.transition(with: cell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                cell.backgroundColor = .green
                            })
                            if let firstCell = collectionView.cellForItem(at: firstIndexPath) as? PostCell {
                                UIView.transition(with: firstCell, duration: 0.5, options: .transitionFlipFromRight, animations: {
                                    firstCell.backgroundColor = .green
                                })
                            }
                        } else {
                            // If values don't match, hide the numbers after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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

    
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button1: UIButton!
    
    var randomNumbers: [Int] = []
    
    var random1: Int = 0
    var random2: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateRandomNumbers()
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
            self.layer.borderWidth = 3.0
            self.layer.borderColor = UIColor.orange.cgColor

            // Shadow
            self.layer.shadowOpacity = 0.1
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.masksToBounds = false

            // Set the font and color of the label
            number.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            number.textColor = UIColor.darkGray

            // Background color
            self.backgroundColor = UIColor.white
        }
}
