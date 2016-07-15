//
//  Item.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

import SpriteKit
// 6 basic kinds of item: weapon, skill, armor, enhancer, style, consumable
// skill: skill move
// weapon: fires projectiles
// armor: boosts DEF and potentially decreases SPD
// enhancer: boosts a stat while equipped
// style: changes appearance
// consumable: gives temporary or permanent stat changes

class Item:NSObject, NSCoding, Purchasable {
    private static let ItemTypeDict:[String:Item.Type] = [
        "Weapon":Weapon.self,
        "Consumable":Consumable.self,
        "Skill":Skill.self,
        "Armor":Armor.self,
        "Enhancer":Enhancer.self,
        "Sellable":Sellable.self,
        "Usable":Usable.self
    ]

    var statMods:Stats
    let name:String
    let desc:String
    let img: String
    
    var priceCoins: Int? = nil
    var priceCrystals: Int? = nil
    var designatedCurrencyType: CurrencyType? = nil
    
    required init(fromBase64:String) {
        fatalError()
    }
    
    init(statMods:Stats, name:String, description:String, img:String, priceCrystals:Int, priceCoins:Int, designatedCurrencyType:CurrencyType?) {
        self.statMods = statMods
        self.desc = description
        self.name = name
        self.img = img
        self.priceCoins = (priceCoins < 0 ? nil : priceCoins)
        self.priceCrystals = (priceCrystals < 0 ? nil : priceCrystals)
        self.designatedCurrencyType = designatedCurrencyType
    }
    
    static func initHandlerID(withID:String) -> Item {
        let thisItem = itemXML.root["item"].allWithAttributes(["id":withID])!.first!
        return ItemTypeDict[thisItem.attributes["type"]!]!.init(fromBase64: thisItem.stringValue)
        
    }
    //NSCoding
    private struct PropertyKey {
        static let statModsKey = "statMods"
        static let nameKey = "name"
        static let descriptionKey = "description"
        static let imgKey = "img"
        static let priceCoinsKey = "pricecoins"
        static let priceCrystalsKey = "pricecrystals"
        static let designatedTypeKey = "desigtype"
    }
    
    required init?(coder aDecoder: NSCoder) {
        statMods = Stats.statsFrom(aDecoder.decodeObjectForKey(PropertyKey.statModsKey) as! NSArray)
        name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        desc = aDecoder.decodeObjectForKey(PropertyKey.descriptionKey) as! String
        img = aDecoder.decodeObjectForKey(PropertyKey.imgKey) as! String
        priceCoins = aDecoder.decodeObjectForKey(PropertyKey.priceCoinsKey) as? Int
        priceCrystals = aDecoder.decodeObjectForKey(PropertyKey.priceCrystalsKey) as? Int
        if let rawVal = aDecoder.decodeObjectForKey(PropertyKey.designatedTypeKey) as? Int {
            designatedCurrencyType = CurrencyType(rawValue: rawVal)
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(statMods.toArray(), forKey: PropertyKey.statModsKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(description, forKey: PropertyKey.descriptionKey)
        aCoder.encodeObject(img, forKey: PropertyKey.imgKey)
        aCoder.encodeObject(priceCrystals, forKey: PropertyKey.priceCrystalsKey)
        aCoder.encodeObject(priceCoins, forKey: PropertyKey.priceCoinsKey)
        aCoder.encodeObject(designatedCurrencyType?.rawValue, forKey: PropertyKey.designatedTypeKey)
    }
    func getType() -> String {
        return ""
    }
}

 class Weapon: Item {
    
    let projectile:String
    private let range:CGFloat
    let projectileSpeed:CGFloat
    let projectileReflects:Bool
    var statusCondition:(condition:StatusCondition,probability:CGFloat)? = nil
    var angles:[CGFloat] = []
    required init(fromBase64:String) {
        let optArr = fromBase64.splitBase64IntoArray("|")
        // "projectile name, # projectiles, range, projectile speed, projectile reflects, status condition, probability, statMod in b64, name, desc, img, priceCrystal, priceCoin, currencyType"
        projectile = optArr[0]
        range = CGFloat(optArr[2])
        projectileSpeed = CGFloat(optArr[3])
        projectileReflects = optArr[4] == "TRUE"
        if let cond = StatusCondition(rawValue: Double(optArr[5])!) {
            statusCondition = (cond, CGFloat(optArr[6]))
        }
        
        let numProjectiles = Int(optArr[1])!
        if (numProjectiles % 2 == 0) {
            for i in 0..<numProjectiles/2 {
                angles.append(CGFloat(i)*CGFloat(M_PI_4/4))
                angles.append(-1 * CGFloat(i)*CGFloat(M_PI_4/4))
            }
        }
        else {
            angles.append(0)
            for i in 0..<numProjectiles/2 {
                angles.append(CGFloat(i)*CGFloat(M_PI_4/2))
                angles.append(-1 * CGFloat(i)*CGFloat(M_PI_4/2))
            }
        }
        super.init(statMods: Stats.statsFrom(optArr[7]), name: optArr[8], description: optArr[9], img: optArr[10], priceCrystals: Int(optArr[11])!, priceCoins: Int(optArr[12])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[13])!))
        
    }
        
    func getProjectile(withAtk:CGFloat, fromPoint:CGPoint, withVelocity:CGVector, isFriendly:Bool) -> [Projectile] {
        var out = [Projectile]()
        for angle in angles {
            out.append(Projectile(fromTexture: defaultLevelHandler.getCurrentLevelAtlas().textureNamed(projectile), fromPoint: fromPoint, withVelocity: projectileSpeed * CGVectorMake(cos(angle)*withVelocity.dx, sin(angle*withVelocity.dy)), isFriendly: isFriendly, withRange: self.range, withAtk: withAtk, reflects: self.projectileReflects, statusInflicted: statusCondition))
        }
        return out
    }
    
    //NSCoding
    private struct PropertyKey {
        static let projectileKey = "projectile"
        static let rangeKey = "range"
        static let projectileSpeedKey = "projectileSpeed"
        static let projectileReflectsKey = "projectileReflects"
        static let statusConditionKey = "statCond"
        static let statusConditionProbKey = "statCondProb"
        static let angleKey = "angles"
    }
    required init?(coder aDecoder: NSCoder) {
        projectile = aDecoder.decodeObjectForKey(PropertyKey.projectileKey) as! String
        range = aDecoder.decodeObjectForKey(PropertyKey.rangeKey) as! CGFloat
        projectileSpeed = aDecoder.decodeObjectForKey(PropertyKey.projectileSpeedKey) as! CGFloat
        projectileReflects = aDecoder.decodeObjectForKey(PropertyKey.projectileReflectsKey) as! Bool
        if let val = aDecoder.decodeObjectForKey(PropertyKey.statusConditionKey) as? Double, prob = aDecoder.decodeObjectForKey(PropertyKey.statusConditionProbKey) as? CGFloat {
            statusCondition = (StatusCondition(rawValue: val)!, prob)
        }
        angles = aDecoder.decodeObjectForKey(PropertyKey.angleKey) as! [CGFloat]
        super.init(coder: aDecoder)
    }
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(projectile, forKey: PropertyKey.projectileKey)
        aCoder.encodeObject(range, forKey:PropertyKey.rangeKey)
        aCoder.encodeObject(projectileSpeed, forKey:PropertyKey.projectileSpeedKey)
        aCoder.encodeObject(projectileReflects, forKey:PropertyKey.projectileReflectsKey)
        aCoder.encodeObject(statusCondition?.condition.rawValue, forKey:PropertyKey.statusConditionKey)
        aCoder.encodeObject(statusCondition?.probability, forKey:PropertyKey.statusConditionProbKey)
        aCoder.encodeObject(angles, forKey: PropertyKey.angleKey)
        super.encodeWithCoder(aCoder)
    }
    override func getType() -> String {
        return "Weapon"
    }
}

class Armor: Item {
    let protectsAgainst:StatusCondition?
    required init(fromBase64: String) {
        //statMod in b64, name, desc, img, priceCrystal, priceCoin, currencyType, statusCondition rawval
        let optArr = fromBase64.splitBase64IntoArray("|")
        protectsAgainst = StatusCondition(rawValue: Double(optArr[7])!)
        super.init(statMods: Stats.statsFrom(optArr[0]), name: optArr[1], description: optArr[2], img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: Int(optArr[5])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[6])!))
    }
    
    override func getType() -> String {
        return "Armor"
    }
    //NSCoding
    required init?(coder aDecoder: NSCoder) {
        if let rawVal = aDecoder.decodeObjectForKey("protectsAgainst") as? Double {
            self.protectsAgainst = StatusCondition(rawValue: rawVal)!
        }
        else {
            self.protectsAgainst = nil
        }
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(protectsAgainst?.rawValue, forKey: "protectsAgainst")
    }


}

class Enhancer: Item {
    override func getType() -> String {
        return "Enhancer"
    }
    required init(fromBase64: String) {
        //statMods, name, desc, img, priceCrystal, priceCoin, currencyType
        let optArr = fromBase64.splitBase64IntoArray("|")
        super.init(statMods: Stats.statsFrom(optArr[0]), name: optArr[1], description: optArr[2], img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: Int(optArr[5])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[6])!))

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Consumable: Item {
    let permanent:Bool
    required init(fromBase64:String) {
        //permanent, statMods, name, img, priceCrystal, priceCoin, currencyType
        let optArr = fromBase64.splitBase64IntoArray("|")
        permanent = optArr[0] == "TRUE"
        super.init(statMods: Stats.statsFrom(optArr[1]), name: optArr[2], description: "", img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: Int(optArr[5])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[6])!))
    }
    //NSCoding
    private struct PropertyKey {
        static let permanentKey = "permanent"
    }
    required init?(coder aDecoder: NSCoder) {
        permanent = aDecoder.decodeObjectForKey(PropertyKey.permanentKey) as! Bool
        super.init(coder: aDecoder)
    }
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(permanent, forKey: PropertyKey.permanentKey)
        super.encodeWithCoder(aCoder)
    }
    override func getType() -> String {
        return "Consumable"
    }
}

class TemporaryBoostConsumable: Item {
    
}

class Usable:Item {
    let eventKey:String
    required init(fromBase64: String) {
        //eventKey, name, desc, img, priceCrystal
        let optArr = fromBase64.splitBase64IntoArray("|")
        eventKey = optArr[0]
        super.init(statMods: Stats.nilStats, name: optArr[1], description: optArr[2], img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: 0, designatedCurrencyType: CurrencyType.ChasmCrystal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        eventKey = aDecoder.decodeObjectForKey("eventkey") as! String
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(eventKey, forKey: "eventkey")
    }
    
    func use() {
        NSNotificationCenter.defaultCenter().postNotificationName("UsableItemUsed", object: eventKey)
    }
   
    override func getType() -> String {
        return "Tool"
    }
}

class Sellable:Item {
    required init(fromBase64:String) {
        //name, img, priceCoin
        let optArr = fromBase64.splitBase64IntoArray("|")
        super.init(statMods: Stats.nilStats, name: optArr[0], description: "Worth: \(optArr[2]) Coins", img: optArr[1], priceCrystals: 0, priceCoins: Int(optArr[2])!, designatedCurrencyType: CurrencyType.Coin)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func getType() -> String {
        return "Valuable"
    }

}
