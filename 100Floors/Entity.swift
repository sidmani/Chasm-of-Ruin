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
    var health:CGFloat    // Health
    var defense:CGFloat   // Defense (% projectile is weakened by)
    var attack:CGFloat    // Attack (% own projectile is strengthened by)
    var speed:CGFloat     // Speed
    var dexterity:CGFloat // Dexterity (rate of projectile release)
    var hunger:CGFloat    // Hunger (decrease with time)
    var level:CGFloat     // Level (Overall boost to all stats)
    var mana:CGFloat      // Mana (used when casting spells)
    var rage:CGFloat      // Builds up over time, released when hunger/health are low (last resort kinda thing)
}

struct EquippedItems {
    var shield:Item?
    var weapon:Item?
    var enhancer:Item?
    var skill:Item?
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
    //var charClass:CharClass
    var stats:Stats = nullStats
    private var projectileTimer:NSTimer?
    private var projectileTimerEnabled = false
    var equipped:EquippedItems = EquippedItems(shield: nil, weapon: nil, enhancer: nil, skill: nil)
    
    //convenience variables
    var currentProjectile:String {
        get{
            return equipped.weapon!.projectile! //set weapon based on item
        }
    }
    var velocity:CGVector?
    {
        get {
            return CGVector(dx: 5*LeftJoystick!.displacement.dx, dy: 5*LeftJoystick!.displacement.dy)
            //return CGVector(dx: 5*stats.speed*LeftJoystick!.displacement.dx, dy: 5*stats.speed*LeftJoystick!.displacement.dy)
        }
    }
    
    /////////////
    var absoluteLoc:CGPoint { //TODO: is this even necessary? (use collisions)
        set {
            GameLogic.gameScene!.nonCharNodes.position = GameLogic.calculateMapPosition(newValue)
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
    
    init(_ID: String, _absoluteLoc: CGPoint) {
        super.init(_ID: _ID, texture: SKTextureAtlas(named: "chars").textureNamed("character"))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10.0) //TODO: fix this
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.friction = 0
        self.physicsBody!.pinned = true
        self.physicsBody!.categoryBitMask = thisPlayerMask
        self.physicsBody!.contactTestBitMask = enemyProjectileMask | mapObjectMask
        self.physicsBody!.collisionBitMask = 0x0
        absoluteLoc = _absoluteLoc

        //absoluteLoc = CGPointMake(0, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///POSITION/DIRECTION METHODS
    
    ///GRAPHICAL METHODS
    private func setImageOrientation() {
        // change image direction
    }
    
    //ITEM HANDLER METHODS
    func consumeItem(c:Item)
    {
        //perform stat changes
    }
    
    ///equip functions
    func equipShield(shield:Item) -> Item?
    {
        let old:Item? = equipped.shield
        equipped.shield = shield
        return old
    }
    
    func equipWeapon(weapon:Item) -> Item?
    {
        let old:Item? = equipped.weapon
        equipped.weapon = weapon
        return old
    }
    
    func equipEnhancer(enhancer:Item) -> Item?
    {
        let old:Item? = equipped.enhancer
        equipped.enhancer = enhancer
        return old
    }
    
    func equipSkill(skill:Item) -> Item?
    {
        let old:Item? = equipped.skill
        equipped.skill = skill
        return old
    }
    
    ///////////////////
    //Projectile Methods
    @objc private func fireProjectile() {
        let newProjectile = Projectile(withID: currentProjectile, fromPoint: absoluteLoc, withVelocity: CGVector(dx: 5*RightJoystick!.displacement.dx, dy: 5*RightJoystick!.displacement.dy), isFriendly: true)
        //TODO: check if projectiles can be shot etc
        GameLogic.addProjectile(newProjectile)
    }
    
    private func attachProjectileCreator(enable:Bool) {
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
    //////////////////
    //Update methods
    
    private func updateProjectileState() {
        if (RightJoystick!.currentPoint != CGPoint(x: 0, y: 0) && !self.projectileTimerEnabled)
        {
            self.attachProjectileCreator(true)
        }
        else if (RightJoystick!.currentPoint == CGPoint(x: 0, y: 0) && self.projectileTimerEnabled)
        {
            self.attachProjectileCreator(false)
        }

    }
    func update() {
        updateProjectileState()
    }
    ///////////////////
}




class Enemy:Entity {
    
}
