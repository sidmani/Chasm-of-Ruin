//
//  InventoryViewController.swift
//  100Floors
//
//  Created by Sid Mani on 2/28/16.
//
//
import UIKit

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var IndexLabel: UILabel!
    
    @IBOutlet weak var inventoryCollection: UICollectionView!
    
    private var currentItemView:UIImageView = UIImageView()
    private var currentContainer:ItemContainer?
    private var currentIndex:Int = -1
    ////////
   // @IBOutlet weak var HPProgressView: VerticalProgressView!
    @IBOutlet weak var DEFProgressView: VerticalProgressView!
    @IBOutlet weak var ATKProgressView: VerticalProgressView!
    @IBOutlet weak var SPDProgressView: VerticalProgressView!
    @IBOutlet weak var DEXProgressView: VerticalProgressView!
   // @IBOutlet weak var WISProgressView: VerticalProgressView!
    
    @IBOutlet weak var EquipButton: UIButton!
    

    var StatsDisplay:[VerticalProgressView] = []
    
    var inventory:Inventory!

    var groundBag:ItemBag?
    var dropLoc:CGPoint!
    
    private var leftScrollBound:CGFloat = 0
    private var rightScrollBound:CGFloat = 0
    
    private var previousSelectedContainer:ItemContainer?
    private var selectedPath:NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
       // GameLogic.setGameState(.InventoryMenu)
        let layout = inventoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Horizontal
        
        let lpgr = UILongPressGestureRecognizer()
        inventoryCollection.addGestureRecognizer(lpgr)
        lpgr.addTarget(self, action: #selector(handleLongPress))
        
        StatsDisplay = [DEFProgressView, ATKProgressView, SPDProgressView, DEXProgressView]


        inventoryCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        inventoryCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        
        leftScrollBound = -inventoryCollection.contentInset.left
        inventoryCollection.setContentOffset(CGPointMake(leftScrollBound,0), animated: false)

        
        currentItemView.contentMode = .ScaleAspectFit
        currentItemView.layer.magnificationFilter = kCAFilterNearest
        
    }
    override func viewDidAppear(animated: Bool) {
        let layout = inventoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        rightScrollBound = layout.collectionViewContentSize().width - screenSize.width/2 - layout.itemSize.width/2
        print("scroll bounds set")
    }
    func itemDropped(indexA:Int, indexB:Int) {
        if (indexA == indexB) {return}
        if (indexA == -2) {
            if let item = inventory.getItem(indexB) {
                if (inventory.isEquipped(indexB)) {
                    inventory.equipItem(indexB)
                }
                inventory.setItem(indexB, toItem: groundBag?.item)
                groundBag?.setItemTo(nil)
                let newBag = ItemBag(withItem: item, loc: dropLoc)
                groundBag = newBag
            }
            else {
                groundBag = nil // this should never happen
            }
        }
        else if (indexB == -2) {
            if let item = inventory.getItem(indexA) {
                if (inventory.isEquipped(indexB)) {
                    inventory.equipItem(indexB)
                }
                inventory.setItem(indexA, toItem: groundBag?.item)
                groundBag?.setItemTo(nil)
                let newBag = ItemBag(withItem: item, loc: dropLoc)
                groundBag = newBag
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
    
    @IBAction func equipButtonPressed(sender: AnyObject) {
        if let item = previousSelectedContainer?.item {
            if (item is Usable) {
                //do something
            }
            else if (item is Consumable) {
                thisCharacter.consumeItem(item as! Consumable)
                inventory.setItem(previousSelectedContainer!.correspondsToInventoryIndex, toItem: nil)
            }
            else {
                if (inventory.equipItem(previousSelectedContainer!.correspondsToInventoryIndex)) {
                    EquipButton.setTitle("Unload", forState: .Normal)
                }
                else {
                    EquipButton.setTitle("Equip", forState: .Normal)
                }
            }
            inventoryCollection.reloadItemsAtIndexPaths(inventoryCollection.indexPathsForVisibleItems())
            selectCenterCell()
        }
    }

    
    func updateInfoDisplay() {
        if (previousSelectedContainer != nil) {
            if let item = previousSelectedContainer!.item {
                ItemNameLabel.text = item.name
                //for i in 0..<StatsDisplay.count {
                //    StatsDisplay[i].setProgress(Float(item.statMods.getIndex(i)/100), animated: true)
                //}
                ATKProgressView.setProgress(Float(item.statMods.attack)/100, animated: true)
                DEFProgressView.setProgress(Float(item.statMods.defense)/100, animated: true)
                SPDProgressView.setProgress(Float(item.statMods.speed)/100, animated: true)
                DEXProgressView.setProgress(Float(item.statMods.dexterity)/100, animated: true)

                if (item is Consumable) {
                    EquipButton.setTitle("Consume", forState: .Normal)
                
                }
                else if (item is Usable) {
                    EquipButton.setTitle("Use", forState: .Normal)
                }
                else if (inventory.isEquipped(previousSelectedContainer!.correspondsToInventoryIndex)) {
                    EquipButton.setTitle("Unload", forState: .Normal)
                }
                else {
                    EquipButton.setTitle("Equip", forState: .Normal)
                }
                EquipButton.enabled = true
                EquipButton.alpha = 1

            }
            else {
                ItemNameLabel.text = "---"
                for i in 0..<StatsDisplay.count {
                    StatsDisplay[i].setProgress(0, animated: true)
                }
                EquipButton.enabled = false
                EquipButton.alpha = 0.3
            }
            if (previousSelectedContainer!.correspondsToInventoryIndex == -2) {
                EquipButton.enabled = false
                EquipButton.alpha = 0.3
            }
            IndexLabel.text = previousSelectedContainer!.correspondsToInventoryIndex == -2 ? "Ground" : "Slot \(previousSelectedContainer!.correspondsToInventoryIndex + 1)"
        }
    }
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
        cell.isEquipped = inventory.isEquipped(cell.correspondsToInventoryIndex)
        cell.setItemTo((indexPath.item == 0 ? groundBag?.item : inventory.getItem(cell.correspondsToInventoryIndex)))
        if (indexPath.item == 0 && previousSelectedContainer == nil) {
            previousSelectedContainer = cell
            cell.setSelectedTo(true)
            updateInfoDisplay()
        }
        else {
            cell.setSelectedTo(false)
        }
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (selectCenterCell()) {
            updateInfoDisplay()
        }
    }
    
    func selectCenterCell() -> Bool {
        if let path = inventoryCollection.indexPathForItemAtPoint(self.view.convertPoint(inventoryCollection.center, toView: inventoryCollection)), container = (inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer) {
            if (previousSelectedContainer != container) {
                selectedPath = path
                previousSelectedContainer?.setSelectedTo(false)
                container.setSelectedTo(true)
                previousSelectedContainer = container
                return true
            }
        }
        return false
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
                if (newLoc.x > 0.8*screenSize.width || newLoc.x < screenSize.width*0.2) {
                    let offsetX = constrain((currentItemView.center.x-inventoryCollection.center.x)/7+inventoryCollection.contentOffset.x, lower: leftScrollBound, upper: rightScrollBound)
                    inventoryCollection.setContentOffset(CGPoint(x:offsetX, y:0), animated: false)
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