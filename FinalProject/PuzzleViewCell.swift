//
//  PuzzleViewCell.swift
//  FinalProject
//
//  Created by Keerthana Srinivasan on 11/28/23.
//

import UIKit

class PuzzleViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    
    func configure(with numString: String){
        print("input from view controller",numString)
        cellLabel.text = numString
    }
}
