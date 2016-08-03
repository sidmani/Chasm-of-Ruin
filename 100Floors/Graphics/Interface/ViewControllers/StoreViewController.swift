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
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blur)
        UIView.animate(withDuration: 0.5) {
            blur.effect = UIBlurEffect(style: .light)
        }
        self.view.sendSubview(toBack: blur)
        
        let layout = storeCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CGFloat.greatestFiniteMagnitude
        itemWidth = layout.itemSize.width

        storeCollection.contentInset.left = (screenSize.width/2 - layout.itemSize.width/2)
        storeCollection.contentInset.right = (screenSize.width/2 - layout.itemSize.width/2)
        storeCollection.backgroundColor = UIColor.clear
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
        self.dismiss(animated: true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
    
    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewController(withIdentifier: "currencyPurchaseVC") as! CurrencyPurchaseViewController
        cpvc.dismissDelegate = self
        self.present(cpvc, animated: true, completion: nil)
        self.view.subviews.forEach({(view) in view.isHidden = true})
    }
    
    func willDismissModalVC(_ object: AnyObject?) {
        self.view.subviews.forEach({(view) in view.isHidden = false})
    }
    
    func didDismissModalVC(_ object: AnyObject?) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemIDs.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ItemContainer
        cell.setItemTo(Item.initHandlerID(itemIDs[(indexPath as NSIndexPath).item]))
        if ((indexPath as NSIndexPath).item == 0 && previousSelectedContainer == nil) {
            previousSelectedContainer = cell
            cell.setSelectedTo(true)
            updateInfoDisplay()
        }
        else {
            cell.setSelectedTo(false)
        }

        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (selectCenterCell()) {
            updateInfoDisplay()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ItemContainer
        if (cell == previousSelectedContainer) {
            let alert = storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
            alert.text = "Purchase \(cell.item!.name) for \(cell.item!.designatedCurrencyType == .chasmCrystal ? "\(cell.item!.priceCrystals!) Chasm Crystals" : "\(cell.item!.priceCoins!) Coins")?"
            alert.completion = {(response) in
                if (response) {
                    if (thisCharacter.inventory.isFull()) {
                        let alert = self.storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
                        alert.text = "Your inventory is full! Replace item in slot \(thisCharacter.inventory.baseSize) (\(thisCharacter.inventory.getItem(thisCharacter.inventory.baseSize-1)!.name))?"
                        alert.completion = {(response) in
                            if (response) {
                                if (defaultPurchaseHandler.makePurchase(cell.item!, withMoneyHandler:defaultMoneyHandler, currency: cell.item!.designatedCurrencyType!)) {
                                    thisCharacter.inventory.setItem(thisCharacter.inventory.baseSize-1, toItem: cell.item!)
                                }
                                else {
                                    let alert = self.storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
                                    alert.text = "You don't have enough \(cell.item!.designatedCurrencyType == .chasmCrystal ? "Crystals" : "Coins") for that! Buy some more?"
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
                    else if (defaultPurchaseHandler.makePurchase(cell.item!, withMoneyHandler:defaultMoneyHandler, currency: cell.item!.designatedCurrencyType!)) {
                        if (thisCharacter.inventory.setItem(thisCharacter.inventory.lowestEmptySlot(), toItem: cell.item!) != nil) {
                            fatalError()
                        }
                    }
                    else {
                        let alert = self.storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
                        alert.text = "You don't have enough \(cell.item!.designatedCurrencyType == .chasmCrystal ? "Crystals" : "Coins") for that! Buy some more?"
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
        else {
            collectionView.setContentOffset(CGPoint(x: CGFloat((indexPath as NSIndexPath).item) * itemWidth - collectionView.contentInset.left, y: 0), animated: true)
        }
    }
    
    @discardableResult func selectCenterCell() -> Bool {
        if let path = storeCollection.indexPathForItem(at: self.view.convert(storeCollection.center, to: storeCollection)), let container = (storeCollection.cellForItem(at: path) as? ItemContainer) {
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
                case .coin:
                    CoinLabel.text = "\(item.priceCoins!)"
                    CoinLabel.isHidden = false
                    self.view.viewWithTag(6)!.isHidden = false
                    CrystalLabel.isHidden = true
                    self.view.viewWithTag(5)!.isHidden = true
                case .chasmCrystal:
                    CrystalLabel.text = "\(item.priceCrystals!)"
                    CoinLabel.isHidden = true
                    self.view.viewWithTag(6)!.isHidden = true
                    CrystalLabel.isHidden = false
                    self.view.viewWithTag(5)!.isHidden = false
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
