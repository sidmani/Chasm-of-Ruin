//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

class Inventory {
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
            inventory = [Item?](count:baseSize+4, repeatedValue: nil)
        }
        else {
            inventory = [Item?](count:baseSize, repeatedValue: nil)
        }
    }
    
    init(fromElement:AEXMLElement) {
        baseSize = Int(fromElement.attributes["size"]!)!
        if ((fromElement.attributes["equip"] == "true")) {
            inventory = [Item?](count:baseSize+4, repeatedValue: nil)
        }
        else {
            inventory = [Item?](count:baseSize, repeatedValue: nil)
        }
        if (fromElement["item"].all != nil) {
            for item in fromElement["item"].all! {
                switch (item.attributes["index"]!) {
                case "weapon":
                self.setItem(weaponIndex, toItem: Item(withID: item.stringValue))
                case "shield":
                    self.setItem(shieldIndex, toItem: Item(withID: item.stringValue))
                case "skill":
                    self.setItem(skillIndex, toItem: Item(withID: item.stringValue))
                case "enhancer":
                    self.setItem(enhancerIndex, toItem: Item(withID: item.stringValue))
                default:
                self.setItem(Int(item.attributes["index"]!)!, toItem: Item(withID: item.stringValue))
                }
            }
        }
    }
    
    /*func printInventory() {
        for (var i = 0; i < inventory.count; i++) {
            print("Item \(i):")
            print(inventory[i]?.name)
            print(inventory[i]?.type)
            print("\n")
        }
    }*/
    
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
