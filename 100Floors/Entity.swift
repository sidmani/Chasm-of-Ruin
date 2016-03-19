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
    static func statsFrom(Element:AEXMLElement) -> Stats {
        return Stats(
            health: CGFloat(Element["Stats"]["health"].doubleValue),
            defense: CGFloat(Element["Stats"]["def"].doubleValue),
            attack: CGFloat(Element["Stats"]["atk"].doubleValue),
            speed: CGFloat(Element["Stats"]["spd"].doubleValue),
            dexterity: CGFloat(Element["Stats"]["dex"].doubleValue),
            hunger: CGFloat(Element["Stats"]["hunger"].doubleValue),
            level: CGFloat(Element["Stats"]["level"].doubleValue),
            mana: CGFloat(Element["Stats"]["mana"].doubleValue),
            rage: CGFloat(Element["Stats"]["rage"].doubleValue))
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
    private var inventory:Inventory
    private var currStats:Stats
    private var baseStats:Stats
    private var projectileTimer:NSTimer?
    private var projectileTimerEnabled = false
    
    var currentProjectile:String? {
        get{
            return inventory.getItem(inventory.weaponIndex)?.projectile //set weapon based on item
        }
    }

    //////////////
    //INIT
    init() {
        currStats = nilStats
        baseStats = nilStats
        inventory = Inventory(withEquipment: true, withSize: inventory_size)
        super.init(_ID: "mainchar", texture: SKTextureAtlas(named: "chars").textureNamed("character"))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10.0) //TODO: fix this
        self.physicsBody?.friction = 0
        self.physicsBody?.categoryBitMask = PhysicsCategory.ThisPlayer
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.EnemyProjectile | PhysicsCategory.Interactive
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.position = screenCenter
        self.zPosition = 5
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
    func consumeItem(c:Item)
    {
        if (c.consumable)
        {
            if (c.permanent) {
                baseStats = baseStats + c.statMods
            }
            else {
                currStats = currStats + c.statMods
            }
        }
    }
    func getInventory() -> Inventory {
        return inventory
    }
    ///////////////////
    //Projectile Methods
    func fireProjectile(withVelocity:CGVector) {
        if (inventory.getItem(inventory.weaponIndex) != nil) {
            let newProjectile = Projectile(withID: currentProjectile!, fromPoint: position, withVelocity: withVelocity, isFriendly: true, withRange: inventory.getItem(inventory.weaponIndex)!.range, withAtk: 10)
            GameLogic.addObject(newProjectile)
        }
    }
    
    @objc private func fireProjectileFromTimer() {
        if (inventory.getItem(inventory.weaponIndex) != nil) {
            let newProjectile = Projectile(withID: currentProjectile!, fromPoint: position, withVelocity: CGVector(dx: 500*cos(UIElements.RightJoystick!.angle), dy: -500*sin(UIElements.RightJoystick!.angle)), isFriendly: true, withRange:inventory.getItem(inventory.weaponIndex)!.range, withAtk: self.currStats.attack)
            //TODO: check if projectiles can be shot etc
            GameLogic.addObject(newProjectile)
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
   
    func update(deltaT:Double) {
        updateProjectileState()
        self.physicsBody!.velocity = CGVector(dx: 5*UIElements.LeftJoystick!.displacement.dx, dy: 5*UIElements.LeftJoystick!.displacement.dy)
    }
}




class Enemy:Entity, Updatable{
    var currStats:Stats
    var baseStats:Stats
    private var AI:EnemyAI?
    //enum EnemyStates {
    //    case Attack, Defend, Wander
    //}
    
    init(withID:String, atPosition:CGPoint) {
        var thisEnemy:AEXMLElement
        if let enemies = enemyXML!.root["enemies"]["enemy"].allWithAttributes(["id":withID]) {
            if (enemies.count != 1) {
                fatalError("Enemy ID error")
            }
            else {
                thisEnemy = enemies[0]
            }
        }
        else {
            fatalError("Enemy Not Found")
        }
        baseStats = Stats.statsFrom(thisEnemy)
        currStats = baseStats
        super.init(_ID: withID, texture: SKTexture(imageNamed: thisEnemy["img"].stringValue))
        AI = EnemyAI(parent: self, withBehaviors: thisEnemy["behaviors"]["behavior"].all!)
        physicsBody = SKPhysicsBody()
        physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.FriendlyProjectile
        physicsBody?.collisionBitMask = PhysicsCategory.None
        position = atPosition
        zPosition = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func projectileEnteredRadius() {
        
    }
    
    func playerEnteredRadius() {
        
    }
    
    func validateMoveTo(point:CGPoint) -> Bool {
        return false
    }
    func distanceToPlayer() -> CGFloat {
        return hypot(self.position.x - thisCharacter.position.x, self.position.y - thisCharacter.position.y)
    }
    
    func update(deltaT:Double) {
        AI?.update(deltaT)
    }
    
    func die() {
        //do some kind of animation
        //drop inventory
        removeFromParent()
    }
    
}
