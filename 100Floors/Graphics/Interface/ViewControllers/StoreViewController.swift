//
//  StoreViewController.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/10/16.
//
//

import Foundation
import UIKit
class StoreViewController: UIViewController, ModalDismissDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!
    
    @IBOutlet weak var ItemNameLabel:UILabel!
    @IBOutlet weak var TypeLabel:UILabel!
    @IBOutlet weak var DescriptionLabel:UILabel!
    
    @IBOutlet weak var HPProgressView: VerticalProgressView!
    @IBOutlet weak var DEFProgressView: VerticalProgressView!
    @IBOutlet weak var ATKProgressView: VerticalProgressView!
    @IBOutlet weak var SPDProgressView: VerticalProgressView!
    @IBOutlet weak var DEXProgressView: VerticalProgressView!
    @IBOutlet weak var ManaProgressView: VerticalProgressView!

    @IBOutlet weak var storeCollection: UICollectionView!
    private var previousSelectedContainer:ItemContainer?

    var dismissDelegate:ModalDismissDelegate?
    var alertCompletion: (Bool) -> () = {_ in }

    var StatsDisplay:[VerticalProgressView] = []
    var itemWidth:CGFloat = 0
    
    private var itemIDs = ["c11","c13","c12","c34","c35","c36","c37","c38"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blur)
        UIView.animateWithDuration(0.5) {
            blur.effect = UIBlurEffect(style: .Light)
        }
        self.view.sendSubviewToBack(blur)
        
        let layout = storeCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = CGFloat.max
        itemWidth = layout.itemSize.width

        storeCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        storeCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        storeCollection.backgroundColor = UIColor.clearColor()
        switch (thisCharacter.level) { //add items depending on char level
        case 1:
            break
        default:
            break
        }
        StatsDisplay = [HPProgressView, DEFProgressView, ATKProgressView, SPDProgressView, DEXProgressView, ManaProgressView]
        DescriptionLabel.text = ""
        
        HPProgressView.label.text = "HP"
        ManaProgressView.label.text = "MANA"
        DEFProgressView.label.text = "DEF"
        SPDProgressView.label.text = "SPD"
        DEXProgressView.label.text = "DEX"
        ATKProgressView.label.text = "ATK"
        HPProgressView.fillDoneColor = ColorScheme.HPColor
        ATKProgressView.fillDoneColor = ColorScheme.ATKColor
        DEFProgressView.fillDoneColor = ColorScheme.DEFColor
        ManaProgressView.fillDoneColor = ColorScheme.MANAColor
        DEXProgressView.fillDoneColor = ColorScheme.DEXColor
        SPDProgressView.fillDoneColor = ColorScheme.SPDColor
        
        selectCenterCell()
        
        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
    }
    
    @IBAction func exit() {
        self.dismissDelegate?.willDismissModalVC(nil)
        self.dismissViewControllerAnimated(true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
    
    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC") as! CurrencyPurchaseViewController
        cpvc.dismissDelegate = self
        self.presentViewController(cpvc, animated: true, completion: nil)
        self.view.subviews.forEach({(view) in view.hidden = true})
    }
    
    func willDismissModalVC(object: AnyObject?) {
        self.view.subviews.forEach({(view) in view.hidden = false})
    }
    
    func didDismissModalVC(object: AnyObject?) {
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemIDs.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ItemContainer
        cell.setItemTo(Item.initHandlerID(itemIDs[indexPath.item]))
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (selectCenterCell()) {
            updateInfoDisplay()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ItemContainer
        if (cell == previousSelectedContainer) {
            let alert = storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
            alert.text = "Purchase \(cell.item!.name) for \(cell.item!.designatedCurrencyType == .ChasmCrystal ? "\(cell.item!.priceCrystals!) Chasm Crystals" : "\(cell.item!.priceCoins!) Coins")?"
            alert.completion = {(response) in
                if (response) {
                    if (thisCharacter.inventory.isFull()) {
                        let alert = self.storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
                        alert.text = "Your inventory is full! Replace item in slot \(thisCharacter.inventory.baseSize) (\(thisCharacter.inventory.getItem(thisCharacter.inventory.baseSize-1)!.name))?"
                        alert.completion = {(response) in
                            if (response) {
                                if (defaultPurchaseHandler.makePurchase(cell.item!, withMoneyHandler:defaultMoneyHandler, currency: cell.item!.designatedCurrencyType!)) {
                                    thisCharacter.inventory.setItem(thisCharacter.inventory.baseSize-1, toItem: cell.item!)
                                }
                                else {
                                    let alert = self.storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
                                    alert.text = "You don't have enough \(cell.item!.designatedCurrencyType == .ChasmCrystal ? "Crystals" : "Coins") for that! Buy some more?"
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
                    else if (defaultPurchaseHandler.makePurchase(cell.item!, withMoneyHandler:defaultMoneyHandler, currency: cell.item!.designatedCurrencyType!)) {
                        if (thisCharacter.inventory.setItem(thisCharacter.inventory.lowestEmptySlot(), toItem: cell.item!) != nil) {
                            fatalError()
                        }
                    }
                    else {
                        let alert = self.storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
                        alert.text = "You don't have enough \(cell.item!.designatedCurrencyType == .ChasmCrystal ? "Crystals" : "Coins") for that! Buy some more?"
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
        else {
            collectionView.setContentOffset(CGPointMake(CGFloat(indexPath.item) * itemWidth - collectionView.contentInset.left, 0), animated: true)
        }
    }
    
    func selectCenterCell() -> Bool {
        if let path = storeCollection.indexPathForItemAtPoint(self.view.convertPoint(storeCollection.center, toView: storeCollection)), container = (storeCollection.cellForItemAtIndexPath(path) as? ItemContainer) {
            if (previousSelectedContainer != container) {
                previousSelectedContainer?.setSelectedTo(false)
                container.setSelectedTo(true)
                previousSelectedContainer = container
                //set bg image
                return true
            }
        }
        return false
    }
    
    func updateInfoDisplay() {
        if (previousSelectedContainer != nil) {
            if let item = previousSelectedContainer!.item {
                switch (item.designatedCurrencyType!) {
                case .Coin:
                    CoinLabel.text = "\(item.priceCoins!)"
                    CoinLabel.hidden = false
                    self.view.viewWithTag(6)!.hidden = false
                    CrystalLabel.hidden = true
                    self.view.viewWithTag(5)!.hidden = true
                case .ChasmCrystal:
                    CrystalLabel.text = "\(item.priceCrystals!)"
                    CoinLabel.hidden = true
                    self.view.viewWithTag(6)!.hidden = true
                    CrystalLabel.hidden = false
                    self.view.viewWithTag(5)!.hidden = false
                }
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
                }
                else if (item is Weapon || item is Armor || item is Enhancer) {
                    HPProgressView.alpha = 0
                    ManaProgressView.alpha = 0
                    ATKProgressView.alpha = 1
                    DEFProgressView.alpha = 1
                    SPDProgressView.alpha = 1
                    DEXProgressView.alpha = 1
                    DescriptionLabel.alpha = 1
                }
                else if item is Skill {
                    for view in StatsDisplay {
                        view.alpha = 0
                    }
                    DescriptionLabel.alpha = 1
                }
                DescriptionLabel.text = item.desc
            }
        }
    }
}