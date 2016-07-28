//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//
import Foundation


class Inventory:NSObject, NSCoding {
    static let max_inventory_size = 12
    var stats:Stats = Stats.nilStats
    
    var weaponIndex:Int = -1
    var armorIndex:Int = -1
    var skillIndex:Int = -1
    var enhancerIndex:Int = -1
    
    var baseSize:Int
    private var inventory:[Item?]
    //INIT
    init(withSize: Int)
    {
        baseSize = withSize
        inventory = [Item?](count:12, repeatedValue: nil)
    }
    
    private var ignoreStats = false
    
    
    //////////
    func swapItems(atIndexA: Int, atIndexB: Int) {
        if (atIndexA >= baseSize || atIndexB >= baseSize || atIndexA < 0 || atIndexB < 0 || atIndexA == atIndexB) {
            return
        }
        let temp = getItem(atIndexA)
        setItem(atIndexA, toItem: getItem(atIndexB))
        setItem(atIndexB, toItem: temp)
        let isEquippedA = isEquipped(atIndexA)
        let isEquippedB = isEquipped(atIndexB)
        if (isEquippedA) {
            forceEquipItem(atIndexB)
        }
        if (isEquippedB) {
            forceEquipItem(atIndexA)
        }

    }

    func getItem(atIndex:Int) -> Item? {
        if (atIndex >= baseSize || atIndex < 0) {
            return nil
        }
        return inventory[atIndex]
    }
    
    func setItem(atIndex:Int, toItem:Item?) -> Item? { //UNSAFE: could cause crash due to setting an equipped index to the wrong type
        if (atIndex >= baseSize || atIndex < 0) {
            return toItem
        }
        let out = inventory[atIndex]
        inventory[atIndex] = toItem
        return out
    }
    
    private func forceEquipItem(atIndex:Int) {
        let item = getItem(atIndex)
        if (item is Weapon) {
            weaponIndex = atIndex
        }
        else if (item is Armor) {
            armorIndex = atIndex
        }
        else if (item is Skill) {
            skillIndex = atIndex
        }
        else if (item is Enhancer) {
            enhancerIndex = atIndex
        }
        if (!ignoreStats) {
            stats = getEquippedStats()
        }
    }
    
    func equipItem(atIndex:Int) -> Bool { //equipped -> true, unloaded -> false
        var equipped = false
        switch(atIndex) {
        case weaponIndex:
            weaponIndex = -1
        case enhancerIndex:
            enhancerIndex = -1
        case armorIndex:
            armorIndex = -1
        case skillIndex:
            skillIndex = -1
        default:
            let item = getItem(atIndex)
            if (item is Weapon) {
                weaponIndex = atIndex
                equipped = true
            }
            else if (item is Armor) {
                armorIndex = atIndex
                equipped = true
            }
            else if (item is Skill) {
                skillIndex = atIndex
                equipped = true
            }
            else if (item is Enhancer) {
                enhancerIndex = atIndex
                equipped = true
            }
        }
        if (!ignoreStats) {
            stats = getEquippedStats()
        }
        return equipped
    }
    
    func isEquipped(index:Int) -> Bool {
        return (weaponIndex == index || skillIndex == index || armorIndex == index || enhancerIndex == index)
    }
    
    func isFull() -> Bool {
        for i in 0..<baseSize {
            if (inventory[i] == nil) {
                return false
            }
        }
        return true
    }
    
    func lowestEmptySlot() -> Int {
        for i in 0..<baseSize {
            if (inventory[i] == nil) {
                return i
            }
        }
        return -1
    }
    
    func purchasedSlot() {
        baseSize = min(baseSize+1, Inventory.max_inventory_size)
    }
    
    private func getEquippedStats() -> Stats {
        var newStats = getItem(weaponIndex)?.statMods + getItem(armorIndex)?.statMods + getItem(skillIndex)?.statMods + getItem(enhancerIndex)?.statMods
        newStats.capAt(StatLimits.EQUIP_STAT_MAX)
        return newStats
    }
    
    func setTextureDict() {
        for item in inventory where item is Weapon {
            (item as! Weapon).setTextureDict()
        }
    }       
    /////NSCoding
    private struct PropertyKey {
        static let inventoryArrKey = "inventory"
        static let baseSizeKey = "baseSize"
        static let weaponKey = "wep"
        static let armorKey = "armor"
        static let skillKey = "skill"
        static let enhancerKey = "enhancer"
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let size = aDecoder.decodeObjectForKey(PropertyKey.baseSizeKey) as! Int
        self.init(withSize: size)
        let arr = aDecoder.decodeObjectForKey(PropertyKey.inventoryArrKey) as! NSArray        
        for i in 0..<arr.count {
            if let id = arr[i] as? String {
                self.setItem(i, toItem: Item.initHandlerID(id))
            }
        }
        self.weaponIndex = aDecoder.decodeObjectForKey(PropertyKey.weaponKey) as! Int
        self.armorIndex = aDecoder.decodeObjectForKey(PropertyKey.armorKey) as! Int
        self.skillIndex = aDecoder.decodeObjectForKey(PropertyKey.skillKey) as! Int
        self.enhancerIndex = aDecoder.decodeObjectForKey(PropertyKey.enhancerKey) as! Int
    }
    func encodeWithCoder(aCoder: NSCoder) {
        let arr:[AnyObject!] = self.inventory.map({$0 == nil ? NSNull():$0!.id})
        aCoder.encodeObject(arr, forKey: PropertyKey.inventoryArrKey)
        aCoder.encodeObject(baseSize, forKey: PropertyKey.baseSizeKey)
        aCoder.encodeObject(weaponIndex, forKey: PropertyKey.weaponKey)
        aCoder.encodeObject(armorIndex, forKey: PropertyKey.armorKey)
        aCoder.encodeObject(skillIndex, forKey: PropertyKey.skillKey)
        aCoder.encodeObject(enhancerIndex, forKey: PropertyKey.enhancerKey)
    }
}
