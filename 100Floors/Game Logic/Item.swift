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
        "Enhancer":Enhancer.self
    ]
    let statMods:Stats
    let name:String
    let desc:String
    let img: String
    
    var priceCoins: Int? = nil
    var priceCrystals: Int? = nil
    var designatedCurrencyType: CurrencyType? = nil
    
    required init(fromBase64:String) {
        fatalError()
    }
    
    init(statMods:Stats, name:String, description:String, img:String, priceCrystals:Int?, priceCoins:Int?, designatedCurrencyType:CurrencyType?) {
        self.statMods = statMods
        self.desc = description
        self.name = name
        self.img = img
        self.priceCoins = priceCoins
        self.priceCrystals = priceCrystals
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
}

 class Weapon: Item {
    let projectile:String
    private let range:CGFloat
    let projectileSpeed:CGFloat
    let projectileReflects:Bool
    var statusCondition:(condition:StatusCondition,probability:CGFloat)? = nil
    
    required init(fromBase64:String) {
        let optArr = fromBase64.splitBase64IntoArray()
        // "projectile name, range, projectile speed, projectile reflects, status condition, probability, statMod in b64, name, desc, img, priceCrystal, priceCoin, currencyType"
        projectile = optArr[0]
       // projectile.filteringMode = .Nearest
        range = CGFloat(s: optArr[1])
        projectileSpeed = CGFloat(s: optArr[2])
        projectileReflects = optArr[3] == "true"
        if let cond = StatusCondition(rawValue: Double(optArr[4])!) {
            statusCondition = (cond, CGFloat(s:optArr[5]))
        }
        super.init(statMods: Stats.statsFrom(optArr[6]), name: optArr[7], description: optArr[8], img: optArr[9], priceCrystals: Int(optArr[10])!, priceCoins: Int(optArr[11])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[12])!))
        
    }
        
    func getProjectile(withAtk:CGFloat, fromPoint:CGPoint, withVelocity:CGVector, isFriendly:Bool) -> Projectile {
        return Projectile(fromTexture: defaultLevelHandler.getCurrentLevelAtlas().textureNamed(projectile), fromPoint: fromPoint, withVelocity: projectileSpeed * withVelocity, isFriendly: isFriendly, withRange: self.range, withAtk: withAtk, reflects: self.projectileReflects, statusInflicted: statusCondition)
    }
    
    //NSCoding
    private struct PropertyKey {
        static let projectileKey = "projectile"
        static let rangeKey = "range"
        static let projectileSpeedKey = "projectileSpeed"
        static let projectileReflectsKey = "projectileReflects"
        static let statusConditionKey = "statCond"
        static let statusConditionProbKey = "statCondProb"
    }
    required init?(coder aDecoder: NSCoder) {
        projectile = aDecoder.decodeObjectForKey(PropertyKey.projectileKey) as! String
        range = aDecoder.decodeObjectForKey(PropertyKey.rangeKey) as! CGFloat
        projectileSpeed = aDecoder.decodeObjectForKey(PropertyKey.projectileSpeedKey) as! CGFloat
        projectileReflects = aDecoder.decodeObjectForKey(PropertyKey.projectileReflectsKey) as! Bool
        if let val = aDecoder.decodeObjectForKey(PropertyKey.statusConditionKey) as? Double, prob = aDecoder.decodeObjectForKey(PropertyKey.statusConditionProbKey) as? CGFloat {
            statusCondition = (StatusCondition(rawValue: val)!, prob)
        }
        super.init(coder: aDecoder)
    }
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(projectile, forKey: PropertyKey.projectileKey)
        aCoder.encodeObject(range, forKey:PropertyKey.rangeKey)
        aCoder.encodeObject(projectileSpeed, forKey:PropertyKey.projectileSpeedKey)
        aCoder.encodeObject(projectileReflects, forKey:PropertyKey.projectileReflectsKey)
        aCoder.encodeObject(statusCondition?.condition.rawValue, forKey:PropertyKey.statusConditionKey)
        aCoder.encodeObject(statusCondition?.probability, forKey:PropertyKey.statusConditionProbKey)
        super.encodeWithCoder(aCoder)
    }
}

class Armor: Item {
    //protects against certain status effects
}

class Enhancer: Item {

}

class Consumable: Item {
    let permanent:Bool
    required init(fromBase64:String) {
        //permanent, statMods, name, desc, img
        let optArr = fromBase64.splitBase64IntoArray()
        permanent = optArr[0] == "true"
        super.init(statMods: Stats.statsFrom(optArr[1]), name: optArr[2], description: optArr[3], img: optArr[4], priceCrystals: Int(optArr[5])!, priceCoins: Int(optArr[6])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[7])!))
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
}

class Usable:Item {
    let eventKey:String
    required init(fromBase64: String) {
        //eventKey, statMods, name, desc, img
        let optArr = fromBase64.splitBase64IntoArray()
        eventKey = optArr[0]
        super.init(statMods: Stats.statsFrom(optArr[1]), name: optArr[2], description: optArr[3], img: optArr[4], priceCrystals: Int(optArr[5])!, priceCoins: Int(optArr[6])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[7])!))

    }
    
    func use() {
        NSNotificationCenter.defaultCenter().postNotificationName("UsableItemUsed", object: eventKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
