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
    init()
    {
        
    }
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
    var projectile:Projectile?
    var power:Int?
    
}

class Skill: Item {
    
}

class Shield: Item {
    var statToBoost = StatTypes.defense
    
    
}

class Enhancer: Item {
    var statToBoost:StatTypes?
    var amountToBoost:Int?
    var permanent = true
    init(_statToBoost:StatTypes, _amountToBoost:Int)
    {
        statToBoost = _statToBoost
        amountToBoost = _amountToBoost
    }
}

class Style: Item {
    
}
