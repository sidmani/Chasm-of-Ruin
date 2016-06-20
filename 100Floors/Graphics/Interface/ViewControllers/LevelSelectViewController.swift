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

    @IBOutlet weak var levelCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = levelCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = CGFloat.max
        
        levelCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        levelCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
    }
    
    ///////////////
    //Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LevelDict.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! LevelContainer
        cell.setLevelTo(indexPath.item)
        if (indexPath.item == 0 && previousSelectedContainer == nil) {
            previousSelectedContainer = cell
            cell.setSelectedTo(true)
        }
        return cell
    }
    
    func selectCenterCell() -> Bool {
        if let path = levelCollection.indexPathForItemAtPoint(self.view.convertPoint(levelCollection.center, toView: levelCollection)), container = (levelCollection.cellForItemAtIndexPath(path) as? LevelContainer) {
            if (previousSelectedContainer != container) {
                previousSelectedContainer?.setSelectedTo(false)
                container.setSelectedTo(true)
                previousSelectedContainer = container
                return true
                //set name, description, etc labels
                //set bg image
            }
        }
        return false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        selectCenterCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       // selectCenterCell() //TODO: fix this, should be select @ point touched
        loadLevel(previousSelectedContainer!.level)
    }
    
    func loadLevel(index:Int) {
        let igvc = storyboard?.instantiateViewControllerWithIdentifier("igvc") as! InGameViewController
        igvc.level = index
        igvc.modalTransitionStyle = .CrossDissolve
        presentViewController(igvc, animated: true, completion:nil)
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
