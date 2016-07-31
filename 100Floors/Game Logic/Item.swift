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

class Item:NSObject, Purchasable {
    private static let ItemTypeDict:[String:Item.Type] = [
        "Weapon":Weapon.self,
        "Consumable":Consumable.self,
        "Skill":Skill.self,
        "Armor":Armor.self,
        "Enhancer":Enhancer.self,
        "Sellable":Sellable.self,
        "Usable":Usable.self,
        "Scroll":Scroll.self
    ]

    var statMods:Stats
    let name:String
    let desc:String
    let img: String
    let id:String
    var priceCoins: Int? = nil
    var priceCrystals: Int? = nil
    var designatedCurrencyType: CurrencyType? = nil
    
    required init(fromBase64:String, id:String) {
        fatalError()
    }
    
    init(statMods:Stats, name:String, description:String, img:String, priceCrystals:Int, priceCoins:Int, designatedCurrencyType:CurrencyType?, id:String) {
        self.statMods = statMods
        self.id = id
        self.desc = description
        self.name = name
        self.img = img
        self.priceCoins = (priceCoins < 0 ? nil : priceCoins)
        self.priceCrystals = (priceCrystals < 0 ? nil : priceCrystals)
        self.designatedCurrencyType = designatedCurrencyType
    }
    
    static func initHandlerID(withID:String) -> Item {
        let thisItem = itemXML.root["item"].allWithAttributes(["id":withID])!.first!
        return ItemTypeDict[thisItem.attributes["type"]!]!.init(fromBase64: thisItem.stringValue, id:withID)
    }
    
    func getType() -> String {
        return ""
    }
    
    func getMaxStat() -> CGFloat {
        return statMods.toSwiftArray().maxElement()!
    }

}

class Weapon: Item {
    
    var projectile:SKTexture!
    private let range:CGFloat
    let projectileName:String
    let projectileReflects:Bool
    var statusCondition:(condition:StatusCondition, probability:CGFloat)? = nil
    var angles:[CGFloat] = []
    required init(fromBase64:String, id:String) {
        let optArr = fromBase64.splitBase64IntoArray("|")
        // "projectile name, # projectiles, range, projectile reflects, status condition, probability, statMod in b64, name, desc, img, priceCrystal, priceCoin, currencyType"
        projectileName = optArr[0]
        range = CGFloat(optArr[2])
        projectileReflects = optArr[3] == "TRUE"
        if let cond = StatusCondition(rawValue: Double(optArr[4])!) {
            statusCondition = (cond, CGFloat(optArr[5]))
        }        
        let numProjectiles = Int(optArr[1])!
        if (numProjectiles % 2 == 0) {
            for i in 0..<numProjectiles/2 {
                angles.append(CGFloat(i+1)*CGFloat(M_PI_4/4))
                angles.append(-1 * CGFloat(i+1)*CGFloat(M_PI_4/4))
            }
        }
        else if (numProjectiles == 1){
            angles.append(0)
        }
        else {
            angles.append(0)
            for i in 0..<numProjectiles/2 {
                angles.append(CGFloat(i+1)*CGFloat(M_PI_4/2))
                angles.append(-1 * CGFloat(i+1)*CGFloat(M_PI_4/2))
            }
        }
        super.init(statMods: Stats.statsFrom(optArr[6]), name: optArr[7], description: optArr[8], img: optArr[9], priceCrystals: Int(optArr[10])!, priceCoins: Int(optArr[11])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[12])!), id: id)
    }
        
    func getProjectile(withAtk:CGFloat, fromPoint:CGPoint, withAngle:CGFloat, withSpeed:CGFloat, isFriendly:Bool) -> [Projectile] {
        var out = [Projectile]()
        for angle in angles {
            out.append(Projectile(fromTexture: projectile, fromPoint: fromPoint, withVelocity: withSpeed*CGVectorMake(cos(angle+withAngle), sin(angle+withAngle)), withAngle: angle+withAngle, isFriendly: isFriendly, withRange: self.range, withAtk: withAtk, reflects: self.projectileReflects, statusInflicted: statusCondition))
        }
        return out
    }

    func setTextureDict() {
        projectile = defaultLevelHandler.getCurrentLevelAtlas().textureNamed(self.projectileName)

    }
    
    override func getType() -> String {
        return "Weapon"
    }
}

class Armor: Item {
    let protectsAgainst:StatusCondition?
    required init(fromBase64: String, id:String) {
        //statMod in b64, name, desc, img, priceCrystal, priceCoin, currencyType, statusCondition rawval
        let optArr = fromBase64.splitBase64IntoArray("|")
        protectsAgainst = StatusCondition(rawValue: Double(optArr[7])!)
        super.init(statMods: Stats.statsFrom(optArr[0]), name: optArr[1], description: optArr[2], img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: Int(optArr[5])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[6])!), id: id)
    }
    
    override func getType() -> String {
        return "Armor"
    }
}

class Enhancer: Item {
    override func getType() -> String {
        return "Enhancer"
    }
    required init(fromBase64: String, id:String) {
        //statMods, name, desc, img, priceCrystal, priceCoin, currencyType
        let optArr = fromBase64.splitBase64IntoArray("|")
        super.init(statMods: Stats.statsFrom(optArr[0]), name: optArr[1], description: optArr[2], img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: Int(optArr[5])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[6])!), id: id)

    }
}

class Consumable: Item {
    let permanent:Bool
    required init(fromBase64:String, id:String) {
        //permanent, statMods, name, img, priceCrystal, priceCoin, currencyType
        let optArr = fromBase64.splitBase64IntoArray("|")
        permanent = optArr[0] == "TRUE"
        super.init(statMods: Stats.statsFrom(optArr[1]), name: optArr[2], description: "", img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: Int(optArr[5])!, designatedCurrencyType: CurrencyType(rawValue: Int(optArr[6])!), id: id)
    }
    override func getType() -> String {
        return "Consumable"
    }
}

class TemporaryBoostConsumable: Item {
    
}

class Usable:Item {
    let eventKey:String
    required init(fromBase64: String, id:String) {
        //eventKey, name, desc, img, priceCrystal
        let optArr = fromBase64.splitBase64IntoArray("|")
        eventKey = optArr[0]
        super.init(statMods: Stats.nilStats, name: optArr[1], description: optArr[2], img: optArr[3], priceCrystals: Int(optArr[4])!, priceCoins: 0, designatedCurrencyType: CurrencyType.ChasmCrystal, id: id)
    }
    
    func use() {
        NSNotificationCenter.defaultCenter().postNotificationName("UsableItemUsed", object: eventKey)
    }
   
    override func getType() -> String {
        return "Tool"
    }
}

class Sellable:Item {
    required init(fromBase64:String, id:String) {
        //name, img, priceCoin
        let optArr = fromBase64.splitBase64IntoArray("|")
        super.init(statMods: Stats.nilStats, name: optArr[0], description: "Worth: \(optArr[2]) Coins", img: optArr[1], priceCrystals: 0, priceCoins: Int(optArr[2])!, designatedCurrencyType: CurrencyType.Coin, id: id)
    }
    override func getType() -> String {
        return "Valuable"
    }

}
