//
//  Item.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

import SpriteKit
// 6 basic kinds of item: consumable, weapon, skill, shield, enhancer, style
// consumable: increases stats temporarily or permanently
// skill: skill move
// weapon: fires projectiles
// shield: boosts DEF and potentially decreases SPD
// enhancer: boosts a stat while equipped
// style: changes appearance
enum ItemType {
    case Weapon, Skill, Shield, Enhancer, Style, None
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
    
    init(withID:String) {
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
        type = {switch (thisItem["type"].stringValue) {
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
            }}()
        print(thisItem["img"].stringValue)
        node = SKSpriteNode(imageNamed: thisItem["img"].stringValue)
        description = thisItem["desc"].stringValue
        name = thisItem["name"].stringValue
        consumable = thisItem["consumable"].boolValue
        if (consumable) {
            permanent = thisItem["permanent"].boolValue
        }
        statMods = Stats(
                health: CGFloat(thisItem["Stats"]["health"].doubleValue),
                defense: CGFloat(thisItem["Stats"]["def"].doubleValue),
                attack: CGFloat(thisItem["Stats"]["atk"].doubleValue),
                speed: CGFloat(thisItem["Stats"]["spd"].doubleValue),
                dexterity: CGFloat(thisItem["Stats"]["dex"].doubleValue),
                hunger: CGFloat(thisItem["Stats"]["hunger"].doubleValue),
                level: CGFloat(thisItem["Stats"]["level"].doubleValue),
                mana: CGFloat(thisItem["Stats"]["mana"].doubleValue),
                rage: CGFloat(thisItem["Stats"]["rage"].doubleValue))
        if (type == ItemType.Weapon) {
            projectile = thisItem["projectile-id"].stringValue
            range = CGFloat(thisItem["range"].doubleValue)
        }
        
    }
}


