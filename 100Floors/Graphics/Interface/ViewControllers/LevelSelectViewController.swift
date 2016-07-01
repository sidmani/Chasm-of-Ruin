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
    private var itemWidth:CGFloat = 0
    @IBOutlet weak var levelCollection: UICollectionView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DescLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = levelCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = CGFloat.max
        itemWidth = layout.itemSize.width
        levelCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        levelCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        selectCenterCell()
    }
    
    ///////////////
    //Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaultLevelHandler.levelDict.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! LevelContainer
        cell.setLevelTo(defaultLevelHandler.levelDict[indexPath.item]!)
        if (indexPath.item == 0 && previousSelectedContainer == nil) {
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
                DescLabel.text = container.level!.desc
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
        if (collectionView.cellForItemAtIndexPath(indexPath) == previousSelectedContainer && previousSelectedContainer?.level?.unlocked == true) {
            defaultLevelHandler.currentLevel = indexPath.item
            loadLevel(previousSelectedContainer!.level!)
        }
        else {
            collectionView.setContentOffset(CGPointMake(CGFloat(indexPath.item) * itemWidth - collectionView.contentInset.left, 0), animated: true)
        }
    }
    
    func loadLevel(level:LevelHandler.LevelDefinition) {
        let igvc = storyboard?.instantiateViewControllerWithIdentifier("igvc") as! InGameViewController
        igvc.modalTransitionStyle = .CrossDissolve
        presentViewController(igvc, animated: true, completion: nil)
        igvc.loadLevel(level)
    }

    @IBAction func exitToLevelSelect(segue:UIStoryboardSegue) {
        levelCollection.reloadData()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}
