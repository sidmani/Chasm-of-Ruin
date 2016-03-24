//
//  Item.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

import SpriteKit
// 5 basic kinds of item: weapon, skill, shield, enhancer, style
// skill: skill move
// weapon: fires projectiles
// shield: boosts DEF and potentially decreases SPD
// enhancer: boosts a stat while equipped
// style: changes appearance
enum ItemType {
    case Weapon, Skill, Shield, Enhancer, Style, None
    static func typeFromString(s:String) -> ItemType {
        switch (s) {
        case "Weapon":
            return ItemType.Weapon
        case "Skill":
            return ItemType.Skill
        case "Shield":
            return ItemType.Shield
        case "Enhancer":
            return ItemType.Enhancer
        case "Style":
            return ItemType.Style
        default:
            fatalError("Item Type Error")
        }
    }
}
class Item {
    
    var statMods:Stats
    var name:String
    var description:String
    var node:SKSpriteNode
    var type:ItemType
    var consumable:Bool
    var permanent:Bool = false
    var projectile:String = ""
    var range:CGFloat = 0
    var projectileSpeed:CGFloat = 0
    init(thisItem: AEXMLElement) {
        type = ItemType.typeFromString(thisItem["type"].stringValue)
        node = SKSpriteNode(imageNamed: thisItem["img"].stringValue)
        description = thisItem["desc"].stringValue
        name = thisItem["name"].stringValue
        consumable = thisItem["consumable"].boolValue
        if (consumable) {
            permanent = thisItem["permanent"].boolValue
        }
        statMods = Stats.statsFrom(thisItem)
        if (type == ItemType.Weapon) {
            projectile = thisItem["projectile-id"].stringValue
            range = CGFloat(thisItem["range"].doubleValue)
            projectileSpeed = CGFloat(thisItem["projectile-speed"].doubleValue)
        }
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

}


