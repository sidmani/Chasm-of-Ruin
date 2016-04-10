//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//
let inventory_size = 8 // TODO: fix this (IAP)

class Inventory:NSObject, NSCoding {
    var weaponIndex:Int {
        return baseSize
    }
    var shieldIndex:Int {
        return baseSize + 1
    }
    var skillIndex:Int {
        return baseSize + 2
    }
    var enhancerIndex:Int {
        return baseSize + 3
    }
    
    private let baseSize:Int
    private var inventory:[Item?]
    private var parent:Entity?
    private var hasInventory:Bool
    
    func setParent(to:Entity?) {
        parent = to
    }
    //INIT
    init(withEquipment:Bool, withSize: Int)
    {
        baseSize = withSize
        hasInventory = withEquipment
        if (withEquipment) {
            inventory = [Item?](count:baseSize+4, repeatedValue: nil)
        }
        else {
            inventory = [Item?](count:baseSize, repeatedValue: nil)
        }
    }
    
    convenience init(fromElement:AEXMLElement) { //Remove this, inventory already implements NSCoding
        self.init(withEquipment:(fromElement.attributes["equip"] == "true"), withSize:Int(fromElement.attributes["size"]!)!)
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
        switch(atIndex) {
        case enhancerIndex:
            if (toItem != nil && !(toItem! is Enhancer)) {
                return toItem
            }
            break
        case weaponIndex:
            if (toItem != nil && !(toItem! is Weapon)) {
                return toItem
            }
            break
        case shieldIndex:
            if (toItem != nil && !(toItem! is Shield)) {
                return toItem
            }
            break
        case skillIndex:
            if (toItem != nil && !(toItem! is Skill)) {
                return toItem
            }
            break
        default:
            break
        }
        let out = inventory[atIndex]
        inventory[atIndex] = toItem
        parent?.updateEquipStats()
        return out
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
            droppedItems.append(inventory[i])
            inventory[i] = nil
        }
        return droppedItems
    }
    /////NSCoding
    private struct PropertyKey {
        static let inventoryArrKey = "inventory"
        static let baseSizeKey = "baseSize"
        static let hasInventoryKey = "hasInventory"
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let size = aDecoder.decodeObjectForKey(PropertyKey.baseSizeKey) as! Int
        let hasInventory = aDecoder.decodeObjectForKey(PropertyKey.hasInventoryKey) as! Bool
        self.init(withEquipment: hasInventory, withSize: size)
        let arr = aDecoder.decodeObjectForKey(PropertyKey.inventoryArrKey) as! NSArray
        for i in 0..<arr.count {
            self.setItem(i, toItem: arr[i] as? Item)
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        let arr:[AnyObject!] = self.inventory.map({$0 == nil ? NSNull():$0})
        aCoder.encodeObject(arr, forKey: PropertyKey.inventoryArrKey)
        aCoder.encodeObject(baseSize, forKey: PropertyKey.baseSizeKey)
        aCoder.encodeObject(hasInventory, forKey: PropertyKey.hasInventoryKey)
    }
}
