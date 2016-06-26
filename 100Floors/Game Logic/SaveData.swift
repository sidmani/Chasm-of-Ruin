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
// money
class SaveData:NSObject, NSCoding {
    static let SaveDir = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let SaveURL = SaveDir.URLByAppendingPathComponent("SaveGame")
    
    static var currentSave:SaveData!
    
    static func loadSaveGame() -> Bool {
        if let currentSave = NSKeyedUnarchiver.unarchiveObjectWithFile(SaveData.SaveURL.path!) as? SaveData  {
            SaveData.currentSave = currentSave
            return true
        }
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
        static let moneyHandlerKey = "moneyHandler"
        static let purchaseHandlerKey = "purchaseHandler"
    }

    let character:ThisCharacter
    let levelHandler:LevelHandler
    let moneyHandler:MoneyHandler
    let purchaseHandler:InternalPurchaseHandler
    
    override init() {
        character = ThisCharacter()
        levelHandler = LevelHandler()
        moneyHandler = MoneyHandler()
        purchaseHandler = InternalPurchaseHandler()
    }
    
    required init?(coder aDecoder: NSCoder) {
        character = aDecoder.decodeObjectForKey(PropertyKey.charKey) as! ThisCharacter
        levelHandler = aDecoder.decodeObjectForKey(PropertyKey.levelHandlerKey) as! LevelHandler
        moneyHandler = aDecoder.decodeObjectForKey(PropertyKey.moneyHandlerKey) as! MoneyHandler
        purchaseHandler = aDecoder.decodeObjectForKey(PropertyKey.purchaseHandlerKey) as! InternalPurchaseHandler
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(character, forKey: PropertyKey.charKey)
        aCoder.encodeObject(levelHandler, forKey: PropertyKey.levelHandlerKey)
        aCoder.encodeObject(moneyHandler, forKey: PropertyKey.moneyHandlerKey)
    }
}

class MoneyHandler:NSCoding {
    private var ChasmCrystals:Int
    private var Coins:Int
    private var CrystalTransactions:[Int] = []
    
    init() {
        ChasmCrystals = 50
        Coins = 0
    }
    
    func addCoins(num:Int) -> Bool {
        if (num <= 0) {
            return false
        }
        Coins += num
        return true
    }
    
    func removeCoins(num:Int) -> Bool{
        if (num <= Coins) {
            Coins -= num
            return true
        }
        return false
    }
    
    func addCrystals(num:Int) -> Bool {
        if (num <= 0) {
            return false
        }
        ChasmCrystals += num
        return true
    }
    
    func removeCrystals(num:Int) -> Bool {
        if (num <= ChasmCrystals) {
            ChasmCrystals -= num
            return true
        }
        return false
    }
    
    func getCoins() -> Int {
        return Coins
    }
    
    func getCrystals() -> Int {
        return ChasmCrystals
    }
    
    func verifyTransactions() -> Bool {
        var sum = 0
        for x in CrystalTransactions {
            sum += x
        }
        if (sum != ChasmCrystals) {
            return false
        }
        return true
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        ChasmCrystals = aDecoder.decodeObjectForKey("ChasmCrystals") as! Int
        Coins = aDecoder.decodeObjectForKey("Coins") as! Int
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(ChasmCrystals, forKey: "ChasmCrystals")
        aCoder.encodeObject(Coins, forKey: "Coins")
    }
}

enum CurrencyType:Int {
    case ChasmCrystal = 0, Coin = 1
}

protocol Purchasable {
    var priceCoins:Int? { get }
    var priceCrystals:Int? { get }
    var designatedCurrencyType:CurrencyType? { get }
}

class InternalPurchaseHandler:NSCoding {
    
    private class Purchase: Purchasable {
        let priceCoins:Int?
        let priceCrystals:Int?
        let designatedCurrencyType:CurrencyType?
        var hasBeenPurchased:Int
        
        init(priceCoins:Int?, priceCrystals:Int?, designatedCurrencyType:CurrencyType? = nil) {
            self.priceCoins = priceCoins
            self.priceCrystals = priceCrystals
            self.designatedCurrencyType = designatedCurrencyType
            self.hasBeenPurchased = 0
        }
    }
    
    private var Purchases:[String:Purchase] = [
        "addInventorySlot":Purchase(priceCoins: nil, priceCrystals: 10, designatedCurrencyType: .ChasmCrystal)
    ]
    
    init() {
        
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        let hasBeenPurchasedDict = aDecoder.decodeObjectForKey("hbpd") as! [String:Int]
        for (key,_) in Purchases {
            Purchases[key]?.hasBeenPurchased = hasBeenPurchasedDict[key]!
        }
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        var hasBeenPurchasedDict:[String:Int] = [:]
        for (key,value) in Purchases {
            hasBeenPurchasedDict[key] = value.hasBeenPurchased
        }
        aCoder.encodeObject(hasBeenPurchasedDict, forKey: "hbpd")
    }
    
    func makePurchase(forKey:String, withMoneyHandler:MoneyHandler, currency:CurrencyType) -> Bool {
        if let purchase = Purchases[forKey] {
            if (makePurchase(purchase, withMoneyHandler: withMoneyHandler, currency: currency)) {
                purchase.hasBeenPurchased += 1
                return true
            }
        }
        return false
    }
    
    func makePurchase(ofPurchasable:Purchasable, withMoneyHandler:MoneyHandler, currency:CurrencyType) -> Bool {
        switch (currency) {
        case .ChasmCrystal:
            if (ofPurchasable.designatedCurrencyType != .Coin && withMoneyHandler.getCrystals() >= ofPurchasable.priceCrystals!) {
                return (withMoneyHandler.removeCrystals(ofPurchasable.priceCrystals!))
            }
        case .Coin:
            if (ofPurchasable.designatedCurrencyType != .ChasmCrystal && withMoneyHandler.getCoins() >= ofPurchasable.priceCoins!) {
                return (withMoneyHandler.removeCoins(ofPurchasable.priceCoins!))
            }
        }
        return false
    }

    func checkPurchase(forKey:String) -> Int {
        if let purchase = Purchases[forKey] {
            return purchase.hasBeenPurchased
        }
        return 0
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
        0:LevelDefinition(fileName:"Tutorial", mapName:"Tutorial", desc:"Description", thumb:"thumbnail", unlocked:true, free:true),
        1:LevelDefinition(fileName:"Tutorial", mapName:"Level 1", desc:"Description 2", thumb:"thumbnail", unlocked:false, free:true)
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