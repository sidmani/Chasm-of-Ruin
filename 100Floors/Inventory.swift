//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

class Inventory {
    struct EquippedItems {
        static let shieldIndex = -2
        static let weaponIndex = -1
        static let enhancerIndex = -4
        static let skillIndex = -3
        var shield:Item?
        var weapon:Item?
        var enhancer:Item?
        var skill:Item?
        func totalStatChanges() -> Stats {
            var stats1 = nilStats, stats2 = nilStats, stats3 = nilStats, stats4 = nilStats
            if (shield != nil) {
                stats1 = shield!.statMods
            }
            if (weapon != nil) {
                stats2 = weapon!.statMods
            }
            if (enhancer != nil) {
                stats3 = enhancer!.statMods
            }
            if (skill != nil) {
                stats4 = skill!.statMods
            }
            return stats1 + stats2 + stats3 + stats4
        }
    }
    private var equipped:EquippedItems?
    private var inventory:[Item?]
    var Weapon:Item? {
        return inventory[0]
    }
    //INIT
    init(withEquipment:Bool, withSize: Int)
    {
        inventory = [Item?](count:withSize, repeatedValue: nil)
        if (withEquipment) {
            equipped = EquippedItems()
        }
    }
    
    init(fromItems:[Item], withEquipment:Bool, withSize:Int) {
        inventory = [Item?](count:withSize, repeatedValue: nil)
        for (var i = 0; i < inventory.count; i++) {
            setItem(i, toItem: fromItems[i])
        }
        if (withEquipment) {
            equipped = EquippedItems()
        }
    }
    func printInventory() {
        for (var i = 0; i < 8; i++) {
            print("Item \(i):")
            print(inventory[i]?.name)
            print("\n")
        }
    }
    //////////
    func swapItems(atIndexA: Int, atIndexB: Int) {
        if (atIndexA >= inventory.count || atIndexB >= inventory.count) {
            return
        }
        let temp = getItem(atIndexA)
        setItem(atIndexA, toItem: getItem(atIndexB))
        setItem(atIndexB, toItem: temp)
    }
    func getItem(atIndex:Int) -> Item? {
        if (atIndex > inventory.count) {
            return nil
        }
        switch(atIndex) {
        case EquippedItems.enhancerIndex:
            return equipped?.enhancer
        case EquippedItems.weaponIndex:
            return equipped?.weapon
        case EquippedItems.shieldIndex:
            return equipped?.shield
        case EquippedItems.skillIndex:
            return equipped?.skill
        default:
            return inventory[atIndex]
        }
    }
    func setItem(atIndex:Int, toItem:Item?) -> Item? {
        if (atIndex > inventory.count) {
            return nil
        }
        if (atIndex < 0) {
            return equipItem(toItem)
        }
        let out = inventory[atIndex]
        inventory[atIndex] = toItem
        return out
    }
    
    func removeItem(atIndex:Int) -> Item? {
        if (atIndex > inventory.count) {
            return nil
        }
        switch(atIndex) {
        case EquippedItems.enhancerIndex:
            let out = equipped?.enhancer
            equipped?.enhancer = nil
            return out
        case EquippedItems.weaponIndex:
            let out = equipped?.weapon
            equipped?.weapon = nil
            return out
        case EquippedItems.shieldIndex:
            let out = equipped?.shield
            equipped?.shield = nil
            return out
        case EquippedItems.skillIndex:
            let out = equipped?.skill
            equipped?.skill = nil
            return out
        default:
            let out = inventory[atIndex]
            inventory[atIndex] = nil
            return out
        }
    }
    func getEquip(type:ItemType) -> Item? {
        switch (type) {
        case .Weapon:
            return equipped?.weapon
        case .Shield:
            return equipped?.shield
        case .Enhancer:
            return equipped?.enhancer
        case .Skill:
            return equipped?.skill
        default:
            return nil
        }
    }
    func equipItem(new:Item?) -> Item? {
        if (equipped == nil || new == nil) {
            return new
        }
        switch (new!.type)
        {
        case .Shield:
            let old = equipped!.shield
            equipped!.shield = new
            return old
        case .Skill:
            let old = equipped!.skill
            equipped!.skill = new
            return old
        case .Weapon:
            let old = equipped!.weapon
            equipped!.weapon = new
            return old
        case .Enhancer:
            let old = equipped!.enhancer
            equipped!.enhancer = new
            return old
        default:
            return nil
        }
    }
}
