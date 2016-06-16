//
//  Item.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

import SpriteKit
// 6 basic kinds of item: weapon, skill, shield, enhancer, style, consumable
// skill: skill move
// weapon: fires projectiles
// shield: boosts DEF and potentially decreases SPD
// enhancer: boosts a stat while equipped
// style: changes appearance
// consumable: gives temporary or permanent stat changes

class Item:NSObject, NSCoding {
    private static let ItemTypeDict:[String:Item.Type] = [
        "Weapon":Weapon.self,
        "Consumable":Consumable.self,
        "Skill":Skill.self,
        "Shield":Shield.self,
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
    let projectile:String
    let range:CGFloat
    let projectileSpeed:CGFloat
    let projectileReflects:Bool
    
    required init(thisItem:AEXMLElement) {
        projectile = thisItem["projectile-id"].stringValue
        range = CGFloat(thisItem["range"].doubleValue)
        projectileSpeed = CGFloat(thisItem["projectile-speed"].doubleValue)
        projectileReflects = thisItem["projectile-reflects"].boolValue
        let img = thisItem["img"].stringValue
        let description = thisItem["desc"].stringValue
        let name = thisItem["name"].stringValue
        let statMods = Stats.statsFrom(thisItem)
        super.init(statMods:statMods, name:name, description:description, img:img)
    }
    
    init(projectile:String, range:CGFloat, projectileSpeed:CGFloat, projectileReflects:Bool, statMods:Stats, name:String, description:String, img:String) {
        self.projectile = projectile
        self.range = range
        self.projectileSpeed = projectileSpeed
        self.projectileReflects = projectileReflects
        super.init(statMods:statMods, name: name, description: description, img:img)
    }
    //NSCoding
    private struct PropertyKey {
        static let projectileKey = "projectile"
        static let rangeKey = "range"
        static let projectileSpeedKey = "projectileSpeed"
        static let projectileReflectsKey = "projectileReflects"
    }
    required init?(coder aDecoder: NSCoder) {
         projectile = aDecoder.decodeObjectForKey(PropertyKey.projectileKey) as! String
         range = aDecoder.decodeObjectForKey(PropertyKey.rangeKey) as! CGFloat
         projectileSpeed = aDecoder.decodeObjectForKey(PropertyKey.projectileSpeedKey) as! CGFloat
         projectileReflects = aDecoder.decodeObjectForKey(PropertyKey.projectileReflectsKey) as! Bool
        super.init(coder: aDecoder)
    }
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(projectile, forKey: PropertyKey.projectileKey)
        aCoder.encodeObject(range, forKey:PropertyKey.rangeKey)
        aCoder.encodeObject(projectileSpeed, forKey:PropertyKey.projectileSpeedKey)
        aCoder.encodeObject(projectileReflects, forKey:PropertyKey.projectileReflectsKey)
        super.encodeWithCoder(aCoder)
    }
}

class Skill: Item {
    
}

class Shield: Item {
    
}

class Enhancer: Item {

}

class Consumable: Item {
    let permanent:Bool
    required init(thisItem:AEXMLElement) {
        permanent = thisItem["permanent"].boolValue
        super.init(thisItem: thisItem)
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
    
}
