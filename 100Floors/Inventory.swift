//
//  Inventory.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

class Inventory {
    static private var inventory:[Item?] = [Item?]()
    static var inventoryFull:Bool {
        get{
            return inventory.count == inventory_size
        }
    }
    static var inventoryEmpty:Bool {
        get{
            return inventory.isEmpty
        }
    }
    static func addItem(item:Item, atIndex:Int)
    {
        if (!inventoryFull)
        {
            inventory.insert(item, atIndex: atIndex)
        }
        
    }
    static func consumeItem(atIndex:Int) -> Consumable?
    {
        if let item = inventory[atIndex] as? Consumable
        {
            inventory.removeAtIndex(atIndex)
            return item
        }
        //TODO: add throw here
        return nil
    }
    static func discardItem(atIndex:Int) -> Item?
    {
        if let item = inventory[atIndex]
        {
            inventory.removeAtIndex(atIndex)
            return item
        }
        return nil
    }
}
