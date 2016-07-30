//
//  LevelSelectViewController.swift
//  100Floors
//
//  Created by Sid Mani on 6/10/16.
//
//

import UIKit
import SpriteKit

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
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = CGFloat.max
        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blur)
        UIView.animateWithDuration(0.5) {
            blur.effect = UIBlurEffect(style: .Light)
        }
        blur.alpha = 0.5
        self.view.sendSubviewToBack(blur)
        itemWidth = layout.itemSize.width
        levelCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        levelCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        levelCollection.setContentOffset(CGPointMake(CGFloat(maxUnlockedLevel) * itemWidth - levelCollection.contentInset.left, 0), animated: true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade", object: nil)

        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        
        setCurrencyLabels()
        selectCenterCell()
    }

    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC")
        self.presentViewController(cpvc, animated: true, completion: nil)
    }
    
    @IBAction func exit(sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC(nil)
        self.dismissViewControllerAnimated(true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }

    ///////////////
    //Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaultLevelHandler.levelDict.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! LevelContainer
        cell.setLevelTo(defaultLevelHandler.levelDict[indexPath.item])
        if (indexPath.item == maxUnlockedLevel && previousSelectedContainer == nil) {
            previousSelectedContainer = cell
            cell.setSelectedTo(true)
            NameLabel.text = cell.level!.mapName
            DescLabel.text = cell.level!.desc
        }
        return cell
    }
    
    func selectCenterCell() -> Bool {
        if let path = levelCollection.indexPathForItemAtPoint(self.view.convertPoint(levelCollection.center, toView: levelCollection)), container = (levelCollection.cellForItemAtIndexPath(path) as? LevelContainer) {
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        selectCenterCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (collectionView.cellForItemAtIndexPath(indexPath) == previousSelectedContainer) {
            if (previousSelectedContainer?.level?.unlocked == true) {
                defaultLevelHandler.currentLevel = indexPath.item
                loadLevel(previousSelectedContainer!.level!)
            }
            else {
                let alert = storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
                alert.text = "This level is still locked! Unlock it for 25 Crystals?"
                alert.completion = {(response) in
                    if (response) {
                        if (defaultPurchaseHandler.makePurchase("UnlockLevel", withMoneyHandler: defaultMoneyHandler, currency: .ChasmCrystal)) {
                            defaultLevelHandler.levelDict[indexPath.item].unlocked = true
                            self.levelCollection.reloadItemsAtIndexPaths(self.levelCollection.indexPathsForVisibleItems())
                            self.selectCenterCell()
                        }
                        else {
                            let alert = self.storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
                            alert.text = "You don't have enough Crystals for that! Buy some more?"
                            alert.completion = {(response) in
                                if (response) {
                                    let cpvc = self.storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC")
                                    self.presentViewController(cpvc, animated: true, completion: nil)
                                }
                            }
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            collectionView.setContentOffset(CGPointMake(CGFloat(indexPath.item) * itemWidth - collectionView.contentInset.left, 0), animated: true)
        }
    }
    
    func loadLevel(level:LevelHandler.LevelDefinition) {
        let igvc = storyboard?.instantiateViewControllerWithIdentifier("igvc") as! InGameViewController
        igvc.modalTransitionStyle = .CrossDissolve
        presentViewController(igvc, animated: true, completion: nil)
        previousSelectedContainer?.setSelectedTo(false)
        previousSelectedContainer = nil
        igvc.loadLevel(level)
    }

    @IBAction func exitToLevelSelect(segue:UIStoryboardSegue) {
        maxUnlockedLevel = defaultLevelHandler.maxUnlockedLevel()
        levelCollection.reloadData()
        levelCollection.setContentOffset(CGPointMake(CGFloat(maxUnlockedLevel) * itemWidth - levelCollection.contentInset.left, 0), animated: true)
    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
}
