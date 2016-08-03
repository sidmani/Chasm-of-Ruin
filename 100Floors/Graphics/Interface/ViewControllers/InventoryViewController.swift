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
    
    var dismissDelegate:ModalDismissDelegate?
    
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
    
    var hasExecutedTutorial = true
    let popTip = AMPopTip()
    var popupNum = 0
    
    private var leftScrollBound:CGFloat = 0
    private var rightScrollBound:CGFloat = 0
    private var itemWidth:CGFloat = 0
    
    private var previousSelectedContainer:ItemContainer?
    
    private var currentItemIsButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = inventoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude

        let longPressGR = UILongPressGestureRecognizer()
        inventoryCollection.addGestureRecognizer(longPressGR)
        longPressGR.addTarget(self, action: #selector(handleLongPress))
        longPressGR.delegate = self
        longPressGR.minimumPressDuration = 0.5
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
        inventoryCollection.setContentOffset(CGPoint(x: leftScrollBound+itemWidth,y: 0), animated: false)

        
        currentItemView.contentMode = .scaleAspectFit
        currentItemView.layer.magnificationFilter = kCAFilterNearest
        
        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blur)
        UIView.animate(withDuration: 0.5) {
            blur.effect = UIBlurEffect(style: .light)
        }
        self.view.sendSubview(toBack: blur)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let layout = inventoryCollection.collectionViewLayout as! UICollectionViewFlowLayout
        rightScrollBound = layout.collectionViewContentSize.width - screenSize.width/2 - layout.itemSize.width/2
        if (!hasExecutedTutorial) {
            popTip.shouldDismissOnTapOutside = true
            popTip.shouldDismissOnTap = true
            
            popTip.popoverColor = ColorScheme.fillColor
            popTip.borderColor = ColorScheme.strokeColor
            popTip.borderWidth = 2.0
            
            popTip.actionAnimation = .float
            popTip.entranceAnimation = .scale
            popTip.exitAnimation = .scale
            popTip.dismissHandler = {[unowned self] in
                self.incrementTutorial()
            }
            incrementTutorial()
        }
    }
    
    /////////Tutorial/////////
    func incrementTutorial() {
        switch (popupNum) {
        case 0:
            popTip.showText("This is your inventory.", direction: .up, maxWidth: self.view.frame.width-50, in: self.view, fromFrame: CGRect(x: inventoryCollection.frame.minX, y: inventoryCollection.frame.minY + 20, width: inventoryCollection.frame.width, height: inventoryCollection.frame.height))
        case 1:
            popTip.showText("Press and drag an item to move it to a different slot.", direction: .up, maxWidth: self.view.frame.width-50, in: self.view, fromFrame: CGRect(x: inventoryCollection.frame.minX, y: inventoryCollection.frame.minY + 20, width: inventoryCollection.frame.width, height: inventoryCollection.frame.height))
        case 2:
            popTip.showText("The leftmost slot shows items on the ground. Use it to drop or pick up items.", direction: .up, maxWidth: self.view.frame.width-50, in: self.view, fromFrame: CGRect(x: inventoryCollection.frame.minX, y: inventoryCollection.frame.minY + 20, width: inventoryCollection.frame.width, height: inventoryCollection.frame.height))
        case 3:
            popTip.showText("Press this button to load or use the selected item.", direction: .up, maxWidth: EquipButton.frame.width*2, in: self.view, fromFrame: EquipButton.frame)
        case 4:
            popTip.showText("These display the individual stats for each item.", direction: .up, maxWidth: self.view.viewWithTag(10)!.frame.width-20, in: self.view, fromFrame: self.view.viewWithTag(10)!.frame)
            popTip.shouldDismissOnTapOutside = false
        case 5:
            popTip.showText("Swipe up to display your character's stats.", direction: .up, maxWidth: self.view.viewWithTag(10)!.frame.width-20, in: self.view, fromFrame: self.view.viewWithTag(10)!.frame)
            popTip.shouldDismissOnTapOutside = true
        case 6:
            popTip.showText("Now load armor and a weapon, and start playing!", direction: .none, maxWidth: self.view.frame.width-50, in: self.view, fromFrame: self.view.frame)
        default:
            break
        }
        popupNum += 1
    }
    
    
    func itemDropped(_ indexA:Int, indexB:Int) {
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
                groundBag?.removeFromParent()
                groundBag = nil
            }
        }
        else {
            inventory.swapItems(indexA, atIndexB: indexB)
        }
    }
    @IBAction func exit(_ sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC(self.groundBag)
        self.dismiss(animated: true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
    
    @IBAction func equipButtonPressed() {
        if let item = previousSelectedContainer?.item {
            if (item is Usable) {
                //do something
                (item as! Usable).use()
            }
            else if (item is Consumable) {
                thisCharacter.consumeItem(item as! Consumable)
                if (previousSelectedContainer!.correspondsToInventoryIndex == -2) {
                    groundBag?.removeFromParent()
                    groundBag = nil
                } else {
                    inventory.setItem(previousSelectedContainer!.correspondsToInventoryIndex, toItem: nil)
                }
            }
            else if (item is Sellable) {
                defaultPurchaseHandler.sellPurchasable(item, withMoneyHandler: defaultMoneyHandler)
                if (previousSelectedContainer!.correspondsToInventoryIndex == -2) {
                    groundBag?.removeFromParent()
                    groundBag = nil
                } else {
                    inventory.setItem(previousSelectedContainer!.correspondsToInventoryIndex, toItem: nil)
                }
            }
            else if (previousSelectedContainer!.correspondsToInventoryIndex != -2) {
                if (inventory.equipItem(previousSelectedContainer!.correspondsToInventoryIndex)) {
                    EquipButton.setTitle("Unload", for: UIControlState())
                }
                else {
                    EquipButton.setTitle("Load", for: UIControlState())
                }
            }
            inventoryCollection.reloadItems(at: inventoryCollection.indexPathsForVisibleItems)
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
                    DescriptionLabel.alpha = 0
                    if ((item as! Consumable).permanent) {
                        HPProgressView.modifierLabel.text = "\(Int(item.statMods.maxHealth))"
                        ManaProgressView.modifierLabel.text = "\(Int(item.statMods.maxMana))"
                        HPProgressView.setProgress(item.statMods.maxHealth/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                        ManaProgressView.setProgress(item.statMods.maxMana/StatLimits.SINGLE_ITEM_STAT_MAX, animated: true)
                        for view in StatsDisplay {
                            view.modifierLabel.text = view.modifierLabel.text! + "🔒"
                        }
                    }
                    for view in StatsDisplay {
                        if (view.progress != 0) {
                            view.alpha = 1
                        }
                        else {
                            view.alpha = 0.3
                        }
                    }
                    EquipButton.setTitle("Consume", for: UIControlState())
                }
                else if (item is Usable) {
                    for view in StatsDisplay {
                        view.alpha = 0
                    }
                    DescriptionLabel.alpha = 1
                    EquipButton.setTitle("Use", for: UIControlState())
                }
                else if (item is Sellable) {
                    for view in StatsDisplay {
                        view.alpha = 0
                    }
                    DescriptionLabel.alpha = 1
                    EquipButton.setTitle("Sell", for: UIControlState())
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
                        EquipButton.setTitle("Unload", for: UIControlState())
                    }
                    else {
                        EquipButton.setTitle("Load", for: UIControlState())
                    }
                }
                else if item is Skill {
                    for view in StatsDisplay {
                        view.alpha = 0
                    }
                    DescriptionLabel.alpha = 1
                    if (inventory.isEquipped(previousSelectedContainer!.correspondsToInventoryIndex)) {
                        EquipButton.setTitle("Unload", for: UIControlState())
                    }
                    else {
                        EquipButton.setTitle("Load", for: UIControlState())
                    }
                }
                
                DescriptionLabel.text = item.desc
                
                EquipButton.isEnabled = true
                EquipButton.alpha = 1

            }
            else {
                ItemNameLabel.text = "---"
                for view in StatsDisplay {
                    view.alpha = 0.3
                    view.setProgress(0, animated: true)
                }
                DescriptionLabel.alpha = 0
                DescriptionLabel.text = ""
                TypeLabel.text = ""
                EquipButton.isEnabled = false
                EquipButton.alpha = 0.3
            }
            
            if (previousSelectedContainer!.correspondsToInventoryIndex == -2 && !(previousSelectedContainer!.item is Consumable)) {
                EquipButton.isEnabled = false
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
            EquipButton.isEnabled = false
            EquipButton.alpha = 0.3
        }
    }

    ////////////////////////////
    //UICollectionView handling
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 + defaultPurchaseHandler.checkPurchase("addInventorySlot")
    }
    
    @IBAction func addMoreSlotsButtonPressed(_ sender:UIButton) {
        if (defaultPurchaseHandler.checkPurchase("addInventorySlot") < 4) {
            let alert = storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
            alert.text = "Purchase another inventory slot for 50 Crystals?"
            alert.completion = {(response) in
                if (response) {
                    if (defaultPurchaseHandler.makePurchase("addInventorySlot", withMoneyHandler: defaultMoneyHandler, currency: .chasmCrystal)) {
                        self.inventoryCollection.insertItems(at: [IndexPath.init(item: self.inventoryCollection.numberOfItems(inSection: 0)-1, section: 0)])
                        self.inventory.purchasedSlot()
                        if (defaultPurchaseHandler.checkPurchase("addInventorySlot") == 4) {
                            sender.isEnabled = false
                            sender.alpha = 0.3
                        }
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if ((indexPath as NSIndexPath).item == collectionView.numberOfItems(inSection: 0)-1) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AddSlots", for: indexPath)
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ItemContainer
            
            cell.updateIndex(((indexPath as NSIndexPath).item == 0 ? -2 : (indexPath as NSIndexPath).item - 1))
            if (cell.correspondsToInventoryIndex != currentIndex) {
                cell.resetItemView()
            }
            else {
                cell.itemView.isHidden = true
            }
        
            cell.isEquipped = inventory.isEquipped(cell.correspondsToInventoryIndex)
            cell.setItemTo(((indexPath as NSIndexPath).item == 0 ? groundBag?.item : inventory.getItem(cell.correspondsToInventoryIndex)))
            if ((indexPath as NSIndexPath).item == 1 && previousSelectedContainer == nil) {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.setContentOffset(CGPoint(x: CGFloat((indexPath as NSIndexPath).item) * itemWidth + leftScrollBound, y: 0), animated: true)
        if let container = (inventoryCollection.cellForItem(at: indexPath) as? ItemContainer), previousSelectedContainer == container {
            equipButtonPressed()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (selectCenterCell()) {
            updateInfoDisplay()
        }
    }
    
    @discardableResult func selectCenterCell() -> Bool {
        if let path = inventoryCollection.indexPathForItem(at: self.view.convert(inventoryCollection.center, to: inventoryCollection)) {
            if let container = (inventoryCollection.cellForItem(at: path) as? ItemContainer) {
                if (previousSelectedContainer != container) {
                    previousSelectedContainer?.setSelectedTo(false)
                    container.setSelectedTo(true)
                    previousSelectedContainer = container
                    return true
                }
                currentItemIsButton = false
            }
            else if (inventoryCollection.cellForItem(at: path) != nil && !currentItemIsButton) {
                previousSelectedContainer?.setSelectedTo(false)
                previousSelectedContainer = nil
                currentItemIsButton = true
                return true
            }
        }
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view is UIButton) {
            return false
        }
        return true
    }
    
    @IBAction func handleLongPress(_ recognizer:UILongPressGestureRecognizer) {
        if (recognizer.state == .began) {
            if let path = inventoryCollection.indexPathForItem(at: recognizer.location(in: self.inventoryCollection))
            {
                currentContainer = (inventoryCollection.cellForItem(at: path) as? ItemContainer)
                if (currentContainer?.item == nil) {
                    currentContainer = nil
                    return
                }
                currentIndex = currentContainer!.correspondsToInventoryIndex
                currentItemView.image = currentContainer!.itemView.image
                let bounds = currentContainer!.itemView.bounds
                
                currentItemView.bounds = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width*1.5, height: bounds.height*1.5)
                currentItemView.center = recognizer.location(in: self.view)
                currentContainer!.itemView.isHidden = true
        
                self.view.addSubview(currentItemView)
            }
        }
        else if (recognizer.state == .changed && currentItemView.image != nil) {
            let newLoc = recognizer.location(in: self.view)
            currentItemView.center = newLoc
            if (newLoc.x > 0.8*screenSize.width || newLoc.x < screenSize.width*0.2) {
                let offsetX = constrain((currentItemView.center.x-inventoryCollection.center.x)/7+inventoryCollection.contentOffset.x, lower: leftScrollBound, upper: rightScrollBound)
                inventoryCollection.setContentOffset(CGPoint(x:offsetX, y:0), animated: false)
            }
        }
        else if (recognizer.state == .ended) {
            if let path = inventoryCollection.indexPathForItem(at: recognizer.location(in: self.inventoryCollection)), let containerA = inventoryCollection.cellForItem(at: path) as? ItemContainer  {
                itemDropped(containerA.correspondsToInventoryIndex, indexB: currentIndex)
                currentIndex = -1
                inventoryCollection.reloadItems(at: inventoryCollection.indexPathsForVisibleItems)
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
    private func constrain(_ x:CGFloat, lower:CGFloat, upper:CGFloat) -> CGFloat{
        return max(lower, min(x,upper))
    }
}
