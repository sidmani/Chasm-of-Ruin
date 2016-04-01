//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//
import SpriteKit

struct Stats {
    let numStats = 7
    
    var health:CGFloat    // Health
    var defense:CGFloat   // Defense (% projectile is weakened by)
    var attack:CGFloat    // Attack (% own projectile is strengthened by)
    var speed:CGFloat     // Speed
    var dexterity:CGFloat // Dexterity (rate of projectile release)
    var mana:CGFloat      // Mana (used when casting spells)
    var rage:CGFloat      // Boosts with combos
    
    func getIndex(index:Int) -> CGFloat{
        switch (index) {
        case 0: return health
        case 1: return defense
        case 2: return attack
        case 3: return speed
        case 4: return dexterity
        case 5: return mana
        case 6: return rage
        default: return 0
        }
    }
    
    mutating func setIndex(index:Int, toVal:CGFloat) {
        switch (index) {
        case 0: health = toVal
        case 1: defense = toVal
        case 2: attack = toVal
        case 3: speed = toVal
        case 4: dexterity = toVal
        case 5: mana = toVal
        case 6: rage = toVal
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
            mana: CGFloat(Element["Stats"]["mana"].doubleValue),
            rage: CGFloat(Element["Stats"]["rage"].doubleValue))
    }
    
    mutating func capAt(maxVal:CGFloat) {
        for i in 0..<numStats {
            setIndex(i, toVal: max(getIndex(i), maxVal))
        }
    }
    
    static let nilStats = Stats(health: 0, defense: 0, attack: 0, speed: 0, dexterity: 0, mana: 0, rage: 0)
}

func +(left: Stats, right: Stats) -> Stats { // add Stats together
    return Stats(health: left.health + right.health,  defense: left.defense + right.defense, attack: left.attack + right.attack, speed: left.speed+right.speed, dexterity: left.dexterity + right.dexterity, mana: left.mana+right.mana, rage: left.rage + right.rage)
}

//////////////////////


class Entity:SKSpriteNode {
    var currStats:Stats
    var baseStats:Stats
    var inventory:Inventory
    private var textures:[SKTexture?] = [SKTexture?](count:4, repeatedValue:nil) //0 - north, 1 - east, 2 - south, 3 - west
    private var weapon:Weapon? {
        return inventory.getItem(inventory.weaponIndex) as? Weapon
    }
    private var skill:Item? {
        return inventory.getItem(inventory.skillIndex) as? Skill
    }
    private var shield:Item? {
        return inventory.getItem(inventory.shieldIndex) as? Shield
    }
    private var enhancer:Item? {
        return inventory.getItem(inventory.enhancerIndex) as? Enhancer
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
    
    private func setImageOrientation(toAngle:CGFloat) {
        let direction = Int((4 / 6.28) * toAngle)
        
        // change image direction
    }
    
    private func takeDamage(d:CGFloat) {
        currStats.health -= d
        if (currStats.health <= 0) {
            currStats.health = 0
            die()
        }
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
        self.position = CGPoint(x: Int(screenSize.width/2), y: Int(screenSize.height/2))

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///collision handling
    override func struckByProjectile(p:Projectile) {
        takeDamage(p.attack - currStats.defense)
    }
    //health/stats handling
   /* private override func takeDamage(d:CGFloat) {
        currStats.health -= d
        if (currStats.health <= 0) {
            currStats.health = 0
            die()
        }
    }*/
    override func die() {
        //lose all inventory and 1 random equipment
        //save game
        //display death screen
    }
    
    //ITEM HANDLER METHODS
    func consumeItem(c:Item)
    {
        if let consumable = c as? Consumable
        {
            if (consumable.permanent) {
                baseStats = baseStats + c.statMods
            }
            else {
                currStats = currStats + c.statMods
            }
        }
    }

    func fireProjectile(withVelocity:CGVector) {
        if (weapon != nil) {
            let newProjectile = Projectile(withID: weapon!.projectile, fromPoint: position, withVelocity: withVelocity, isFriendly: true, withRange: weapon!.range, withAtk: self.currStats.attack, reflects: weapon!.projectileReflects)
            GameLogic.addObject(newProjectile)
        }
    }

    
    func update(deltaT:Double) {
        if (UIElements.RightJoystick!.currentPoint != CGPointZero && timeSinceProjectile > 300 && weapon != nil) {
            fireProjectile(weapon!.projectileSpeed * UIElements.RightJoystick!.displacement)
            timeSinceProjectile = 0
        }
        else {
            timeSinceProjectile += deltaT
        }

        self.physicsBody?.velocity = 50*UIElements.LeftJoystick!.displacement
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
    
    func fireProjectile(withVelocity:CGVector) {
        if (weapon != nil) {
            let newProjectile = Projectile(withID: weapon!.projectile, fromPoint: position, withVelocity: weapon!.projectileSpeed*withVelocity, isFriendly: false, withRange:weapon!.range, withAtk: self.currStats.attack, reflects: weapon!.projectileReflects)
            //TODO: check if projectiles can be shot etc
            GameLogic.addObject(newProjectile)
        }
    }
    
    func fireProjectileAngle(atAngle:CGFloat) {
        fireProjectile(CGVectorMake(cos(atAngle), sin(atAngle)))
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
    func normalVectorToCharacter() -> CGVector {
        let dist = distanceToCharacter()
        return CGVectorMake((self.position.x - thisCharacter.position.x)/dist, (self.position.y - thisCharacter.position.y)/dist)
    }
    
    func update(deltaT:Double) {
        AI?.update(deltaT)
    }
    
    override func die() {
        //do some kind of animation
        for item in inventory.dropAllItems() {
            if (item != nil) {
                let newPoint = CGPointMake(randomBetweenNumbers(self.position.x-20, secondNum: self.position.x+20), randomBetweenNumbers(self.position.y-20, secondNum: self.position.y+20))
                GameLogic.addObject(ItemBag(withItem: item!, loc: newPoint))
            }
        } //drop inventory
        removeFromParent()
    }
    
}
