//
//  InventoryViewController.swift
//  100Floors
//
//  Created by Sid Mani on 2/28/16.
//
//
import UIKit

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var IndexLabel: UILabel!
    
    @IBOutlet weak var inventoryCollection: UICollectionView!
    
    private var currentItemView:UIImageView = UIImageView()
    private var currentContainer:ItemContainer?
    private var currentIndex:Int = -1
    ////////
    @IBOutlet weak var HPProgressView: VerticalProgressView!
    @IBOutlet weak var DEFProgressView: VerticalProgressView!
    @IBOutlet weak var ATKProgressView: VerticalProgressView!
    @IBOutlet weak var SPDProgressView: VerticalProgressView!
    @IBOutlet weak var DEXProgressView: VerticalProgressView!
    @IBOutlet weak var WISProgressView: VerticalProgressView!
    
    var StatsDisplay:[VerticalProgressView] = []
    
    var inventory:Inventory!

    var groundBag:ItemBag?
    var dropLoc:CGPoint!
    
    private var leftScrollBound:CGFloat!
    private var rightScrollBound:CGFloat!
    
    private var previousSelectedContainer:ItemContainer?
    private var selectedPath:NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = inventoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Horizontal
        
        let lpgr = UILongPressGestureRecognizer()
        inventoryCollection.addGestureRecognizer(lpgr)
        lpgr.addTarget(self, action: #selector(handleLongPress))
        
        StatsDisplay = [HPProgressView, DEFProgressView, ATKProgressView, SPDProgressView, DEXProgressView, WISProgressView]
        for view in StatsDisplay {
            view.backgroundColor = UIColor(colorLiteralRed: 0.85, green: 0.85, blue: 0.85, alpha: 0.5)
        }
        inventoryCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        inventoryCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)

        leftScrollBound = -inventoryCollection.contentInset.left
        rightScrollBound = inventoryCollection.collectionViewLayout.collectionViewContentSize().width - screenSize.width/2 - layout.itemSize.width/2
        
        inventoryCollection.setContentOffset(CGPointMake(leftScrollBound,0), animated: false)
        
        currentItemView.contentMode = .ScaleAspectFit
        currentItemView.layer.magnificationFilter = kCAFilterNearest
        
        selectCenterCell() //this doesn't work for some reason
    }
    
    func itemDropped(indexA:Int, indexB:Int) {
        if (indexA == indexB) {return}
        if (indexA == -2) {
            if let item = inventory.getItem(indexB) {
                inventory.setItem(indexB, toItem: groundBag?.item)
                groundBag?.setItemTo(nil)
                let newBag = ItemBag(withItem: item, loc: dropLoc)
                groundBag = newBag
                GameLogic.addObject(newBag)
            }
            else {
                groundBag = nil // this should never happen
            }
        }
        else if (indexB == -2) {
            if let item = inventory.getItem(indexA) {
                inventory.setItem(indexA, toItem: groundBag?.item)
                groundBag?.setItemTo(nil)
                let newBag = ItemBag(withItem: item, loc: dropLoc)
                groundBag = newBag
                GameLogic.addObject(newBag)
            }
            else {
                inventory.setItem(indexA, toItem: groundBag?.item)
                groundBag?.setItemTo(nil)
                groundBag = nil
            }
        }
        else {
            inventory.swapItems(indexA, atIndexB: indexB)
        }
    }
    

    
    func updateInfoDisplay() {
        print("run")
        if (previousSelectedContainer != nil) {
            if (previousSelectedContainer!.item != nil) {
                ItemNameLabel.text = previousSelectedContainer!.item!.name
                for i in 0..<StatsDisplay.count {
                    StatsDisplay[i].setProgress(Float(previousSelectedContainer!.item!.statMods.getIndex(i)/100), animated: true)
                }
            }
            else {
                ItemNameLabel.text = "---"
                for i in 0..<StatsDisplay.count {
                    StatsDisplay[i].setProgress(0, animated: true)
                }
            }
            IndexLabel.text = previousSelectedContainer!.correspondsToInventoryIndex == -2 ? "Ground" : ("Slot \(previousSelectedContainer!.correspondsToInventoryIndex + 1)")
        }
    }
    //////////////////////////////
    //UITableView handling
    
    ////////////////////////////
    //UICollectionView handling
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inventory_size + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ItemContainer
        cell.correspondsToInventoryIndex = (indexPath.item == 0 ? -2 : indexPath.item - 1)
      
        if (cell.correspondsToInventoryIndex != currentIndex) {
            cell.resetItemView()
        }
        else {
            cell.itemView.hidden = true
        }
        cell.setItemTo((indexPath.item == 0 ? groundBag?.item : inventory.getItem(cell.correspondsToInventoryIndex)))
        cell.setSelectedTo(false)
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let path = inventoryCollection.indexPathForItemAtPoint(self.view.convertPoint(inventoryCollection.center, toView: inventoryCollection)), container = (inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer) {
            if (container != previousSelectedContainer) {
                selectedPath = path
                previousSelectedContainer?.setSelectedTo(false)
                container.setSelectedTo(true)
                previousSelectedContainer = container
                updateInfoDisplay()
            }
        }
    }
 
    

    
    func selectCenterCell() {
        if let path = inventoryCollection.indexPathForItemAtPoint(self.view.convertPoint(inventoryCollection.center, toView: inventoryCollection)), container = (inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer) {
            selectedPath = path
            previousSelectedContainer?.setSelectedTo(false)
            container.setSelectedTo(true)
            previousSelectedContainer = container
        }
    }

    @IBAction func handleLongPress(recognizer:UILongPressGestureRecognizer) {
        let loc = recognizer.locationInView(self.inventoryCollection)
        let newLoc = recognizer.locationInView(self.view)
        if (recognizer.state == .Began) {
            if let path = inventoryCollection.indexPathForItemAtPoint(loc)
            {
                currentContainer = (inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer)
                if (currentContainer?.item == nil) {
                    currentContainer = nil
                    return
                }
                
                currentIndex = currentContainer!.correspondsToInventoryIndex
                currentItemView.image = currentContainer!.itemView.image
                let bounds = currentContainer!.itemView.bounds
                currentItemView.bounds = CGRectMake(bounds.minX, bounds.minY, bounds.width*1.5, bounds.height*1.5)
                currentItemView.center = newLoc
                
                currentContainer!.itemView.hidden = true
        
                self.view.addSubview(currentItemView)
            }
            
        }
        else if (recognizer.state == .Changed) {
            if (currentItemView.image != nil) {
                currentItemView.center = newLoc
                if (screenSize.width - newLoc.x < 0.2*screenSize.width || newLoc.x < screenSize.width*0.2) {
                    let offsetX = constrain((currentItemView.center.x-inventoryCollection.center.x)/7+inventoryCollection.contentOffset.x, lower: leftScrollBound, upper: rightScrollBound)
                    inventoryCollection.setContentOffset(CGPoint(x: offsetX, y:0), animated: false)
                }
            }
        }
        else if (recognizer.state == .Ended) {
            if let path = inventoryCollection.indexPathForItemAtPoint(loc), containerA = inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer  {
                itemDropped(containerA.correspondsToInventoryIndex, indexB: currentIndex)
                currentIndex = -1
                inventoryCollection.reloadItemsAtIndexPaths(inventoryCollection.indexPathsForVisibleItems())
                selectCenterCell()
                updateInfoDisplay()
            }
            else {
                currentIndex = -1
                currentContainer?.resetItemView()
            }
            currentItemView.removeFromSuperview()
            currentItemView.image = nil

        }
    
    }
    /////////////////////////
    
    
    
    private func constrain(x:CGFloat, lower:CGFloat, upper:CGFloat) -> CGFloat{
        return max(lower, min(x,upper))
    }
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
            return .Landscape
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}