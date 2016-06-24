//
//  SaveGame.swift
//  100Floors
//
//  Created by Sid Mani on 3/30/16.
//
//

import Foundation
import GameKit
//autosave
//things to save:
// character
// char customization, if that's implemented
// unlocked levels
//
class SaveData:NSObject, NSCoding {
    static let SaveDir = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let SaveURL = SaveDir.URLByAppendingPathComponent("SaveGame")
    
    static var currentSave:SaveData!
    
    static func loadSaveGame() -> Bool {
        if let currentSave = NSKeyedUnarchiver.unarchiveObjectWithFile(SaveData.SaveURL.path!) as? SaveData  {
            SaveData.currentSave = currentSave
            return true
        }//load save
        else {
            SaveData.currentSave = SaveData()
            return false
        }
    }

    static func saveGame() -> Bool {
       return NSKeyedArchiver.archiveRootObject(SaveData.currentSave, toFile: SaveData.SaveURL.path!)
    }
    
    private struct PropertyKey {
        static let charKey = "char"
        static let levelHandlerKey = "lvl"
    }

    let character:ThisCharacter
    let levelHandler:LevelHandler
    
    init (char:ThisCharacter, lvlHandler:LevelHandler) {
        character = char
        levelHandler = lvlHandler
    }

    override init() {
        character = ThisCharacter()
        levelHandler = LevelHandler()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(char: aDecoder.decodeObjectForKey(PropertyKey.charKey) as! ThisCharacter, lvlHandler: aDecoder.decodeObjectForKey(PropertyKey.levelHandlerKey) as! LevelHandler)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(character, forKey: PropertyKey.charKey)
        aCoder.encodeObject(levelHandler, forKey: PropertyKey.levelHandlerKey)
    }
}

class LevelHandler:NSCoding {
   
    class LevelDefinition:NSCoding {
        let fileName:String
        let mapName:String
        let desc:String
        let thumb:String
        var unlocked:Bool
        let free:Bool
        
        init(fileName:String, mapName:String, desc:String, thumb:String, unlocked:Bool, free:Bool) {
            self.fileName = fileName
            self.mapName = mapName
            self.desc = desc
            self.thumb = thumb
            self.unlocked = unlocked
            self.free = free
        }
        
        @objc required convenience init?(coder aDecoder: NSCoder) {
            let fileName = aDecoder.decodeObjectForKey("fileName") as! String
            let mapName = aDecoder.decodeObjectForKey("mapName") as! String
            let desc = aDecoder.decodeObjectForKey("desc") as! String
            let thumb = aDecoder.decodeObjectForKey("thumb") as! String
            let unlocked = aDecoder.decodeObjectForKey("unlocked") as! Bool
            let free = aDecoder.decodeObjectForKey("free") as! Bool
            self.init(fileName: fileName, mapName: mapName, desc: desc, thumb: thumb, unlocked: unlocked, free: free)
        }
        
        @objc func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(fileName, forKey: "fileName")
            aCoder.encodeObject(mapName, forKey: "mapName")
            aCoder.encodeObject(desc, forKey: "desc")
            aCoder.encodeObject(thumb, forKey: "thumb")
            aCoder.encodeObject(unlocked, forKey: "unlocked")
            aCoder.encodeObject(free, forKey: "free")
        }
    }
    
    var levelDict:[Int:LevelDefinition] = [
        0:LevelDefinition(fileName:"Tutorial", mapName:"Tutorial", desc:"Description", thumb:"thumbnail", unlocked:true, free:true)
    ]
    
    init() {
        
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        levelDict = aDecoder.decodeObjectForKey("levelDict") as! [Int:LevelDefinition]
        for (key, value) in levelDict {
            if (!value.free) {
                //verify purchases
            }
        }
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(levelDict, forKey: "levelDict")
    }
    
   
    func getAllLevels() -> [LevelDefinition] {
        return Array(levelDict.values)
    }
    
    func setLevelUnlocked(index:Int) {
        levelDict[index]?.unlocked = true
    }
}