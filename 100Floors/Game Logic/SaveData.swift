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
var thisCharacter:ThisCharacter {
    return SaveData.currentSave!.character
}
var defaultLevelHandler:LevelHandler {
    return SaveData.currentSave!.levelHandler
}
var defaultMoneyHandler:MoneyHandler! {
    return SaveData.currentSave!.moneyHandler
}
var defaultPurchaseHandler:InternalPurchaseHandler! {
    return SaveData.currentSave!.purchaseHandler
}


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
        levelHandler = LevelHandler()
        moneyHandler = MoneyHandler()
        purchaseHandler = InternalPurchaseHandler()
        character = ThisCharacter(inventorySize: 8 + purchaseHandler.checkPurchase("addInventorySlot"))
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
    private var ChasmCrystals:Int {
        didSet {
        NSNotificationCenter.defaultCenter().postNotificationName("transactionMade", object: nil)
        }
    }
    private var Coins:Int {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("transactionMade", object: nil)
        }
    }
    private var CrystalTransactions:[Int] = []
    
    init() {
        ChasmCrystals = 500
        Coins = 500
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
        "addInventorySlot":Purchase(priceCoins: nil, priceCrystals: 50, designatedCurrencyType: .ChasmCrystal),
        "ReviveSelf":Purchase(priceCoins: nil, priceCrystals: 10, designatedCurrencyType: .ChasmCrystal),
        "UnlockLevel":Purchase(priceCoins: nil, priceCrystals: 25, designatedCurrencyType: .ChasmCrystal)
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
    
    func sellPurchasable(purchasable:Purchasable, withMoneyHandler:MoneyHandler) {
        withMoneyHandler.addCoins(purchasable.priceCoins!)
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
        let thumbFrames:Int
        var unlocked:Bool
        let free:Bool
        let unlocksIndex:Int
        var cleared:Bool
        var playCount:Int
        let numWaves:CGFloat
        var bestWave:CGFloat
        let bgMusic:String
        
        init(fileName:String, mapName:String, desc:String, thumb:String, thumbFrames:Int, unlocked:Bool, free:Bool, unlocksIndex:Int, playCount:Int = 0, cleared:Bool = false, numWaves:CGFloat, bestWave:CGFloat = 0, bgMusic:String = "") {
            self.fileName = fileName
            self.mapName = mapName
            self.desc = desc
            self.thumb = thumb
            self.thumbFrames = thumbFrames
            self.unlocked = unlocked
            self.free = free
            self.unlocksIndex = unlocksIndex
            self.playCount = playCount
            self.cleared = cleared
            self.bestWave = bestWave
            self.numWaves = numWaves
            self.bgMusic = bgMusic
        }
        
        @objc required init?(coder aDecoder: NSCoder) {
            unlocked = aDecoder.decodeObjectForKey("unlocked") as! Bool
            playCount = aDecoder.decodeObjectForKey("playcount") as! Int
            cleared = aDecoder.decodeObjectForKey("cleared") as! Bool
            bestWave = aDecoder.decodeObjectForKey("bestWave") as! CGFloat
            
            fileName = ""
            mapName = ""
            desc = ""
            thumb = ""
            thumbFrames = 0
            free = true
            unlocksIndex = -1
            numWaves = 0
            bgMusic = ""
        }
        
        @objc func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(unlocked, forKey: "unlocked")
            aCoder.encodeObject(playCount, forKey: "playcount")
            aCoder.encodeObject(cleared, forKey: "cleared")
            aCoder.encodeObject(bestWave, forKey: "bestWave")
        }
    }
    
    var levelDict:[LevelDefinition] = [
        LevelDefinition(fileName:"Tutorial", mapName:"Tutorial", desc:"Learn how to play!", thumb:"EyeBallA", thumbFrames: 8, unlocked:true, free:true, unlocksIndex: 1, numWaves:3, bgMusic: "throwawayfantasy"),
        LevelDefinition(fileName:"SunlitCaverns", mapName:"Sunlit Caverns", desc:"What horrors lurk in these caves?", thumb:"MonolithA", thumbFrames: 5, unlocked:false, free:true, unlocksIndex: 2, numWaves: 15, bgMusic: "familiarfaces"),
        LevelDefinition(fileName:"AncientRealm", mapName:"Ancient Realm", desc:"Beasts untouched for millenia have awakened within...", thumb:"DyeD", thumbFrames: 5, unlocked:false, free:true, unlocksIndex: 3, numWaves: 15, bgMusic: "goodasdead"),
        LevelDefinition(fileName:"DarkenedHall", mapName:"Darkened Hall", desc:"This cursed chamber has claimed the lives of all who enter.", thumb:"DiscA", thumbFrames: 5, unlocked:false, free:true, unlocksIndex: -1, numWaves:15, bgMusic: "modulatedmind")
    ]
    
    var currentLevel:Int!
    
    func getCurrentLevelAtlas() -> SKTextureAtlas {
        return SKTextureAtlas(named: "Level\(currentLevel)")
    }
    
    init() {
        
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        let newLevelDict = aDecoder.decodeObjectForKey("levelDict") as! [LevelDefinition]
        for i in 0..<newLevelDict.count {
            levelDict[i].unlocked = newLevelDict[i].unlocked
            levelDict[i].bestWave = newLevelDict[i].bestWave
            levelDict[i].cleared = newLevelDict[i].cleared
            levelDict[i].playCount = newLevelDict[i].playCount
        }
    }
    
    func maxUnlockedLevel() -> Int {
        var leastIndex = 0
        for i in 0..<defaultLevelHandler.levelDict.count {
            if (defaultLevelHandler.levelDict[i].cleared == true) {
                leastIndex = i+1
            }
        }
        return min(leastIndex, defaultLevelHandler.levelDict.count)
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(levelDict, forKey: "levelDict")
    }
    
    func levelCompleted(victory:Bool, wave:Int) {
        levelDict[currentLevel].playCount += 1
        levelDict[currentLevel].bestWave = CGFloat(wave)
        if (victory) {
            setLevelUnlocked(levelDict[currentLevel].unlocksIndex)
            levelDict[currentLevel].cleared = true
        }
    }
    
    func setLevelUnlocked(index:Int) {
        levelDict[index].unlocked = true
    }
}