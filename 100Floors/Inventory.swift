//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//
import Foundation

let inventory_size = 8 // TODO: fix this (IAP)

class Inventory:NSObject, NSCoding {
    
    var weaponIndex:Int = -1
    var shieldIndex:Int = -1
    var skillIndex:Int = -1
    var enhancerIndex:Int = -1
    
    private let baseSize:Int
    private var inventory:[Item?]
    private var parent:Entity?
    
    func setParent(to:Entity?) {
        parent = to
    }
    //INIT
    init(withSize: Int)
    {
        baseSize = withSize
        inventory = [Item?](count:baseSize, repeatedValue: nil)
    }
    
    convenience init(fromElement:AEXMLElement) { //Remove this, inventory already implements NSCoding
        self.init(withSize:Int(fromElement.attributes["size"]!)!)
        if (fromElement["item"].all != nil) {
            for item in fromElement["item"].all! {
                switch (item.attributes["index"]!) {
                case "weapon":
                    self.setItem(weaponIndex, toItem: Item.initHandlerID(item.stringValue))
                case "shield":
                    self.setItem(shieldIndex, toItem: Item.initHandlerID(item.stringValue))
                case "skill":
                    self.setItem(skillIndex, toItem: Item.initHandlerID(item.stringValue))
                case "enhancer":
                    self.setItem(enhancerIndex, toItem: Item.initHandlerID(item.stringValue))
                default:
                    self.setItem(Int(item.attributes["index"]!)!, toItem: Item.initHandlerID(item.stringValue))
                }
            }
        }
    }
    
    //////////
    func swapItems(atIndexA: Int, atIndexB: Int) {
        if (atIndexA >= inventory.count || atIndexB >= inventory.count || atIndexA < 0 || atIndexB < 0) {
            return
        }
        let temp = getItem(atIndexA)
        setItem(atIndexA, toItem: getItem(atIndexB))
        setItem(atIndexB, toItem: temp)
    }

    func getItem(atIndex:Int) -> Item? {
        if (atIndex >= inventory.count || atIndex < 0) {
            return nil
        }
        return inventory[atIndex]
    }
    
    func setItem(atIndex:Int, toItem:Item?) -> Item? {
        if (atIndex >= inventory.count || atIndex < 0) {
            return toItem
        }
        let out = inventory[atIndex]
        inventory[atIndex] = toItem
        parent?.updateEquipStats()
        return out
    }
    
    func equipItem(atIndex:Int) {
        switch(atIndex) {
        case weaponIndex:
            weaponIndex = -1
        case enhancerIndex:
            enhancerIndex = -1
        case shieldIndex:
            shieldIndex = -1
        case skillIndex:
            skillIndex = -1
        default:
            if (getItem(atIndex) as? Weapon) != nil {
                weaponIndex = atIndex
            }
            else if (getItem(atIndex) as? Shield) != nil {
                shieldIndex = atIndex
            }
            else if (getItem(atIndex) as? Skill) != nil {
                skillIndex = atIndex
            }
            else if (getItem(atIndex) as? Enhancer) != nil {
                enhancerIndex = atIndex
            }
        }
    }
    
    func dropAllItems() -> [Item?] {
        let size = inventory.count
        let allItems = inventory
        inventory = [Item?](count:size, repeatedValue: nil)
        return allItems
    }
    
    func dropAllExceptInventory() -> [Item?] {
        var droppedItems:[Item?] = []
        for i in 0..<baseSize {
            if (i != skillIndex && i != weaponIndex && i != enhancerIndex && i != shieldIndex) {
                droppedItems.append(inventory[i])
                inventory[i] = nil
            }
        }
        return droppedItems
    }
    
    /////NSCoding
    private struct PropertyKey {
        static let inventoryArrKey = "inventory"
        static let baseSizeKey = "baseSize"
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let size = aDecoder.decodeObjectForKey(PropertyKey.baseSizeKey) as! Int
        self.init(withSize: size)
        let arr = aDecoder.decodeObjectForKey(PropertyKey.inventoryArrKey) as! NSArray        
        for i in 0..<arr.count {
            self.setItem(i, toItem: arr[i] as? Item)
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        let arr:[AnyObject!] = self.inventory.map({$0 == nil ? NSNull():$0})
        aCoder.encodeObject(arr, forKey: PropertyKey.inventoryArrKey)
        aCoder.encodeObject(baseSize, forKey: PropertyKey.baseSizeKey)
    }
}
