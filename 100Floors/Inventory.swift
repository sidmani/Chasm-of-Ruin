//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

class Inventory {
    private var inventory:[Item?] = [Item?]()
    init()
    {
        
    }
    var inventoryCount:Int {
        get{
            return inventory.count
        }
    }

    func addItem(item:Item, atIndex:Int) {
        if (inventoryCount < inventory_size)
        {
            inventory.insert(item, atIndex: atIndex)
        }
        
    }
    
    func removeItem(atIndex:Int) -> Item? {
        if let item = inventory[atIndex]
        {
            inventory.removeAtIndex(atIndex)
            return item
        }
        return nil
    }
}
