//
//  ViewController.swift
//  Ather2048
//
//  Created by Siva Sandeep on 07/08/21.
//

import UIKit

enum TapEvent {
    case right
    case left
}
let WINNING_SCORE: Int = 2048

class ViewController: UIViewController {
    @IBOutlet var screenTitle: UILabel!
    @IBOutlet var scoreView: UIView!
    @IBOutlet var highScoreLbl: UILabel!
    @IBOutlet var currentScoreLbl: UILabel!
    
    @IBOutlet var currentTileValue: UILabel!
    @IBOutlet var upcommingtileValue: UILabel!
    @IBOutlet var gameCollectionView: UICollectionView!
    
    @IBOutlet var flotingLbl: UILabel!
    @IBOutlet var wonTitle: UILabel!
    var widthOfCell = CGFloat(75.0) // default
    var numberOfItems = 4 // default and input taken from config screen
    var sizeOfFlotinglabel = CGFloat(0)
    private let viewModel = GameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.setNumberOfColumns(numberOfItems)
        defaultMatrix()
        self.viewModel.delegates = self
        sizeOfFlotinglabel = self.view.bounds.size.width/CGFloat(self.viewModel.getNumberOfColumns())
        // Do any additional setup after loading the view.
        viewModel.setCurrentTileNumber()
        viewModel.setUpcommingTileNumber()
        flotingLbl.text = "\(viewModel.getCurrentTileNumber())"
        currentTileValue.text = "\(viewModel.getCurrentTileNumber())"
        upcommingtileValue.text = "\(viewModel.getUpCommingTileNumbere())"
        if let score = UserDefaults.standard.integer(forKey: UserDefaultConstants.highScore) as? Int {
            highScoreLbl.text = score.description
        }
      
        wonTitle.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createBorders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let calculatedValForCell = self.gameCollectionView.bounds.size.width > self.gameCollectionView.bounds.size.height ?  self.gameCollectionView.bounds.size.height : self.gameCollectionView.bounds.size.width
        widthOfCell = calculatedValForCell/CGFloat(self.viewModel.getNumberOfColumns())
        self.gameCollectionView.reloadData()
        
        flotingLbl.frame = CGRect(x: 0, y: 66, width: sizeOfFlotinglabel, height: 40)
    }
  
    
    func defaultMatrix() {
        let result = viewModel.getDefaultArray()
        debugPrint("result is \(result)")
    }
    
    func createBorders() {
        self.highScoreLbl.layer.cornerRadius = 5
        self.highScoreLbl.layer.borderWidth = 0.8
        self.highScoreLbl.layer.borderColor = UIColor.black.cgColor
        
        self.currentScoreLbl.layer.cornerRadius = 5
        self.currentScoreLbl.layer.borderWidth = 0.8
        self.currentScoreLbl.layer.borderColor = UIColor.black.cgColor

    }
    @IBAction func leftMoveBtnClick(_ sender: UIButton) {
        self.moveFlotingLable(.left)

    }
    
    @IBAction func rightMoveBtnClick(_ sender: UIButton) {
        self.moveFlotingLable(.right)
    }
    
    @IBAction func placeCurrentTileBtnTap(_ sender: Any) {
        let lastIndex = self.viewModel.getLastEmptyPositionInColumn()
        debugPrint("Last Index is \(lastIndex)")
        if lastIndex >= 0 {
            self.viewModel.updateModelsList(lastIndex, withNumber: viewModel.getCurrentTileNumber())
            viewModel.checkAndAjustTiles(lastIndex)

            viewModel.setCurrentTileNumber(viewModel.getUpCommingTileNumbere())
            viewModel.setUpcommingTileNumber()
            flotingLbl.text = "\(viewModel.getCurrentTileNumber())"
            currentTileValue.text = "\(viewModel.getCurrentTileNumber())"
            upcommingtileValue.text = "\(viewModel.getUpCommingTileNumbere())"
        } else {
            debugPrint("No moves left move to another column")
        }
       
      
    }
    
    @IBAction func refreshGame(_ sender: Any) {
        self.viewModel.resetGame()
    }
    func moveFlotingLable(_ tap: TapEvent) {
        let currentFrame = flotingLbl.frame
        debugPrint(currentFrame)
        if tap == .left {
            // move to left
            if currentFrame.origin.x > 0 {
                let newFrame = CGRect(x: currentFrame.origin.x-sizeOfFlotinglabel, y: 66, width: sizeOfFlotinglabel, height: 40)
                self.adjustPostionOfFlotingLabel(newFrame)
                viewModel.setCurrentTileColumnIndex(true)
            } else {
                debugPrint("Ignore tap event")
            }
            debugPrint("Move to left")
        } else {
            // move to right
            if currentFrame.origin.x < self.view.bounds.width - sizeOfFlotinglabel {
                let newFrame = CGRect(x: currentFrame.origin.x+sizeOfFlotinglabel, y: 66, width: sizeOfFlotinglabel, height: 40)
                self.adjustPostionOfFlotingLabel(newFrame)
                viewModel.setCurrentTileColumnIndex(false)

            } else {
                debugPrint("Ignore tap event")
            }
            debugPrint("Move to right")
        }
    }
    
    func adjustPostionOfFlotingLabel(_ newFrame: CGRect) {
        UIView.animate(withDuration: 0.4) {
            self.flotingLbl.frame = newFrame
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfItemsInMatrix()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionViewCellID", for: indexPath) as? GameCollectionViewCell else {
            return GameCollectionViewCell()
        }
        let model = self.viewModel.gameModels[indexPath.row]
        cell.setupData(model.number)
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthOfCell, height: widthOfCell)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


extension ViewController: GameViewModelProtocol {
    func modelsUpdatedRefreshUI() {
        self.gameCollectionView.reloadData()
        currentScoreLbl.text = self.viewModel.getTotalScore().description
        if self.viewModel.getTotalScore() >= WINNING_SCORE {
            wonTitle.isHidden = false
        }
    }
    
    func gameResetDone() {
        self.gameCollectionView.reloadData()
        wonTitle.isHidden = true
        currentScoreLbl.text = self.viewModel.getTotalScore().description
    }
}
