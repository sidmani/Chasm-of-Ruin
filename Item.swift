//
//  Item.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

import SpriteKit
enum ItemType {
    case Weapon, Consumable, Skill, Shield, Enhancer, Style
}
class Item {
    var node:SKSpriteNode?
    var statMods:Stats
    var description:String
    var name:String
    var consumable:Bool
    var type:ItemType
    var projectile:String?
    
   /* init(stats:Stats)
    {
        node = SKSpriteNode()
        statMods = stats
    }*/
    init(withID:String) {
        var thisItem:AEXMLElement
        if let items = itemXML!.root["items"]["item"].allWithAttributes(["id":"wep1"]) {
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
        type = {switch (thisItem["type"].value!) {
            case "Weapon":
            return ItemType.Weapon
            case "Consumable":
            return ItemType.Consumable
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
        node = SKSpriteNode(fileNamed: thisItem["img"].value!)
        description = thisItem["desc"].value!
        name = thisItem["name"].value!
        consumable = thisItem["consumable"].boolValue
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
            projectile = thisItem["projectile-id"].value!
        }
        
    }
    
    func getNode() -> SKSpriteNode? {
        return node
    }
}

class ItemBag { // Container for item dropped on the ground
    
}
// 6 basic kinds of item: consumable, weapon, skill, shield, enhancer, style
// consumable: increases stats temporarily or permanently
// skill: skill move
// weapon: fires projectiles
// shield: boosts DEF and potentially decreases SPD
// enhancer: boosts a stat while equipped
// style: changes appearance

/*class Consumable: Item {
    
}

class Weapon: Item {
    var projectile:ProjectileDefinition
    //TODO: some sort of special effect when rage hits max
    init(definition:WeaponDefinition)
    {
        projectile = definition.projectile
        super.init(stats: definition.statMods)
    }
}

class Skill: Item {
    init(definition:SkillDefinition)
    {
        super.init(stats: definition.statMods)
    }
}

class Shield: Item {    
    init(definition:ShieldDefinition)
    {
        super.init(stats: definition.statMods)
    }
}

class Enhancer: Item {
    var permanent:Bool = false
    
    init(definition:EnhancerDefinition)
    {
        super.init(stats: definition.statMods)
    }
}

class Style: Item {
    
}*/

