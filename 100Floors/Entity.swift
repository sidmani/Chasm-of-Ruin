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
    func getIndex(i:Int) -> CGFloat{
        switch (i) {
        case 0: return health
        case 1: return defense
        case 2: return attack
        case 3: return speed
        case 4: return dexterity
        case 5: return hunger
        case 6: return level
        case 7: return mana
        case 8: return rage
        default: return 0
        }
    }
    
    mutating func setIndex(i:Int, toVal:CGFloat) {
        switch (i) {
        case 0: health = toVal
        case 1: defense = toVal
        case 2: attack = toVal
        case 3: speed = toVal
        case 4: dexterity = toVal
        case 5: hunger = toVal
        case 6: level = toVal
        case 7: mana = toVal
        case 8: rage = toVal
        default: break
        }
    }
    
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
    init(fromTexture: SKTexture)
    {
        super.init(texture: fromTexture, color: UIColor.clearColor(), size: fromTexture.size())
        self.physicsBody?.friction = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//////////////////////

class ThisCharacter: Entity, Updatable {
    var currStats:Stats
    var baseStats:Stats
    
    private var inventory:Inventory
  //  private var projectileTimer:NSTimer?
  //  private var projectileTimerEnabled = false
    private var timeSinceProjectile:Double = 0
   /* var currentProjectile:String? {
        get{
            return inventory.getItem(inventory.weaponIndex)?.projectile //set weapon based on item
        }
    }*/

    //////////////
    //INIT
    init() {
        currStats = nilStats
        baseStats = nilStats
        inventory = Inventory(withEquipment: true, withSize: inventory_size)
        super.init(fromTexture: SKTextureAtlas(named: "chars").textureNamed("character"))
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10.0) //TODO: fix this
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
            let newProjectile = Projectile(withID: inventory.getItem(inventory.weaponIndex)!.projectile, fromPoint: position, withVelocity: withVelocity, isFriendly: true, withRange: inventory.getItem(inventory.weaponIndex)!.range, withAtk: self.currStats.attack)
            GameLogic.addObject(newProjectile)
        }
    }
    
    @objc private func fireProjectileFromTimer() {
        if (inventory.getItem(inventory.weaponIndex) != nil) {
            let weapon = inventory.getItem(inventory.weaponIndex)!
            let newProjectile = Projectile(withID: weapon.projectile, fromPoint: position, withVelocity: CGVector(dx: weapon.projectileSpeed*cos(UIElements.RightJoystick!.angle), dy: -weapon.projectileSpeed*sin(UIElements.RightJoystick!.angle)), isFriendly: true, withRange:weapon.range, withAtk: self.currStats.attack)
            //TODO: check if projectiles can be shot etc
            GameLogic.addObject(newProjectile)
        }
    }

    
    //////////////////
    //Update methods

   
    func update(deltaT:Double) {
        if (UIElements.RightJoystick!.currentPoint != CGPointZero && timeSinceProjectile > 300) {
            fireProjectileFromTimer()
            timeSinceProjectile = 0
        }
        else {
            timeSinceProjectile += deltaT
        }
        self.physicsBody!.velocity = CGVector(dx: 5*UIElements.LeftJoystick!.displacement.dx, dy: 5*UIElements.LeftJoystick!.displacement.dy)
    }
}




class Enemy:Entity, Updatable{
    var currStats:Stats
    var baseStats:Stats
    private var inventory:Inventory
    private var AI:EnemyAI?
    convenience init(withID:String, atPosition:CGPoint) {
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
        self.init(thisEnemy: thisEnemy, atPosition: atPosition)
    }
    
    init(thisEnemy:AEXMLElement, atPosition:CGPoint) {
        baseStats = Stats.statsFrom(thisEnemy)
        currStats = baseStats
        inventory = Inventory(fromElement: thisEnemy["inventory"])
        super.init(fromTexture: SKTexture(imageNamed: thisEnemy["img"].stringValue))
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
    
    func fireProjectile(atAngle:CGFloat) {
        if (inventory.getItem(inventory.weaponIndex) != nil) {
            let weapon = inventory.getItem(inventory.weaponIndex)!
            let newProjectile = Projectile(withID: weapon.projectile, fromPoint: position, withVelocity: CGVector(dx: weapon.projectileSpeed*cos(atAngle), dy: weapon.projectileSpeed*sin(atAngle)), isFriendly: true, withRange:weapon.range, withAtk: self.currStats.attack)
        
            //TODO: check if projectiles can be shot etc
            GameLogic.addObject(newProjectile)
        }
    }

    func validateMoveTo(point:CGPoint) -> Bool {
        return false
    }
    
    func distanceToCharacter() -> CGFloat {
        return hypot(self.position.x - thisCharacter.position.x, self.position.y - thisCharacter.position.y)
    }
    
    func angleToCharacter() -> CGFloat {
        return atan2(thisCharacter.position.y - self.position.y, thisCharacter.position.x - self.position.x)
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
