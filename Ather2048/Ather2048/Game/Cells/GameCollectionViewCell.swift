//
//  GameCollectionViewCell.swift
//  Ather2048
//
//  Created by Siva Sandeep on 07/08/21.
//

import UIKit

class GameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var itemLabel: UILabel!
    
    
    func setupData(_ number: Int) {
        if number > 0 {
            itemLabel.text = number.description
        } else {
           itemLabel.text = ""
        }
        itemLabel.backgroundColor = ColorAssingment.getColorForNumber(number)
    }
}
