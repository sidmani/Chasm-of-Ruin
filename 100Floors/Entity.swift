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
        var stats1 = nilStats, stats2 = nilStats, stats3 = nilStats, stats4 = nilStats
        if (shield != nil) {
            stats1 = shield!.statMods
        }
        if (weapon != nil) {
            stats2 = weapon!.statMods
        }
        if (enhancer != nil) {
            stats3 = enhancer!.statMods
        }
        if (skill != nil) {
            stats4 = skill!.statMods
        }
        return stats1 + stats2 + stats3 + stats4
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

class ThisCharacter: Entity, Updatable {
    var inventory:Inventory
    private var currStats:Stats
    private var baseStats:Stats
    private var projectileTimer:NSTimer?
    private var projectileTimerEnabled = false
    private var equipped:EquippedItems
    
    //convenience variables
    var currentProjectile:String? {
        get{
            return equipped.weapon?.projectile //set weapon based on item
        }
    }
    var velocity:CGVector
    {
        get {
            return CGVector(dx: 5*UIElements.LeftJoystick!.displacement.dx, dy: 5*UIElements.LeftJoystick!.displacement.dy)
            //return CGVector(dx: 5*currStats.speed*LeftJoystick!.displacement.dx, dy: 5*currStats.speed*LeftJoystick!.displacement.dy)
        }
    }
    
    /////////////
    var absoluteLoc:CGPoint {
        get {
            return GameLogic.getPositionOnMap(self)
        }
    }
  
    //////////////
    //INIT
    init() {
        currStats = nilStats
        baseStats = nilStats
        inventory = Inventory()
        equipped = EquippedItems(shield: nil, weapon: nil, enhancer: nil, skill: nil)
        super.init(_ID: "mainchar", texture: SKTextureAtlas(named: "chars").textureNamed("character"))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10.0) //TODO: fix this
        self.physicsBody?.friction = 0
        self.physicsBody?.pinned = true //really?
        self.physicsBody?.categoryBitMask = PhysicsCategory.ThisPlayer
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.EnemyProjectile | PhysicsCategory.Interactive
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.position = screenCenter
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///collision handling
    func struckByProjectile(p:Projectile) {
        takeDamage(p.attack - currStats.defense)
    }
    //health/stats handling
    private func takeDamage(d:CGFloat) {
        currStats.health -= d
        if (currStats.health <= 0) {
            currStats.health = 0
            die()
        }
    }
    private func die() {
        
    }
    ///GRAPHICAL METHODS
    private func setImageOrientation() {
        // change image direction
    }
    
    //ITEM HANDLER METHODS
    func consumeItem(c:Item?)
    {
        if (c != nil && c!.consumable)
        {
            if (c!.permanent) {
                baseStats = baseStats + c!.statMods
            }
            else {
                currStats = currStats + c!.statMods
            }
        }
    }
    ///equip functions
    func equipItem(new:Item) -> Item? {
            switch (new.type)
            {
            case ItemType.Shield:
                let old = equipped.shield
                equipped.shield = new
                return old
            case ItemType.Skill:
                let old = equipped.skill
                equipped.skill = new
                return old
            case ItemType.Weapon:
                let old = equipped.weapon
                equipped.weapon = new
                return old
            case ItemType.Enhancer:
                let old = equipped.enhancer
                equipped.enhancer = new
                return old
            case ItemType.Style:
                return nil
            }
    }
    
    ///////////////////
    //Projectile Methods
    func fireProjectile(withVelocity:CGVector) {
        if (equipped.weapon != nil) {
            let newProjectile = Projectile(withID: currentProjectile!, fromPoint: absoluteLoc, withVelocity: withVelocity, isFriendly: true, withRange: equipped.weapon!.range, withAtk: 10)
            GameLogic.addProjectile(newProjectile)
        }
    }
    
    @objc private func fireProjectileFromTimer() {
        if (equipped.weapon != nil) {
            let newProjectile = Projectile(withID: currentProjectile!, fromPoint: absoluteLoc, withVelocity: CGVector(dx: 500*cos(UIElements.RightJoystick!.angle), dy: -500*sin(UIElements.RightJoystick!.angle)), isFriendly: true, withRange: equipped.weapon!.range, withAtk: self.currStats.attack)
            //TODO: check if projectiles can be shot etc
            GameLogic.addProjectile(newProjectile)
        }
    }
    
    private func attachProjectileCreator(enable:Bool) {
        if (enable) {
            fireProjectileFromTimer()
            projectileTimerEnabled = true
            projectileTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "fireProjectileFromTimer", userInfo: nil, repeats: true) //TODO: calculate rate of fire
        }
        else {
            projectileTimerEnabled = false
            projectileTimer?.invalidate()
        }
    }
    
    //////////////////
    //Update methods
    
    private func updateProjectileState() {
        if (!projectileTimerEnabled && UIElements.RightJoystick!.currentPoint != CGPointZero)
        {
            attachProjectileCreator(true)
        }
        else if (projectileTimerEnabled && UIElements.RightJoystick!.currentPoint == CGPointZero)
        {
            attachProjectileCreator(false)
        }
    }
   
    func update() {
        updateProjectileState()
    }
}




class Enemy:Entity, Updatable{
    func update() {
        //run AI
    }
    func die() {
        
    }
    
}
