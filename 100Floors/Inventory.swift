//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

class Inventory {
    /*struct EquippedItems {
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
    }*/
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
    
    private var baseSize:Int
    private var inventory:[Item?]
    //INIT
    init(withEquipment:Bool, withSize: Int)
    {
        baseSize = withSize
        if (withEquipment) {
            inventory = [Item?](count:withSize+4, repeatedValue: nil)
        }
        else {
            inventory = [Item?](count:withSize, repeatedValue: nil)
        }
    }

    func printInventory() {
        for (var i = 0; i < inventory.count; i++) {
            print("Item \(i):")
            print(inventory[i]?.name)
            print(inventory[i]?.type)
            print("\n")
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
            if (toItem != nil && toItem!.type != .Enhancer) {
                return toItem
            }
            break
        case weaponIndex:
            if (toItem != nil && toItem!.type != .Weapon) {
                return toItem
            }
            break
        case shieldIndex:
            if (toItem != nil && toItem!.type != .Shield) {
                return toItem
            }
            break
        case skillIndex:
            if (toItem != nil && toItem!.type != .Skill) {
                return toItem
            }
            break
        default:
            break
        }
        let out = inventory[atIndex]
        inventory[atIndex] = toItem
        return out
    }
}
