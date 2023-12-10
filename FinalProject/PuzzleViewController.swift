//
//  PuzzleViewController.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 11/28/23.
//

import UIKit

class PuzzleViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    var currentLevel = 1
    var numbers = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLevel(currentLevel)
        setupDragAndDrop()
        
        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: (view.frame.size.width/3)-3,
//                                 height: (view.frame.size.height/3)-3)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        collectionView.collectionViewLayout = layout
        
//        configureCollectionViewLayout()
        
        collectionView.register(CustomHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureCollectionViewLayout() // Ensure layout is updated here
    }

    func setupLevel(_ level: Int) {
        numbers = (1...level + 3).shuffled().map { "\($0)" }
        configureCollectionViewLayout()
        collectionView.reloadData()
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
            currentLevel += 1
            setupLevel(currentLevel)
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
        let alert = UIAlertController(title: "Great Job!", message: "Moving to level \(currentLevel + 1)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
        }))
        present(alert, animated: true)
    }
        
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected element kind")
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! CustomHeaderView
        header.titleLabel.text = "Level \(currentLevel)"
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
            let individualCellHeight = (collectionView.bounds.height - totalSpacing) / numberOfCellsPerRow // Adjust height as needed

            layout.itemSize = CGSize(width: individualCellWidth, height: individualCellHeight)
            layout.minimumLineSpacing = spacing
            layout.minimumInteritemSpacing = spacing
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

