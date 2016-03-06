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
            print(inventory[i]?.type)
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
            return toItem
        }
        switch(atIndex) {
        case EquippedItems.enhancerIndex:
            if (toItem == nil || toItem!.type == .Enhancer) {
                let out = equipped?.enhancer
                equipped?.enhancer = toItem
                return out
            }
            return toItem
        case EquippedItems.weaponIndex:
            if (toItem == nil || toItem!.type == .Weapon) {
                let out = equipped?.weapon
                equipped?.weapon = toItem
                return out
            }
            return toItem
        case EquippedItems.shieldIndex:
            if (toItem == nil || toItem!.type == .Shield) {
                let out = equipped?.shield
                equipped?.shield = toItem
                return out
            }
            return toItem
        case EquippedItems.skillIndex:
            if (toItem == nil || toItem!.type == .Skill) {
                let out = equipped?.skill
                equipped?.skill = toItem
                return out
            }
            return toItem
        default:
            let out = inventory[atIndex]
            inventory[atIndex] = toItem
            return out
        }
    }
}
