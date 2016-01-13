//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//
import SpriteKit
struct stats {
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
struct posData {
    var absoluteLoc:CGPoint
    var screenLoc:CGPoint //TODO: Make computed property
    var velocity:CGFloat
    var direction:CGFloat //direction in radians
}
struct equipped_items {
    
}
class Entity { //TODO: rewrite properties in class
    var absoluteLoc:CGPoint = CGPoint(x: 0, y: 0)
    var screenLoc:CGPoint = CGPoint(x: 0, y: 0)
    var velocity:CGFloat = 0
    var moveAngle:CGFloat = 0
    var ID:String
    
    init(_ID:String)
    {
        ID = _ID
    }
    
}

class ThisCharacter: Entity {
    var thisNode:SKSpriteNode //TODO: fix this
    var thisCharClass:charClass
  
    
    override var moveAngle:CGFloat {
        get {
            return left_joystick_angle
        }
        set {
        }
    }
//  var currentProjectile:Projectile //set based on item, dynamic assigment
    init(_class:charClass, _ID:String) {
        thisCharClass = _class
        thisNode = SKSpriteNode(imageNamed: thisCharClass.img_base)
        super.init(_ID: _ID)
    }
    func setScreenLoc(newLoc:CGPoint)
    {
        screenLoc = newLoc
        thisNode.position = newLoc
    }
    func setImageOrientation() {
        // change image direction
    }

}





class OtherCharacter:Entity {
    var thisCharClass:charClass
    init(_class:charClass, _ID:String) {
        thisCharClass = _class
        super.init(_ID: _ID)
    }
}





class Enemy:Entity {
    
}
