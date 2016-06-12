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
    
    let baseSize:Int
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
        if (atIndexA >= inventory.count || atIndexB >= inventory.count || atIndexA < 0 || atIndexB < 0 || atIndexA == atIndexB) {
            return
        }
        let temp = getItem(atIndexA)
        setItem(atIndexA, toItem: getItem(atIndexB))
        setItem(atIndexB, toItem: temp)
        if (isEquipped(atIndexA)) {
            equipItem(atIndexB)
        }
        else if (isEquipped(atIndexB)) {
            equipItem(atIndexA)
        }

    }

    func getItem(atIndex:Int) -> Item? {
        if (atIndex >= inventory.count || atIndex < 0) {
            return nil
        }
        return inventory[atIndex]
    }
    
    func setItem(atIndex:Int, toItem:Item?) -> Item? { //UNSAFE: could cause crash due to setting an equipped index to the wrong type
        if (atIndex >= inventory.count || atIndex < 0) {
            return toItem
        }
        let out = inventory[atIndex]
        inventory[atIndex] = toItem
      //  if (isEquipped(atIndex)) {
      //      equipItem(atIndex)
      //  }
        parent?.updateEquipStats()
        return out
    }
    
    func equipItem(atIndex:Int) -> Bool { //equipped -> true, unloaded -> false
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
            let item = getItem(atIndex)
            if (item is Weapon) {
                weaponIndex = atIndex
                return true
            }
            else if (item is Shield) {
                shieldIndex = atIndex
                return true
            }
            else if (item is Skill) {
                skillIndex = atIndex
                return true
            }
            else if (item is Enhancer) {
                enhancerIndex = atIndex
                return true
            }
        }
        return false
    }
    func isEquipped(index:Int) -> Bool {
        return (weaponIndex == index || skillIndex == index || shieldIndex == index || enhancerIndex == index) 
    }
    func dropAllItems() -> [Item?] {
        let allItems = inventory
        inventory = [Item?](count:baseSize, repeatedValue: nil)
        weaponIndex = -1
        skillIndex = -1
        shieldIndex = -1
        enhancerIndex = -1
        
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
