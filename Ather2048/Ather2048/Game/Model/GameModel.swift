//
//  GameModel.swift
//  Ather2048
//
//  Created by Siva Sandeep on 08/08/21.
//

import UIKit

struct GameModel: CustomStringConvertible {

    let number: Int
    let position: (row: Int, column: Int)
    let sourrendedPostions: (leftIndex: Int,righIndex: Int,topIndex: Int,bottomIndex: Int)
    
    var description: String {
        return "number: \(number) position \(position) sourrendedPostions \(sourrendedPostions)"
    }
    
}

class CalculateSurrondingIndexes {
    
    static func getSurroundedIndexes(_ tileIndex: Int, matrixSize: Int) -> (leftIndex: Int,righIndex: Int,topIndex: Int,bottomIndex: Int) {
        let currentPosition = getPostionForIndex(tileIndex, matrixSize: matrixSize)
        

        var left = tileIndex-1
        let leftPostion = getPostionForIndex(left, matrixSize: matrixSize)
        if leftPostion.row != currentPosition.row {
            left = -1
        } else {
            if left < 0 {
                left = -1
            }
        }
        
        
        var right = tileIndex+1
        
        let rightPostion = getPostionForIndex(right, matrixSize: matrixSize)
        
        if rightPostion.row != currentPosition.row {
            right = -1
        } else {
            if right >= matrixSize*matrixSize {
                right = -1
            }
        }

      
        
        var top = tileIndex-matrixSize
        if top < 0 {
            top = -1
        }
        
        var bottom = tileIndex+matrixSize
        if bottom >= matrixSize*matrixSize {
            bottom = -1
        }
        
        return (leftIndex: left,righIndex: right,topIndex: top,bottomIndex: bottom)
    }
    
    static func getPostionForIndex(_ index: Int, matrixSize: Int ) -> (row: Int, column: Int) {
        let row = index/matrixSize
        let column = index%matrixSize
        let positionOnMatrix = (row: row , column: column)
        return positionOnMatrix
    }
}


class ColorAssingment {
    
    static func getColorForNumber(_ number: Int) -> UIColor {
        switch number {
        case 0:
            return .lightGray
        case 2:
            return UIColor(red: 156/255.0, green: 96/255.0, blue: 14/255.0, alpha: 1.0)
        case 4:
            return UIColor(red: 185/255.0, green: 48/255.0, blue: 146/255.0, alpha: 1.0)
        case 8:
            return UIColor(red: 62/255.0, green: 180/255.0, blue: 186/255.0, alpha: 1.0)
        case 16:
            return UIColor(red: 255/255.0, green: 209/255.0, blue: 1/255.0, alpha: 1.0)
        case 32:
            return UIColor(red: 0/255.0, green: 172/255.0, blue: 213/255.0, alpha: 1.0)
        case 64:
            return UIColor(red: 255/255.0, green: 108/255.0, blue: 0/255.0, alpha: 1.0)
        case 128:
            return UIColor(red: 0/255.0, green: 70/255.0, blue: 124/255.0, alpha: 1.0)
        case 256:
            return UIColor(red: 0/255.0, green: 134/255.0, blue: 82/255.0, alpha: 1.0)
        case 512:
            return UIColor(red: 245/255.0, green: 67/255.0, blue: 110/255.0, alpha: 1.0)
        case 1024:
            return UIColor(red: 58/255.0, green: 129/255.0, blue: 225/255.0, alpha: 1.0)
        case 2048:
            return UIColor(red: 94/255.0, green: 25/255.0, blue: 20/255.0, alpha: 1.0)
        default:
            return UIColor(red: 94/255.0, green: 25/255.0, blue: 20/255.0, alpha: 1.0)
        }
    }
}

struct UserDefaultConstants {
    static let highScore = "HighScore"
}
