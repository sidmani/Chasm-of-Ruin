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
    @IBOutlet weak var ManaProgressView: VerticalProgressView!
    
    @IBOutlet weak var EquipButton: UIButton!
    
    var StatsDisplay:[VerticalProgressView] = []
    
    var inventory:Inventory!

    var groundBag:ItemBag?
    var dropLoc:CGPoint!
    
    private var leftScrollBound:CGFloat = 0
    private var rightScrollBound:CGFloat = 0
    private var itemWidth:CGFloat = 0
    
    private var previousSelectedContainer:ItemContainer?
    
    private var currentItemIsButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = inventoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = CGFloat.max

        let longPressGR = UILongPressGestureRecognizer()
        inventoryCollection.addGestureRecognizer(longPressGR)
        longPressGR.addTarget(self, action: #selector(handleLongPress))
        longPressGR.delegate = self
        
        StatsDisplay = [HPProgressView, DEFProgressView, ATKProgressView, SPDProgressView, DEXProgressView, ManaProgressView]
        HPProgressView.label.text = "HP"
        ManaProgressView.label.text = "MANA"
        DEFProgressView.label.text = "DEF"
        SPDProgressView.label.text = "SPD"
        DEXProgressView.label.text = "DEX"
        ATKProgressView.label.text = "ATK"


        inventoryCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        inventoryCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        itemWidth = layout.itemSize.width
        leftScrollBound = -inventoryCollection.contentInset.left
        inventoryCollection.setContentOffset(CGPointMake(leftScrollBound,0), animated: false)

        
        currentItemView.contentMode = .ScaleAspectFit
        currentItemView.layer.magnificationFilter = kCAFilterNearest
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let layout = inventoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        rightScrollBound = layout.collectionViewContentSize().width - screenSize.width/2 - layout.itemSize.width/2
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
              
                HPProgressView.setProgress(item.statMods.health/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                ManaProgressView.setProgress(item.statMods.mana/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                ATKProgressView.setProgress(item.statMods.attack/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                DEFProgressView.setProgress(item.statMods.defense/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                SPDProgressView.setProgress(item.statMods.speed/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                DEXProgressView.setProgress(item.statMods.dexterity/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                
                if (item is Consumable) {
                    EquipButton.setTitle("Eat", forState: .Normal)
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
        }
        else if (currentItemIsButton) {
            for i in 0..<StatsDisplay.count {
                StatsDisplay[i].setProgress(0, animated: true)
            }
            ItemNameLabel.text = "Purchase More Inventory Slots"
            EquipButton.enabled = false
            EquipButton.alpha = 0.3
        }
    }

    ////////////////////////////
    //UICollectionView handling
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 + defaultPurchaseHandler.checkPurchase("addInventorySlot")
    }
    
    @IBAction func addMoreSlotsButtonPressed(sender:UIButton) {
        print("add more slots")
        if (defaultPurchaseHandler.checkPurchase("addInventorySlot") < 4) {
            if (defaultPurchaseHandler.makePurchase("addInventorySlot", withMoneyHandler: defaultMoneyHandler, currency: .ChasmCrystal)) {
                inventoryCollection.insertItemsAtIndexPaths([NSIndexPath.init(forItem: inventoryCollection.numberOfItemsInSection(0)-1, inSection: 0)])
                //if (defaultPurchaseHandler.checkPurchase("addInventorySlot") == 4) {
                //    inventoryCollection.deleteItemsAtIndexPaths([NSIndexPath.init(forItem: inventoryCollection.numberOfItemsInSection(0)-1, inSection: 0)])
                //}
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (indexPath.item == collectionView.numberOfItemsInSection(0)-1) {
            return collectionView.dequeueReusableCellWithReuseIdentifier("AddSlots", forIndexPath: indexPath)
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ItemContainer
            cell.updateIndex((indexPath.item == 0 ? -2 : indexPath.item - 1))
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
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.setContentOffset(CGPointMake(CGFloat(indexPath.item) * itemWidth + leftScrollBound, 0), animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (selectCenterCell()) {
            updateInfoDisplay()
        }
    }
    
    func selectCenterCell() -> Bool {
        if let path = inventoryCollection.indexPathForItemAtPoint(self.view.convertPoint(inventoryCollection.center, toView: inventoryCollection)) {
            if let container = (inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer) {
                if (previousSelectedContainer != container) {
                    previousSelectedContainer?.setSelectedTo(false)
                    container.setSelectedTo(true)
                    previousSelectedContainer = container
                    return true
                }
                currentItemIsButton = false
            }
            else if (inventoryCollection.cellForItemAtIndexPath(path) != nil) {
                if (!currentItemIsButton) {
                    previousSelectedContainer?.setSelectedTo(false)
                    previousSelectedContainer = nil
                    currentItemIsButton = true
                    return true
                }
            }
        }
        return false
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (touch.view is UIButton) {
            return false
        }
        return true
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