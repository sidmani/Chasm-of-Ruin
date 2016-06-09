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
    
    let statMods:Stats
    let name:String
    let desc:String
    let img: String
    
    init(thisItem: AEXMLElement) {
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
    
    static func initHandler(fromElement:AEXMLElement) -> Item? {
        switch (fromElement["type"].stringValue) {
        case "Weapon":
            return Weapon(thisItem: fromElement)
        case "Consumable":
            return Consumable(thisItem: fromElement)
        case "Skill":
            return Skill(thisItem: fromElement)
        case "Shield":
            return Shield(thisItem: fromElement)
        case "Enhancer":
            return Enhancer(thisItem: fromElement)
        case "Style":
            return nil
        default:
            return nil
        }
    }
    static func initHandlerID(withID:String) -> Item? {
        var thisItem:AEXMLElement
        if let items = itemXML.root["items"]["item"].allWithAttributes(["id":withID]) {
            if (items.count != 1) {
                fatalError("Item ID error")
            }
            else {
                thisItem = items[0]
            }
        }
        else {
            fatalError("Item Not Found")
        }
        return initHandler(thisItem)
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
         //self.init(statMods: statMods, name: name, description: description, img: img)
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
    
    override init(thisItem:AEXMLElement) {
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
       // let statMods = Stats.statsFrom(aDecoder.decodeObjectForKey(PropertyKey.statModsKey) as! NSArray)
      //  let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
      //  let description = aDecoder.decodeObjectForKey(PropertyKey.descriptionKey) as! String
      //  let img = aDecoder.decodeObjectForKey(PropertyKey.imgKey) as! String
         projectile = aDecoder.decodeObjectForKey(PropertyKey.projectileKey) as! String
         range = aDecoder.decodeObjectForKey(PropertyKey.rangeKey) as! CGFloat
         projectileSpeed = aDecoder.decodeObjectForKey(PropertyKey.projectileSpeedKey) as! CGFloat
         projectileReflects = aDecoder.decodeObjectForKey(PropertyKey.projectileReflectsKey) as! Bool
        super.init(coder: aDecoder)
        //self.init(projectile:projectile, range:range, projectileSpeed:projectileSpeed, projectileReflects:projectileReflects, statMods: statMods, name: name, description: description, img: img)
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
    override init(thisItem: AEXMLElement) {
        super.init(thisItem: thisItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class Shield: Item {
    override init(thisItem: AEXMLElement) {
        super.init(thisItem: thisItem)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Enhancer: Item {
    override init(thisItem: AEXMLElement) {
        super.init(thisItem: thisItem)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Consumable: Item {
    let permanent:Bool
    override init(thisItem:AEXMLElement) {
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
