//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//
import SpriteKit

//// data structs ////
struct Stats {
    var health:Int    // Health
    var defense:Int   // Defense (% projectile is weakened by)
    var attack:Int    // Attack (% own projectile is strengthened by)
    var speed:Int     // Speed
    var dexterity:Int // Dexterity (rate of projectile release)
    var hunger:Int    // Hunger (decrease with time)
    var level:Int     // Level (Overall boost to all stats)
    var mana:Int      // Mana (used when casting spells)
    var rage:Int      // Builds up over time, released when hunger/health are low (last resort kinda thing)
}
struct PosData {
    var absoluteLoc:CGPoint
    var screenLoc:CGPoint //TODO: Make computed property
    var velocity:CGFloat
    var direction:CGFloat //direction in radians
}
struct EquippedItems {
    var shield:Shield
    var weapon:Weapon
    var enhancer:Enhancer
    var skill:Skill
}
//////////////////////


class Entity { //TODO: rewrite properties in class
    var posData:PosData?
    var equippedItems:EquippedItems?
    var ID:String
    
    init(_ID:String)
    {
        ID = _ID
    }
    
}

class ThisCharacter: Entity {
    var node:SKSpriteNode? //TODO: fix this
    var charClass:CharClass?
    var stats:Stats?
    var equipped:EquippedItems?
    var currentProjectile:Projectile? //set based on item, dynamic assigment
    
    func setScreenLoc(newLoc:CGPoint)
    {
        posData!.screenLoc = newLoc
        node!.position = newLoc //TODO: fix this
    }
    func setImageOrientation() {
        // change image direction
    }
    func consumeItem(c:Consumable)
    {
        //inform the server
        //perform stat changes
    }

}





class OtherCharacter:Entity {
    var charClass:CharClass
    init(_class:CharClass, _ID:String) {
        charClass = _class
        super.init(_ID: _ID)
    }
}





class Enemy:Entity {
    
}
