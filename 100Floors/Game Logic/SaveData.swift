//
//  SaveGame.swift
//  100Floors
//
//  Created by Sid Mani on 3/30/16.
//
//

import Foundation
//autosave
//things to save:
// equipment + inventory
// base stats
// char customization, if that's implemented
// 
class SaveData:NSObject, NSCoding {
    static let SaveDir = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let SaveURL = SaveDir.URLByAppendingPathComponent("SaveGame")
    
    static func loadCharacter() -> ThisCharacter {
        let currentSave = NSKeyedUnarchiver.unarchiveObjectWithFile(SaveData.SaveURL.path!) as? SaveData  //load save
        if (currentSave != nil) {
            return ThisCharacter(fromSaveData: currentSave!)
        }
        else {
            return ThisCharacter()
        }
        
    }
    
    static func saveGame() -> Bool {
        return NSKeyedArchiver.archiveRootObject(SaveData(fromCharacter: thisCharacter), toFile: SaveData.SaveURL.path!)
    }
    
    private struct PropertyKey {
        static let statsKey = "stats"
        static let inventoryKey = "inventory"
        static let totalDamageKey = "totalDamage"
    }

    let stats:Stats
    let inventory:Inventory
    let totalDamageInflicted:Int
    init (stats:Stats, inventory:Inventory, totalDamageInflicted:Int) {
        self.stats = stats
        self.inventory = inventory
        self.totalDamageInflicted = totalDamageInflicted
    }
    convenience init (fromCharacter:ThisCharacter) {
        self.init(stats: fromCharacter.stats, inventory: fromCharacter.inventory, totalDamageInflicted: fromCharacter.totalDamageInflicted)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let stats = Stats.statsFrom(aDecoder.decodeObjectForKey(PropertyKey.statsKey) as! NSArray)
        let inventory = aDecoder.decodeObjectForKey(PropertyKey.inventoryKey) as! Inventory
        let totalDamageInflicted = aDecoder.decodeObjectForKey(PropertyKey.totalDamageKey) as! Int
        self.init(stats: stats, inventory: inventory, totalDamageInflicted: totalDamageInflicted)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(inventory, forKey: PropertyKey.inventoryKey)
        aCoder.encodeObject(stats.toArray(), forKey: PropertyKey.statsKey)
        aCoder.encodeObject(totalDamageInflicted, forKey: PropertyKey.totalDamageKey)
    }
}