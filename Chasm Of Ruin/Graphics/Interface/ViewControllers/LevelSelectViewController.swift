//
//  LevelSelectViewController.swift
//  100Floors
//
//  Created by Sid Mani on 6/10/16.
//
//

import UIKit
import SpriteKit
import AVFoundation

class LevelSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var previousSelectedContainer:LevelContainer?
    var dismissDelegate:ModalDismissDelegate?
    private var itemWidth:CGFloat = 0
    @IBOutlet weak var levelCollection: UICollectionView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DescLabel: UILabel!
    
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!
    private var maxUnlockedLevel = defaultLevelHandler.maxUnlockedLevel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = levelCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blur)
        UIView.animate(withDuration: 0.5) {
            blur.effect = UIBlurEffect(style: .light)
        }
        blur.alpha = 0.5
        self.view.sendSubview(toBack: blur)
        itemWidth = layout.itemSize.width
        levelCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        levelCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        levelCollection.setContentOffset(CGPoint(x: CGFloat(maxUnlockedLevel) * itemWidth - levelCollection.contentInset.left, y: 0), animated: true)

        NotificationCenter.default.addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade" as NSNotification.Name, object: nil)

        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        
        setCurrencyLabels()
        selectCenterCell()
    }

    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewController(withIdentifier: "currencyPurchaseVC")
        self.present(cpvc, animated: true, completion: nil)
    }
    
    @IBAction func exit(_ sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC(nil)
        self.dismiss(animated: true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }

    ///////////////
    //Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaultLevelHandler.levelDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LevelContainer
        cell.setLevelTo(defaultLevelHandler.levelDict[(indexPath as NSIndexPath).item])
        if ((indexPath as NSIndexPath).item == maxUnlockedLevel && previousSelectedContainer == nil) {
            previousSelectedContainer = cell
            cell.setSelectedTo(true)
            NameLabel.text = cell.level!.mapName
            DescLabel.text = cell.level!.desc
        }
        return cell
    }
    
    @discardableResult func selectCenterCell() -> Bool {
        if let path = levelCollection.indexPathForItem(at: self.view.convert(levelCollection.center, to: levelCollection)), let container = (levelCollection.cellForItem(at: path) as? LevelContainer) {
            if (previousSelectedContainer != container) {
                previousSelectedContainer?.setSelectedTo(false)
                container.setSelectedTo(true)
                previousSelectedContainer = container
                NameLabel.text = container.level!.mapName
                DescLabel.text = (container.level!.unlocked ? container.level!.desc : "???")
                //set bg image
                return true
            }
        }
        return false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        selectCenterCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) == previousSelectedContainer) {
            if (previousSelectedContainer?.level?.unlocked == true) {
                defaultLevelHandler.currentLevel = (indexPath as NSIndexPath).item
                loadLevel(previousSelectedContainer!.level!)
            }
            else {
                let alert = storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
                alert.text = "This level is still locked! Unlock it for 25 Crystals?"
                alert.completion = {(response) in
                    if (response) {
                        if (defaultPurchaseHandler.makePurchase("UnlockLevel", withMoneyHandler: defaultMoneyHandler, currency: .chasmCrystal)) {
                            defaultLevelHandler.levelDict[(indexPath as NSIndexPath).item].unlocked = true
                            self.levelCollection.reloadItems(at: self.levelCollection.indexPathsForVisibleItems)
                            self.selectCenterCell()
                        }
                        else {
                            let alert = self.storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
                            alert.text = "You don't have enough Crystals for that! Buy some more?"
                            alert.completion = {(response) in
                                if (response) {
                                    let cpvc = self.storyboard!.instantiateViewController(withIdentifier: "currencyPurchaseVC")
                                    self.present(cpvc, animated: true, completion: nil)
                                }
                            }
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            collectionView.setContentOffset(CGPoint(x: CGFloat((indexPath as NSIndexPath).item) * itemWidth - collectionView.contentInset.left, y: 0), animated: true)
        }
    }
    
    func loadLevel(_ level:LevelHandler.LevelDefinition) {
        let igvc = storyboard?.instantiateViewController(withIdentifier: "igvc") as! InGameViewController
        igvc.modalTransitionStyle = .crossDissolve
        present(igvc, animated: true, completion: nil)
        previousSelectedContainer?.setSelectedTo(false)
        previousSelectedContainer = nil
        igvc.loadLevel(level)
    }

    @IBAction func exitToLevelSelect(_ segue:UIStoryboardSegue) {
        maxUnlockedLevel = defaultLevelHandler.maxUnlockedLevel()
        levelCollection.reloadData()
        levelCollection.setContentOffset(CGPoint(x: CGFloat(maxUnlockedLevel) * itemWidth - levelCollection.contentInset.left, y: 0), animated: true)
        globalAudioPlayer?.stop()
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "sunnydaysahead", ofType: "mp3")!)
        do {
            globalAudioPlayer = try AVAudioPlayer(contentsOf:url)
            globalAudioPlayer!.numberOfLoops = -1
            globalAudioPlayer!.prepareToPlay()
            if (audioEnabled) {
                globalAudioPlayer!.play()
            }
        } catch {
            print("Error getting the audio file")
        }

    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
}
