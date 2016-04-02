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

class Item {
    
    var statMods:Stats
    var name:String
    var description:String
    var img: String
    
    init(thisItem: AEXMLElement) {
        img = thisItem["img"].stringValue
        description = thisItem["desc"].stringValue
        name = thisItem["name"].stringValue
        statMods = Stats.statsFrom(thisItem)
    }

    convenience init(withID:String) {
        var thisItem:AEXMLElement
        if let items = itemXML?.root["items"]["item"].allWithAttributes(["id":withID]) {
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
        self.init(thisItem:thisItem)
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
    static func initHandler(withID:String) -> Item? {
        var thisItem:AEXMLElement
        if let items = itemXML?.root["items"]["item"].allWithAttributes(["id":withID]) {
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

}

class Weapon: Item {
    var projectile:String
    var range:CGFloat
    var projectileSpeed:CGFloat
    var projectileReflects:Bool
    override init(thisItem:AEXMLElement) {
        projectile = thisItem["projectile-id"].stringValue
        range = CGFloat(thisItem["range"].doubleValue)
        projectileSpeed = CGFloat(thisItem["projectile-speed"].doubleValue)
        projectileReflects = thisItem["projectile-reflects"].boolValue
        super.init(thisItem: thisItem)
    }

}

class Skill: Item {
    override init(thisItem: AEXMLElement) {
        super.init(thisItem: thisItem)
    }
}

class Shield: Item {
    override init(thisItem: AEXMLElement) {
        super.init(thisItem: thisItem)
    }
}

class Enhancer: Item {
    override init(thisItem: AEXMLElement) {
        super.init(thisItem: thisItem)
    }
}

class Consumable: Item {
    var permanent:Bool
    override init(thisItem:AEXMLElement) {
        permanent = thisItem["permanent"].boolValue
        super.init(thisItem: thisItem)
    }
    
}

