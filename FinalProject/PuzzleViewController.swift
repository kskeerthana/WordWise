//
//  PuzzleViewController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 11/28/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PuzzleViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    var currentLevel : Int?
    var numbers = [String]()
    let descriptionLabel = UILabel()
    var gameName : String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupLevel(currentLevel)
        setupDragAndDrop()
        
        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: (view.frame.size.width/3)-3,
//                                 height: (view.frame.size.height/3)-3)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        collectionView.collectionViewLayout = layout
        let descriptionLabelHeight: CGFloat = 40 // Adjust this value based on the size of your description label
        collectionView.contentInset = UIEdgeInsets(top: descriptionLabelHeight, left: 0, bottom: 0, right: 0)
        
//        configureCollectionViewLayout()
        
        collectionView.register(CustomHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        setupDescriptionLabel()
        fetchCurrentLevel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureCollectionViewLayout() // Ensure layout is updated here
    }
    
    func setupDescriptionLabel() {
            // Configure the label's appearance
            descriptionLabel.text = "Drag and drop the tiles in sequence"
            descriptionLabel.textAlignment = .center
            descriptionLabel.font = UIFont.italicSystemFont(ofSize: 16).bold()
            descriptionLabel.numberOfLines = 0 // Allows multiple lines if needed

            // Add the label to the view and set its constraints
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(descriptionLabel)
            NSLayoutConstraint.activate([
                descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
            ])
        }

    func setupLevel(_ level: Int) {
        numbers = (1...level + 3).shuffled().map { "\($0)" }
        configureCollectionViewLayout()
        collectionView.reloadData()
        updateGameState()
    }

    func setupDragAndDrop() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }

    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
            checkOrder()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    func checkOrder() {
        let isCorrectOrder = numbers.sorted() == numbers
        if isCorrectOrder {
            // Move to the next level
            advanceToNextLevel()
//            currentLevel += 1
//            setupLevel(currentLevel)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "numCell", for: indexPath) as! PuzzleViewCell
        print("Number value",numbers[indexPath.row])
        cell.cellLabell.text = String(numbers[indexPath.row])
        cell.backgroundColor = .lightGray// or any contrasting color
        cell.cellLabell.textColor = .black
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = numbers.remove(at: sourceIndexPath.item)
        numbers.insert(temp, at: destinationIndexPath.item)
        checkOrder()
    }
    
    func advanceToNextLevel() {
        let alert = UIAlertController(title: "Great Job!", message: "Moving to level \(currentLevel! + 1)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//            self.currentLevel += 1
//            self.setupLevel(self.currentLevel)
//            self.updateGameState()
            guard let level = self.currentLevel else { return }

            let newLevel = level + 1
            self.currentLevel = newLevel
            self.setupLevel(newLevel)
            self.updateGameState()
        }))
        present(alert, animated: true)
    }
        
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected element kind")
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! CustomHeaderView
        let level = currentLevel ?? 0 // Provide a default value such as 0
        header.titleLabel.text = "Level \(level)"
//        header.titleLabel.text = "Level \(currentLevel)"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50) // Adjust the height as needed
    }
    
    func configureCollectionViewLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            
        let numberOfCellsPerRow: CGFloat = 3 // Adjust based on your design
        let spacing: CGFloat = 1 // Spacing between cells
        let totalSpacing = (numberOfCellsPerRow - 1) * spacing
        let individualCellWidth = (collectionView.bounds.width - totalSpacing) / numberOfCellsPerRow
        let individualCellHeight = (collectionView.bounds.height - totalSpacing) / numberOfCellsPerRow
        let CellHeight = individualCellWidth - 1

            layout.itemSize = CGSize(width: individualCellWidth, height: CellHeight)
            layout.minimumLineSpacing = spacing
            layout.minimumInteritemSpacing = spacing
    }
    
    func updateGameState() {
        guard let userId = Auth.auth().currentUser?.uid, let gameName = self.gameName else {
                print("User ID or Game Name not found")
                return
            }

            let gameData: [String: Any] = [
                "userId": userId,
                "gameName": gameName,
                "currentLevel": currentLevel,
                "totalLevels": 10
            ]

            let db = Firestore.firestore()
            // Assuming you have a unique document for each game and user
            let gameDocId = "\(userId)_\(gameName)"
            db.collection("games").document(gameDocId).setData(gameData, merge: true) { error in
                if let error = error {
                    print("Error updating game state: \(error)")
                } else {
                    print("Game state updated successfully.")
                }
            }
    }
    
    func fetchCurrentLevel() {
        guard let userId = Auth.auth().currentUser?.uid, let gameName = self.gameName else {
            print("User ID or Game Name not found")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("games").whereField("userId", isEqualTo: userId).whereField("gameName", isEqualTo: gameName).getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching game state: \(error)")
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                let data = documents.first?.data()
                let fetchedLevel = data?["currentLevel"] as? Int ?? 1
                self?.currentLevel = fetchedLevel
                self?.setupLevel(fetchedLevel)
            } else {
                print("No game state found, starting at level 1")
                self?.currentLevel = 1
                self?.setupLevel(1)
            }
        }
        
        
    }

}

class CustomHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
}

extension UIFont {
    func bold() -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic])
        return UIFont(descriptor: descriptor!, size: 0) // size 0 means keep the size as it is
    }
}
