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
enum StatTypes {
    case health
    case defense
    case attack
    case speed
    case dexterity
    case hunger
    case level
    case mana
    case rage
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
    var ID:String
    
    init(_ID:String)
    {
        ID = _ID
    }
    
}

class ThisCharacter: Entity {
    var node:SKSpriteNode? //TODO: Turn into graphical texture
    var charClass:CharClass?
    var stats:Stats?
    var equipped:EquippedItems?
    var currentProjectile:Projectile {
        get{
            return equipped!.weapon.projectile! //set weapon based on item
        }
    }
    
    ///POSITION/DIRECTION METHODS
    
    init(_class:CharClass, _ID: String) {
        super.init(_ID: _ID)
        charClass = _class
        node = SKSpriteNode(texture: SKTextureAtlas(named: "chars").textureNamed(charClass!.img_base))
        node!.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
    }
    ///GRAPHICAL METHODS
        func setImageOrientation() {
            // change image direction
        }
        func setScreenLoc(newLoc:CGPoint) //TODO: Write dynamic screen locations
        {
          //  posData!.screenLoc = newLoc
            node!.position = newLoc
        }
    
    //ITEM HANDLER METHODS
        func consumeItem(c:Consumable)
        {
            //inform the server
            //perform stat changes
        }
    
        ///equip functions
            func equipShield(shield:Shield) -> Shield?
            {
                let old = equipped?.shield
                equipped?.shield = shield
                return old
            }
            func equipWeapon(weapon:Weapon) -> Weapon?
            {
                let old = equipped?.weapon
                equipped?.weapon = weapon
                return old
            }
            func equipEnhancer(enhancer:Enhancer) -> Enhancer?
            {
                let old = equipped?.enhancer
                equipped?.enhancer = enhancer
                return old
            }
            func equipSkill(skill:Skill) -> Skill?
            {
                let old = equipped?.skill
                equipped?.skill = skill
                return old
            }
    ///////////////////
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
