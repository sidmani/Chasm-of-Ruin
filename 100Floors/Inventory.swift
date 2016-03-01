//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

class Inventory {
    private var inventory:[Item?]
    init(withSize: Int)
    {
        inventory = [Item?](count:withSize, repeatedValue: nil)
    }
    init(fromItems:[Item], withSize:Int) {
        inventory = [Item?](count:withSize, repeatedValue: nil)
        for (var i = 0; i < inventory.count; i++) {
            setItem(i, toItem: fromItems[i])
        }
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
}
