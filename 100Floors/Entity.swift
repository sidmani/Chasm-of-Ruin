//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//
import SpriteKit

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
    static let nilStats = Stats(health: 0, defense: 0, attack: 0, speed: 0, dexterity: 0, hunger: 0, level: 0, mana: 0, rage: 0)
}

func +(left: Stats, right: Stats) -> Stats { // add Stats together
    return Stats(health: left.health + right.health,  defense: left.defense + right.defense, attack: left.attack + right.attack, speed: left.speed+right.speed, dexterity: left.dexterity + right.dexterity, hunger: left.hunger + right.hunger, level: left.level+right.level, mana: left.mana+right.mana, rage: left.rage + right.rage)
}

//////////////////////


class Entity:SKSpriteNode {
    var currStats:Stats
    var baseStats:Stats
    var inventory:Inventory
    
    private var weapon:Item? {
        return inventory.getItem(inventory.weaponIndex)
    }
    private var skill:Item? {
        return inventory.getItem(inventory.skillIndex)
    }
    private var shield:Item? {
        return inventory.getItem(inventory.shieldIndex)
    }
    private var enhancer:Item? {
        return inventory.getItem(inventory.enhancerIndex)
    }
    
    init(fromTexture: SKTexture, withCurrStats:Stats, withBaseStats:Stats, withInventory:Inventory)
    {
        currStats = withCurrStats
        baseStats = withBaseStats
        inventory = withInventory
        super.init(texture: fromTexture, color: UIColor.clearColor(), size: fromTexture.size())
        self.zPosition = BaseLevel.LayerDef.Entity

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func struckByProjectile(p:Projectile) {
    
    }
    
    private func setImageOrientation() {
        // change image direction
    }
    
    func die() {
        
    }
    
}

//////////////////////

class ThisCharacter: Entity, Updatable {
    
    private var timeSinceProjectile:Double = 0
    
    //////////////
    //INIT
    init() {
        super.init(fromTexture: SKTextureAtlas(named: "chars").textureNamed("character"), withCurrStats: Stats.nilStats, withBaseStats: Stats.nilStats, withInventory: Inventory(withEquipment: true, withSize: inventory_size))

        self.physicsBody = SKPhysicsBody(circleOfRadius: 10.0) //TODO: fix this
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.ThisPlayer
        self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.Enemy | InGameScene.PhysicsCategory.EnemyProjectile | InGameScene.PhysicsCategory.Interactive
        self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        self.position = screenCenter
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///collision handling
    override func struckByProjectile(p:Projectile) {
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
       
    
    //ITEM HANDLER METHODS
    func consumeItem(c:Item)
    {
        if (c.consumable)
        {
            if (c.permanent!) {
                baseStats = baseStats + c.statMods
            }
            else {
                currStats = currStats + c.statMods
            }
        }
    }

    func fireProjectile(withVelocity:CGVector) {
        if (weapon != nil) {
            let newProjectile = Projectile(withID: weapon!.projectile!, fromPoint: position, withVelocity: withVelocity, isFriendly: true, withRange: weapon!.range!, withAtk: self.currStats.attack, reflects: weapon!.projectileReflects!)
            GameLogic.addObject(newProjectile)
        }
    }

    
    func update(deltaT:Double) {
        if (UIElements.RightJoystick!.currentPoint != CGPointZero && timeSinceProjectile > 300) {
            fireProjectile(CGVector(dx: weapon!.projectileSpeed!*cos(UIElements.RightJoystick!.angle), dy: -weapon!.projectileSpeed!*sin(UIElements.RightJoystick!.angle)))
            timeSinceProjectile = 0
        }
        else {
            timeSinceProjectile += deltaT
        }

        self.physicsBody?.velocity = CGVector(dx: 5*UIElements.LeftJoystick!.displacement.dx, dy: 5*UIElements.LeftJoystick!.displacement.dy)
    }
}


class Enemy:Entity, Updatable{

    private var AI:EnemyAI?
    
    init(thisEnemy:AEXMLElement, atPosition:CGPoint) {
        let _baseStats = Stats.statsFrom(thisEnemy)
        super.init(fromTexture: SKTexture(imageNamed: thisEnemy["img"].stringValue), withCurrStats: _baseStats, withBaseStats: _baseStats, withInventory: Inventory(fromElement: thisEnemy["inventory"]))
        AI = EnemyAI(parent: self, withBehaviors: thisEnemy["behaviors"]["behavior"].all!)
        physicsBody = SKPhysicsBody(circleOfRadius: 10)
        physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.FriendlyProjectile
        physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        position = atPosition
    }
    

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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func struckByProjectile(p:Projectile) {
        
    }
    
    func fireProjectile(atAngle:CGFloat) {
        if (weapon != nil) {
            let newProjectile = Projectile(withID: weapon!.projectile!, fromPoint: position, withVelocity: CGVector(dx: weapon!.projectileSpeed!*cos(atAngle), dy: weapon!.projectileSpeed!*sin(atAngle)), isFriendly: false, withRange:weapon!.range!, withAtk: self.currStats.attack, reflects: weapon!.projectileReflects!)
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
        if (self.position != thisCharacter.position) {
            return atan2(thisCharacter.position.y - self.position.y, thisCharacter.position.x - self.position.x)
        }
        else {
            return 0
        }
    }
    
    func update(deltaT:Double) {
        AI?.update(deltaT)
    }
    
    override func die() {
        //do some kind of animation
        //drop inventory
        removeFromParent()
    }
    
}
