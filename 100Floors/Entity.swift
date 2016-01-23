//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//
import SpriteKit

//// data structs ////
struct Stats { //TODO: add base stat and current stat definitions
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

struct EquippedItems {
    var shield:Shield?
    var weapon:Weapon?
    var enhancer:Enhancer?
    var skill:Skill?
    func totalStatChanges() -> Stats {
        return shield!.statMods+weapon!.statMods+skill!.statMods+enhancer!.statMods
    }
}
//////////////////////


class Entity:SKSpriteNode {
    
    var ID:String
    init(_ID:String, texture: SKTexture)
    {
        ID = _ID
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//////////////////////

class ThisCharacter: Entity {
    // properties
    var inventory:Inventory = Inventory()
    var charClass:CharClass
    var stats:Stats = nullStats
    var projectileTimer:NSTimer?
    var projectileTimerEnabled = false
    var equipped:EquippedItems = EquippedItems(shield: nil, weapon: nil, enhancer: nil, skill: nil)
    
    //convenience variables
    var currentProjectile:ProjectileDefinition {
        get{
            return equipped.weapon!.projectile! //set weapon based on item
        }
    }
    var velocity:CGVector?
        {
        get {
            return CGVector(dx: 5*LeftJoystick!.dx, dy: 5*LeftJoystick!.dy) //TODO: item modifies speed
        }
    }
    
    /////////////
    
    var absoluteLoc:CGPoint? { // guaranteed to be correct, unless server returns different value
        set {
            nonSelfNodes.position = GameLogic.calculateMapPosition(newValue!)
        }
        get {
            return GameLogic.calculateRelativePosition(self)
        }
    }
    
    var screenLoc:CGPoint? {
        didSet {
            self.position = screenLoc!
        }
    }
    
  
    //////////////
    //INIT
    
    init(_class:CharClass, _ID: String) {
        charClass = _class
        super.init(_ID: _ID, texture: SKTextureAtlas(named: "chars").textureNamed(charClass.img_base))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.friction = 0
        self.physicsBody!.pinned = true
        absoluteLoc = CGPointMake(0, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///POSITION/DIRECTION METHODS
    
    ///GRAPHICAL METHODS
    func setImageOrientation() {
        // change image direction
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
        let old:Shield? = equipped.shield
        equipped.shield = shield
        return old
    }
    
    func equipWeapon(weapon:Weapon) -> Weapon?
    {
        let old:Weapon? = equipped.weapon
        equipped.weapon = weapon
        return old
    }
    
    func equipEnhancer(enhancer:Enhancer) -> Enhancer?
    {
        let old:Enhancer? = equipped.enhancer
        equipped.enhancer = enhancer
        return old
    }
    
    func equipSkill(skill:Skill) -> Skill?
    {
        let old:Skill? = equipped.skill
        equipped.skill = skill
        return old
    }
    
    ///////////////////
    //Projectile Methods
    @objc func fireProjectile() {
        let newProjectile = Projectile(definition: currentProjectile, fromPoint: absoluteLoc!, withVelocity: CGVector(dx: 5*RightJoystick!.dx, dy: 5*RightJoystick!.dy))
        nonMapNodes.addChild(newProjectile)
    }
    
    func attachProjectileCreator(enable:Bool) {
        if (enable) {
            fireProjectile()
            projectileTimerEnabled = true
            projectileTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "fireProjectile", userInfo: nil, repeats: true) //TODO: calculate rate of fire
        }
        else {
            projectileTimerEnabled = false
            if ((projectileTimer) != nil) {
                projectileTimer!.invalidate()
            }
        }
    }
    ///////////////////
}





class OtherCharacter:Entity {
   // var charClass:CharClass
   // init(_class:CharClass, _ID:String) {
   //     charClass = _class
   //     super.init(_ID: _ID)
   // }
}





class Enemy:Entity {
    
}
