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
    
    @IBOutlet weak var GlobalHPProgressView: VerticalProgressView!
    @IBOutlet weak var GlobalDEFProgressView: VerticalProgressView!
    @IBOutlet weak var GlobalATKProgressView: VerticalProgressView!
    @IBOutlet weak var GlobalSPDProgressView: VerticalProgressView!
    @IBOutlet weak var GlobalDEXProgressView: VerticalProgressView!
    @IBOutlet weak var GlobalManaProgressView: VerticalProgressView!

    
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var TypeLabel: UILabel!
    
    @IBOutlet weak var EquipButton: UIButton!
    
    var StatsDisplay:[VerticalProgressView] = []
    
    var inventory = thisCharacter.inventory

    var groundBag:ItemBag?
    
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
       // inventoryCollection.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
        inventoryCollection.addGestureRecognizer(longPressGR)
        longPressGR.addTarget(self, action: #selector(handleLongPress))
        longPressGR.delegate = self
        
        StatsDisplay = [HPProgressView, DEFProgressView, ATKProgressView, SPDProgressView, DEXProgressView, ManaProgressView]
        DescriptionLabel.text = ""
        
        HPProgressView.label.text = "HP"
        ManaProgressView.label.text = "MANA"
        DEFProgressView.label.text = "DEF"
        SPDProgressView.label.text = "SPD"
        DEXProgressView.label.text = "DEX"
        ATKProgressView.label.text = "ATK"

        GlobalHPProgressView.label.text = "HP"
        GlobalManaProgressView.label.text = "MANA"
        GlobalDEFProgressView.label.text = "DEF"
        GlobalSPDProgressView.label.text = "SPD"
        GlobalDEXProgressView.label.text = "DEX"
        GlobalATKProgressView.label.text = "ATK"
        updatePermanentStatsDisplay()
        
        HPProgressView.fillDoneColor = ColorScheme.HPColor
        ATKProgressView.fillDoneColor = ColorScheme.ATKColor
        DEFProgressView.fillDoneColor = ColorScheme.DEFColor
        ManaProgressView.fillDoneColor = ColorScheme.MANAColor
        DEXProgressView.fillDoneColor = ColorScheme.DEXColor
        SPDProgressView.fillDoneColor = ColorScheme.SPDColor

        GlobalHPProgressView.fillDoneColor = ColorScheme.HPColor
        GlobalATKProgressView.fillDoneColor = ColorScheme.ATKColor
        GlobalDEFProgressView.fillDoneColor = ColorScheme.DEFColor
        GlobalManaProgressView.fillDoneColor = ColorScheme.MANAColor
        GlobalDEXProgressView.fillDoneColor = ColorScheme.DEXColor
        GlobalSPDProgressView.fillDoneColor = ColorScheme.SPDColor

        for view in StatsDisplay {
            view.alpha = 0
        }
        DescriptionLabel.alpha = 0

        inventoryCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        inventoryCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        itemWidth = layout.itemSize.width
        leftScrollBound = -inventoryCollection.contentInset.left
        inventoryCollection.setContentOffset(CGPointMake(leftScrollBound,0), animated: false)

        
        currentItemView.contentMode = .ScaleAspectFit
        currentItemView.layer.magnificationFilter = kCAFilterNearest
        
        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blur)
        UIView.animateWithDuration(0.5) {
            blur.effect = UIBlurEffect(style: .Light)
        }
        self.view.sendSubviewToBack(blur)
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
                let newBag = ItemBag(withItem: item, loc: thisCharacter.position)
                groundBag = newBag
            }
        }
        else if (indexB == -2) {
            if let item = inventory.getItem(indexA) {
                inventory.setItem(indexA, toItem: groundBag?.item)
                groundBag?.setItemTo(nil)
                let newBag = ItemBag(withItem: item, loc: thisCharacter.position)
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
                (item as! Usable).use()
            }
            else if (item is Consumable) {
                thisCharacter.consumeItem(item as! Consumable)
                inventory.setItem(previousSelectedContainer!.correspondsToInventoryIndex, toItem: nil)
            }
            else if (item is Sellable) {
                defaultPurchaseHandler.sellPurchasable(item, withMoneyHandler: defaultMoneyHandler)
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
            updateInfoDisplay()
            updatePermanentStatsDisplay()
        }
    }
    
    func updatePermanentStatsDisplay() {
        let stats = thisCharacter.getStats()
        GlobalHPProgressView.setProgress(stats.health/stats.maxHealth, animated: true)
        GlobalManaProgressView.setProgress(stats.mana/stats.maxMana, animated: true)
        GlobalATKProgressView.setProgress(stats.attack/StatLimits.GLOBAL_STAT_MAX, animated: true)
        GlobalDEFProgressView.setProgress(stats.defense/StatLimits.GLOBAL_STAT_MAX, animated: true)
        GlobalSPDProgressView.setProgress(stats.speed/StatLimits.GLOBAL_STAT_MAX, animated: true)
        GlobalDEXProgressView.setProgress(stats.dexterity/StatLimits.GLOBAL_STAT_MAX, animated: true)

        GlobalHPProgressView.modifierLabel.text = "\(Int(stats.health))/\(Int(stats.maxHealth))"
        GlobalManaProgressView.modifierLabel.text = "\(Int(stats.mana))/\(Int(stats.maxMana))"
        GlobalATKProgressView.modifierLabel.text = (stats.attack == StatLimits.GLOBAL_STAT_MAX ? "MAX" : "\(Int(stats.attack))")
        GlobalDEFProgressView.modifierLabel.text = (stats.defense == StatLimits.GLOBAL_STAT_MAX ? "MAX" : "\(Int(stats.defense))")
        GlobalSPDProgressView.modifierLabel.text = (stats.speed == StatLimits.GLOBAL_STAT_MAX ? "MAX" : "\(Int(stats.speed))")
        GlobalDEXProgressView.modifierLabel.text = (stats.dexterity == StatLimits.GLOBAL_STAT_MAX ? "MAX" : "\(Int(stats.dexterity))")
    }
    
    func updateInfoDisplay() {
        if (previousSelectedContainer != nil) {
            if let item = previousSelectedContainer!.item {
                ItemNameLabel.text = item.name
                TypeLabel.text = item.getType()
                HPProgressView.setProgress(item.statMods.health/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                ManaProgressView.setProgress(item.statMods.mana/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                ATKProgressView.setProgress(item.statMods.attack/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                DEFProgressView.setProgress(item.statMods.defense/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                SPDProgressView.setProgress(item.statMods.speed/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                DEXProgressView.setProgress(item.statMods.dexterity/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                
                HPProgressView.modifierLabel.text = "\(Int(item.statMods.health))"
                ManaProgressView.modifierLabel.text = "\(Int(item.statMods.mana))"
                ATKProgressView.modifierLabel.text = "\(Int(item.statMods.attack))"
                DEFProgressView.modifierLabel.text = "\(Int(item.statMods.defense))"
                SPDProgressView.modifierLabel.text = "\(Int(item.statMods.speed))"
                DEXProgressView.modifierLabel.text = "\(Int(item.statMods.dexterity))"

                if (item is Consumable) {
                    for view in StatsDisplay {
                        view.alpha = 1
                    }
                    DescriptionLabel.alpha = 0
                    if ((item as! Consumable).permanent) {
                        for view in StatsDisplay {
                            view.modifierLabel.text = view.modifierLabel.text! + "🔒"
                        }
                    }
                    else {
                        ATKProgressView.alpha = 0.3
                        DEFProgressView.alpha = 0.3
                        SPDProgressView.alpha = 0.3
                        DEXProgressView.alpha = 0.3
                    }
                   // else {
                  //      for view in StatsDisplay {
                  //          view.modifierLabel.text = view.modifierLabel.text! + "⏱"
                  //      }
                  //  }
                    EquipButton.setTitle("Consume", forState: .Normal)
                }
                else if (item is Usable) {
                    for view in StatsDisplay {
                        view.alpha = 0
                    }
                    DescriptionLabel.alpha = 1
                    EquipButton.setTitle("Use", forState: .Normal)
                }
                else if (item is Sellable) {
                    for view in StatsDisplay {
                        view.alpha = 0
                    }
                    DescriptionLabel.alpha = 1
                    EquipButton.setTitle("Sell", forState: .Normal)
                }
                else if (item is Weapon || item is Armor || item is Enhancer) {
                    HPProgressView.alpha = 0
                    ManaProgressView.alpha = 0
                    ATKProgressView.alpha = 1
                    DEFProgressView.alpha = 1
                    SPDProgressView.alpha = 1
                    DEXProgressView.alpha = 1
                    DescriptionLabel.alpha = 1
                    if (inventory.isEquipped(previousSelectedContainer!.correspondsToInventoryIndex)) {
                        EquipButton.setTitle("Unload", forState: .Normal)
                    }
                    else {
                        EquipButton.setTitle("Equip", forState: .Normal)
                    }
                }
                else if item is Skill {
                    for view in StatsDisplay {
                        view.alpha = 0
                    }
                    DescriptionLabel.alpha = 1
                    if (inventory.isEquipped(previousSelectedContainer!.correspondsToInventoryIndex)) {
                        EquipButton.setTitle("Unload", forState: .Normal)
                    }
                    else {
                        EquipButton.setTitle("Equip", forState: .Normal)
                    }
                }
                
                DescriptionLabel.text = item.desc
                
                EquipButton.enabled = true
                EquipButton.alpha = 1

            }
            else {
                ItemNameLabel.text = "---"
                for view in StatsDisplay {
                    view.alpha = 0
                }
                DescriptionLabel.alpha = 0
                DescriptionLabel.text = ""
                TypeLabel.text = ""
                EquipButton.enabled = false
                EquipButton.alpha = 0.3
            }
            
            if (previousSelectedContainer!.correspondsToInventoryIndex == -2) {
                EquipButton.enabled = false
                EquipButton.alpha = 0.3
            }
        }
        else if (currentItemIsButton) {
            for view in StatsDisplay {
                view.alpha = 0
            }
            DescriptionLabel.alpha = 0
            DescriptionLabel.text = ""
            TypeLabel.text = ""
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
        if (defaultPurchaseHandler.checkPurchase("addInventorySlot") < 4) {
            let alert = storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
            alert.text = "Purchase another inventory slot for 50 Crystals?"
            alert.completion = {(response) in
                if (response) {
                    if (defaultPurchaseHandler.makePurchase("addInventorySlot", withMoneyHandler: defaultMoneyHandler, currency: .ChasmCrystal)) {
                        self.inventoryCollection.insertItemsAtIndexPaths([NSIndexPath.init(forItem: self.inventoryCollection.numberOfItemsInSection(0)-1, inSection: 0)])
                        //TODO: actually increase inventory size
                        if (defaultPurchaseHandler.checkPurchase("addInventorySlot") == 4) {
                            sender.enabled = false
                            sender.alpha = 0.3
                        }
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
    
   /* func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC")
        self.presentViewController(cpvc, animated: true, completion: nil)
    }*/
    
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
            else if (inventoryCollection.cellForItemAtIndexPath(path) != nil && !currentItemIsButton) {
              //  if (!currentItemIsButton) {
                previousSelectedContainer?.setSelectedTo(false)
                previousSelectedContainer = nil
                currentItemIsButton = true
                return true
              //  }
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
        if (recognizer.state == .Began) {
            if let path = inventoryCollection.indexPathForItemAtPoint(recognizer.locationInView(self.inventoryCollection))
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
                currentItemView.center = recognizer.locationInView(self.view)
                currentContainer!.itemView.hidden = true
        
                self.view.addSubview(currentItemView)
            }
        }
        else if (recognizer.state == .Changed && currentItemView.image != nil) {
        //    if (currentItemView.image != nil) {
            let newLoc = recognizer.locationInView(self.view)
            currentItemView.center = newLoc
            if (newLoc.x > 0.8*screenSize.width || newLoc.x < screenSize.width*0.2) {
                let offsetX = constrain((currentItemView.center.x-inventoryCollection.center.x)/7+inventoryCollection.contentOffset.x, lower: leftScrollBound, upper: rightScrollBound)
                inventoryCollection.setContentOffset(CGPoint(x:offsetX, y:0), animated: false)
            }
       //     }
        }
        else if (recognizer.state == .Ended) {
            if let path = inventoryCollection.indexPathForItemAtPoint(recognizer.locationInView(self.inventoryCollection)), containerA = inventoryCollection.cellForItemAtIndexPath(path) as? ItemContainer  {
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
    ////////////////////////
    private func constrain(x:CGFloat, lower:CGFloat, upper:CGFloat) -> CGFloat{
        return max(lower, min(x,upper))
    }
}