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

class Item:NSObject, NSCoding {
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
    
    required init(thisItem: AEXMLElement) {
        img = thisItem["img"].stringValue
        desc = thisItem["desc"].stringValue
        name = thisItem["name"].stringValue
        statMods = Stats.statsFrom(thisItem)
    }
    
    init(statMods:Stats, name:String, description:String, img:String) {
        self.statMods = statMods
        self.desc = description
        self.name = name
        self.img = img
    }
    
    static func initHandlerID(withID:String) -> Item {
        let thisItem = itemXML.root["items"]["item"].allWithAttributes(["id":withID])!.first!
        return ItemTypeDict[thisItem["type"].stringValue]!.init(thisItem: thisItem)
    }
    //NSCoding
    private struct PropertyKey {
        static let statModsKey = "statMods"
        static let nameKey = "name"
        static let descriptionKey = "description"
        static let imgKey = "img"
    }
    
    required init?(coder aDecoder: NSCoder) {
         statMods = Stats.statsFrom(aDecoder.decodeObjectForKey(PropertyKey.statModsKey) as! NSArray)
         name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
         desc = aDecoder.decodeObjectForKey(PropertyKey.descriptionKey) as! String
         img = aDecoder.decodeObjectForKey(PropertyKey.imgKey) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(statMods.toArray(), forKey: PropertyKey.statModsKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(description, forKey: PropertyKey.descriptionKey)
        aCoder.encodeObject(img, forKey: PropertyKey.imgKey)
    }
}

 class Weapon: Item {
    let projectile:SKTexture
    private let range:CGFloat
    let projectileSpeed:CGFloat
    let projectileReflects:Bool
    var statusCondition:(condition:StatusCondition,probability:CGFloat)? = nil

    required init(thisItem:AEXMLElement) {
        projectile = SKTextureAtlas(named: "Projectiles").textureNamed(thisItem["projectile-img"].stringValue)
        projectile.filteringMode = .Nearest
        range = CGFloat(thisItem["range"].doubleValue)
        projectileSpeed = CGFloat(thisItem["projectile-speed"].doubleValue)
        projectileReflects = thisItem["projectile-reflects"].boolValue
        if let cond = StatusCondition(rawValue: thisItem["status-condition"].doubleValue) {
            statusCondition = (cond, CGFloat(thisItem["status-condition-probability"].doubleValue))
        }
        let img = thisItem["img"].stringValue
        let description = thisItem["desc"].stringValue
        let name = thisItem["name"].stringValue
        let statMods = Stats.statsFrom(thisItem)
        super.init(statMods:statMods, name:name, description:description, img:img)
    }
    
    init(fromBase64:String) {
        let optArr = fromBase64.splitBase64IntoArray()
        // "projectile name, range, projectile speed, projectile reflects, status condition, probability, statMod in b64, name, desc, img"
        projectile = SKTextureAtlas(named: "Projectiles").textureNamed(optArr[0])
        projectile.filteringMode = .Nearest
        range = CGFloat(s: optArr[1])
        projectileSpeed = CGFloat(s: optArr[2])
        projectileReflects = optArr[3] == "true"
        if let cond = StatusCondition(rawValue: Double(optArr[4])!) {
            statusCondition = (cond, CGFloat(s:optArr[5]))
        }
        super.init(statMods: Stats.statsFrom(optArr[6]), name: optArr[7], description: optArr[8], img: optArr[9])
        
    }
    
    private init(projectile:String, range:CGFloat, projectileSpeed:CGFloat, projectileReflects:Bool, statMods:Stats, name:String, description:String, img:String, statusCondition:(StatusCondition, CGFloat)?) {
        self.projectile = SKTextureAtlas(named: "Projectiles").textureNamed(projectile)
        self.projectile.filteringMode = .Nearest
        self.range = range
        self.projectileSpeed = projectileSpeed
        self.projectileReflects = projectileReflects
        self.statusCondition = statusCondition
        super.init(statMods:statMods, name: name, description: description, img:img)
    }
    
    func getProjectile(withAtk:CGFloat, fromPoint:CGPoint, withVelocity:CGVector, isFriendly:Bool) -> Projectile {
        return Projectile(fromTexture: self.projectile, fromPoint: fromPoint, withVelocity: projectileSpeed * withVelocity, isFriendly: isFriendly, withRange: self.range, withAtk: withAtk, reflects: self.projectileReflects, statusInflicted: statusCondition)
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
        projectile = aDecoder.decodeObjectForKey(PropertyKey.projectileKey) as! SKTexture
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

class Skill: Item {
    
}

class Armor: Item {
    
}

class Enhancer: Item {

}

class Consumable: Item {
    let permanent:Bool
    
    required init(thisItem:AEXMLElement) {
        permanent = thisItem["permanent"].boolValue
        super.init(thisItem: thisItem)
    }
    
  //  init(fromBase64:String) {
        
  //  }
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
//    let eventKey:String
//    send NSNotifications 
}
