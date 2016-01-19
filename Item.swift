//
//  Item.swift
//  100Floors
//
//  Created by Sid Mani on 1/12/16.
//
//

import SpriteKit

class Item {
    var node:SKSpriteNode?
    var statMods:Stats
    init(stats:Stats)
    {
        statMods = stats
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

class Consumable: Item {
    
}

class Weapon: Item {
    var projectile:ProjectileDefinition?
    //TODO: some sort of special effect when rage hits max
    init(definition:WeaponDefinition)
    {
        super.init(stats: definition.statMods)
        projectile = definition.projectile
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
    var permanent:Bool?
    
    init(definition:EnhancerDefinition)
    {
        super.init(stats: definition.statMods)
    }
}

class Style: Item {
    
}

