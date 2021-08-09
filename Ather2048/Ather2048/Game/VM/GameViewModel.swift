//
//  GameViewModel.swift
//  Ather2048
//
//  Created by Siva Sandeep on 07/08/21.
//

import UIKit

protocol GameViewModelProtocol {
    func modelsUpdatedRefreshUI()
    func gameResetDone()
}

class GameViewModel: NSObject {
    var delegates: GameViewModelProtocol?
    let numbersList = [2,4] //,8,16,32,64 this is the list of random numbers which we are picking to show curernt number and upcomming number.
    private var totalItems = 16 // default.
    private var matrixSize = 4 // default size of matrix is 5*5
    
    private var currentTileNumber = 0
    private var upcommingTitleNumber = 0
    
    
    private var totalScore = 0
    
    private var currentTileColumnIndex = 0
    var gameModels = [GameModel]()
    /*
     input config
     */
    func setNumberOfColumns(_ size: Int){
        self.matrixSize = size
        calculateTotalMartixSize()
    }
    
    private func calculateTotalMartixSize() {
        totalItems = self.matrixSize * self.matrixSize
    }
    /*
     get
     */
    func getNumberOfColumns() -> Int {
        return self.matrixSize
    }
    
    func getNumberOfItemsInMatrix() -> Int {
        return totalItems
    }
    
    func setCurrentTileColumnIndex(_ isMovedLeft: Bool) {
        if isMovedLeft {
            currentTileColumnIndex -= 1
        } else {
            currentTileColumnIndex += 1
        }
    }
  
    func getTotalScore() -> Int{
        return totalScore
    }
    
    func getDefaultArray() {
        gameModels.removeAll()
        for index in 0..<totalItems {
            let indexPositionInMatrix = CalculateSurrondingIndexes.getPostionForIndex(index, matrixSize: matrixSize)
            let result = CalculateSurrondingIndexes.getSurroundedIndexes(index, matrixSize: matrixSize)
            let model = GameModel(number: 0, position: indexPositionInMatrix, sourrendedPostions: result)
            gameModels.append(model)
        }
    }
    
    
    func getLastEmptyPositionInColumn() -> Int {
        let listofLastAvailableIndexs = gameModels.filter({$0.number == 0 && $0.position.column == self.currentTileColumnIndex})
        let assorder = listofLastAvailableIndexs.sorted(by: {$0.position.row < $1.position.row}).last
        if let lastElement = assorder {
            let availableindex = lastElement.position.row * matrixSize + lastElement.position.column
            return availableindex
        }
        return -1
    }
    
    
    func checkForAnyPossibleMoves() -> Bool {
        let listofLastAvailableIndexs = gameModels.filter({$0.number == 0})
        if listofLastAvailableIndexs.count == 0 {
            return false
        }
        return true
    }
    
    func updateModelsList(_ index: Int, withNumber: Int) {
       let model = gameModels[index]
        let newModel = GameModel(number: withNumber, position: model.position, sourrendedPostions: model.sourrendedPostions)
        gameModels[index] = newModel
        self.delegates?.modelsUpdatedRefreshUI()
    }
    
    
    func checkAndAjustTiles(_ index: Int) {
     //   let result =  calculateNewModelsWithCalculations(index)
        let result =  calculateNewModelsWithCalculationsAlteration(index)
        if !result.recursiveNeeded {
            self.delegates?.modelsUpdatedRefreshUI()
        } else {
            if result.index > 0 {
                checkAndAjustTiles(result.index)
            }
        }
    }
    
    func calculateNewModelsWithCalculations(_ index: Int) -> (recursiveNeeded:Bool , index:Int){
        debugPrint("index for this iteration is \(index)")
        let item = gameModels[index]
        debugPrint("item for this iteration is \(item)")
        var numberInt = [Int]()
        var isbottomAvailable = false
        if item.sourrendedPostions.topIndex > 0 {
            let model = gameModels[item.sourrendedPostions.topIndex]
            if gameModels[item.sourrendedPostions.topIndex].number == item.number {
                numberInt.append(gameModels[item.sourrendedPostions.topIndex].number)
                let newModel = self.createEmptyModel(item: model)
                gameModels[item.sourrendedPostions.topIndex] = newModel
            }
        }
        
        if item.sourrendedPostions.bottomIndex > 0 {
            let model = gameModels[item.sourrendedPostions.bottomIndex]
            if gameModels[item.sourrendedPostions.bottomIndex].number == item.number {
             numberInt.append(gameModels[item.sourrendedPostions.bottomIndex].number)
                let newModel = self.createEmptyModel(item: model)
                gameModels[item.sourrendedPostions.bottomIndex] = newModel
                isbottomAvailable = true
            }

        }
        
        if item.sourrendedPostions.leftIndex > 0 {
            let model = gameModels[item.sourrendedPostions.leftIndex]
            if gameModels[item.sourrendedPostions.leftIndex].number == item.number {
                numberInt.append(gameModels[item.sourrendedPostions.leftIndex].number)
                let newModel = self.createEmptyModel(item: model)
                gameModels[item.sourrendedPostions.leftIndex] = newModel
            }

        }
        
        if item.sourrendedPostions.righIndex > 0 {
            let model = gameModels[item.sourrendedPostions.righIndex]
            if gameModels[item.sourrendedPostions.righIndex].number == item.number {
                numberInt.append(gameModels[item.sourrendedPostions.righIndex].number)
                let newModel = self.createEmptyModel(item: model)
                gameModels[item.sourrendedPostions.righIndex] = newModel
            }

        }
        debugPrint("num int is \(numberInt) and total is \(numberInt.reduce(0, +))")
        let newTotalNumber = numberInt.reduce(0, +)  + item.number
       
        var nextIterationIndex = -1
        if newTotalNumber != item.number {
            totalScore = newTotalNumber + totalScore
            if let score = UserDefaults.standard.integer(forKey: UserDefaultConstants.highScore) as? Int {
                if totalScore >= score {
                    UserDefaults.standard.set(totalScore, forKey: UserDefaultConstants.highScore)
                }
            } else {
                UserDefaults.standard.set(totalScore, forKey: UserDefaultConstants.highScore)
            }
            if isbottomAvailable {
                let indexPositionInMatrix = CalculateSurrondingIndexes.getPostionForIndex(item.sourrendedPostions.bottomIndex, matrixSize: matrixSize)
                let result = CalculateSurrondingIndexes.getSurroundedIndexes(item.sourrendedPostions.bottomIndex, matrixSize: matrixSize)
                let newModel = GameModel(number: newTotalNumber, position:indexPositionInMatrix, sourrendedPostions: result)
                debugPrint("models before bottom availble \(gameModels) and newModel is \(newModel)")
                gameModels[item.sourrendedPostions.bottomIndex] = newModel
                let emptyModel = self.createEmptyModel(item: item)
                gameModels[index] = emptyModel
                nextIterationIndex = item.sourrendedPostions.bottomIndex
                debugPrint("models after bottom availble \(gameModels)")
            } else {
                let newModel = GameModel(number: newTotalNumber, position: item.position, sourrendedPostions: item.sourrendedPostions)
                gameModels[index] = newModel
                nextIterationIndex = index
            }
        }
    
        if numberInt.count == 0 {
            return (recursiveNeeded:false , index:nextIterationIndex)
        } else {
            return (recursiveNeeded:true , index:nextIterationIndex)
        }
    }
    
    
    func createEmptyModel(_ index: Int = 0, item: GameModel?) -> GameModel {
        if let model = item  {
            let emptyModel = GameModel(number: 0, position: model.position, sourrendedPostions: model.sourrendedPostions)
            return emptyModel
        }
        
        let indexPositionInMatrix = CalculateSurrondingIndexes.getPostionForIndex(index, matrixSize: matrixSize)
        let result = CalculateSurrondingIndexes.getSurroundedIndexes(index, matrixSize: matrixSize)
        let emptyModel = GameModel(number: 0, position: indexPositionInMatrix, sourrendedPostions: result)
        return emptyModel
    }
    
    func genereteRandomNumberFormList() -> Int {
        let randomIndex = Int.random(in: 0..<numbersList.count)
        return numbersList[randomIndex]
    }
    
    func setCurrentTileNumber(_ input: Int = 0) {
        if input > 0 {
            currentTileNumber = input
        } else {
            currentTileNumber = self.genereteRandomNumberFormList()

        }
    }
    
    func setUpcommingTileNumber(_ input :Int = 0) {
        if input > 0 {
            upcommingTitleNumber = input
        } else {
            upcommingTitleNumber = self.genereteRandomNumberFormList()

        }
    }
    
    func getCurrentTileNumber() -> Int {
        return currentTileNumber
    }
    
    func getUpCommingTileNumbere() -> Int {
        return upcommingTitleNumber
    }
    
    func resetGame() {
        setCurrentTileNumber()
        setUpcommingTileNumber()
        totalScore = 0
        setNumberOfColumns(self.matrixSize)
        getDefaultArray()
        self.delegates?.gameResetDone()
    }
}




extension GameViewModel {
    
    func calculateNewModelsWithCalculationsAlteration(_ index: Int) -> (recursiveNeeded:Bool , index:Int){
        debugPrint("index for this iteration is \(index)")
        let item = gameModels[index]
        debugPrint("item for this iteration is \(item)")
        var numberInt = [Int]()
        var isbottomAvailable = false
        
        
        
        if item.sourrendedPostions.topIndex > 0 {
            let model = gameModels[item.sourrendedPostions.topIndex]
            if gameModels[item.sourrendedPostions.topIndex].number == item.number {
                
                numberInt.append(gameModels[item.sourrendedPostions.topIndex].number)
                let newModel = self.createEmptyModel(item: model)
                gameModels[item.sourrendedPostions.topIndex] = newModel
            }
        }
        
        if item.sourrendedPostions.bottomIndex > 0 {
            let model = gameModels[item.sourrendedPostions.bottomIndex]
            if gameModels[item.sourrendedPostions.bottomIndex].number == item.number {
             numberInt.append(gameModels[item.sourrendedPostions.bottomIndex].number)
                let newModel = self.createEmptyModel(item: model)
                gameModels[item.sourrendedPostions.bottomIndex] = newModel
                isbottomAvailable = true
            }

        }
        
        if item.sourrendedPostions.leftIndex > 0 {
            let model = gameModels[item.sourrendedPostions.leftIndex]
            if gameModels[item.sourrendedPostions.leftIndex].number == item.number {
                
                numberInt.append(gameModels[item.sourrendedPostions.leftIndex].number)
                let newModel = self.createEmptyModel(item: model)
                gameModels[item.sourrendedPostions.leftIndex] = newModel
                /*
                 here need to play with left item top index
                 */
            }

        }
        
        if item.sourrendedPostions.righIndex > 0 {
            let model = gameModels[item.sourrendedPostions.righIndex]
            if gameModels[item.sourrendedPostions.righIndex].number == item.number {
                numberInt.append(gameModels[item.sourrendedPostions.righIndex].number)
                let newModel = self.createEmptyModel(item: model)
                gameModels[item.sourrendedPostions.righIndex] = newModel
                /*
                 here need to play with right item top index
                 */
            }

        }
        debugPrint("num int is \(numberInt) and total is \(numberInt.reduce(0, +))")
        let newTotalNumber = numberInt.reduce(0, +)  + item.number
       
        var nextIterationIndex = -1
        if newTotalNumber != item.number {
            totalScore = newTotalNumber + totalScore
            if let score = UserDefaults.standard.integer(forKey: UserDefaultConstants.highScore) as? Int {
                if totalScore >= score {
                    UserDefaults.standard.set(totalScore, forKey: UserDefaultConstants.highScore)
                }
            } else {
                UserDefaults.standard.set(totalScore, forKey: UserDefaultConstants.highScore)
            }
            if isbottomAvailable {
                let indexPositionInMatrix = CalculateSurrondingIndexes.getPostionForIndex(item.sourrendedPostions.bottomIndex, matrixSize: matrixSize)
                let result = CalculateSurrondingIndexes.getSurroundedIndexes(item.sourrendedPostions.bottomIndex, matrixSize: matrixSize)
                let newModel = GameModel(number: newTotalNumber, position:indexPositionInMatrix, sourrendedPostions: result)
                gameModels[item.sourrendedPostions.bottomIndex] = newModel
                let emptyModel = self.createEmptyModel(item: item)
                gameModels[index] = emptyModel
                nextIterationIndex = item.sourrendedPostions.bottomIndex
            } else {
                let newModel = GameModel(number: newTotalNumber, position: item.position, sourrendedPostions: item.sourrendedPostions)
                gameModels[index] = newModel
                nextIterationIndex = index
            }
        }
        if numberInt.count == 0 {
            return (recursiveNeeded:false , index:nextIterationIndex)
        } else {
            return (recursiveNeeded:true , index:nextIterationIndex)
        }
    }
}
