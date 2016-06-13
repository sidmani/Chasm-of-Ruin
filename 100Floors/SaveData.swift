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
        static let currStatsKey = "currStats"
        static let baseStatsKey = "baseStats"
        static let inventoryKey = "inventory"
        static let totalDamageKey = "totalDamage"
    }

    let currStats:Stats
    let baseStats:Stats
    let inventory:Inventory
    let totalDamageInflicted:Int
    init (currStats:Stats, baseStats:Stats, inventory:Inventory, totalDamageInflicted:Int) {
        self.currStats = currStats
        self.baseStats = baseStats
        self.inventory = inventory
        self.totalDamageInflicted = totalDamageInflicted
    }
    convenience init (fromCharacter:ThisCharacter) {
        self.init(currStats:fromCharacter.currStats, baseStats: fromCharacter.baseStats, inventory: fromCharacter.inventory, totalDamageInflicted: fromCharacter.totalDamageInflicted)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let currStats = Stats.statsFrom(aDecoder.decodeObjectForKey(PropertyKey.currStatsKey) as! NSArray)
        let baseStats = Stats.statsFrom(aDecoder.decodeObjectForKey(PropertyKey.baseStatsKey) as! NSArray)
        let inventory = aDecoder.decodeObjectForKey(PropertyKey.inventoryKey) as! Inventory
        let totalDamageInflicted = aDecoder.decodeObjectForKey(PropertyKey.totalDamageKey) as! Int
        self.init(currStats:currStats, baseStats: baseStats, inventory: inventory, totalDamageInflicted: totalDamageInflicted)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(inventory, forKey: PropertyKey.inventoryKey)
        aCoder.encodeObject(currStats.toArray(), forKey: PropertyKey.currStatsKey)
        aCoder.encodeObject(baseStats.toArray(), forKey: PropertyKey.baseStatsKey)
        aCoder.encodeObject(totalDamageInflicted, forKey: PropertyKey.totalDamageKey)
    }
}