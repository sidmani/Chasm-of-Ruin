//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

class Inventory {
    struct EquippedItems {
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
    
    //////////
    func swapItems(atIndexA: Int, atIndexB: Int) {
        if (atIndexA >= inventory.count || atIndexB >= inventory.count) {
            return
        }
        let temp = inventory[atIndexA]
        inventory[atIndexA] = inventory[atIndexB]
        inventory[atIndexB] = temp
    }
    func getItem(atIndex:Int) -> Item? {
        if (atIndex > inventory.count) {
            return nil
        }
        return inventory[atIndex]
    }
    func setItem(atIndex:Int, toItem:Item) -> Item? {
        if (atIndex > inventory.count) {
            return nil
        }
        let out = inventory[atIndex]
        inventory[atIndex] = toItem
        return out
    }
    
    func removeItem(atIndex:Int) -> Item? {
        if (atIndex > inventory.count) {
            return nil
        }
        let out = inventory[atIndex]
        inventory[atIndex] = nil
        return out
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
    func equipItem(new:Item) -> Item? {
        if (equipped == nil) {
            return new
        }
        switch (new.type)
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
