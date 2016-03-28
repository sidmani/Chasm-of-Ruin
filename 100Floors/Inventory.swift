//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//
let inventory_size = 8 // TODO: fix this (IAP)

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
    
    convenience init(fromElement:AEXMLElement) {
        self.init(withEquipment:(fromElement.attributes["equip"] == "true"), withSize:Int(fromElement.attributes["size"]!)!)
        if (fromElement["item"].all != nil) {
            for item in fromElement["item"].all! {
                switch (item.attributes["index"]!) {
                case "weapon":
                    self.setItem(weaponIndex, toItem: Weapon(withID: item.stringValue))
                case "shield":
                    self.setItem(shieldIndex, toItem: Shield(withID: item.stringValue))
                case "skill":
                    self.setItem(skillIndex, toItem: Skill(withID: item.stringValue))
                case "enhancer":
                    self.setItem(enhancerIndex, toItem: Enhancer(withID: item.stringValue))
                default:
                    self.setItem(Int(item.attributes["index"]!)!, toItem: Item.initHandler(item.stringValue))
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
        return out
    }
}
