//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//
import SpriteKit

struct Stats {
    static let numStats = 8
    
    var defense:CGFloat   // Defense (% projectile is weakened by)
    var attack:CGFloat    // Attack (% own projectile is strengthened by)
    var speed:CGFloat     // Speed
    var dexterity:CGFloat // Dexterity (rate of projectile release)
    
    var health:CGFloat    // Health
    var maxHealth:CGFloat
    
    var mana:CGFloat      // Mana (used when casting spells)
    var maxMana:CGFloat

    func getIndex(index:Int) -> CGFloat {
        switch (index) {
        case 0: return health
        case 1: return defense
        case 2: return attack
        case 3: return speed
        case 4: return dexterity
        case 5: return mana
        case 6: return maxHealth
        case 7: return maxMana
        default: return 10
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
        case 6: maxHealth = toVal
        case 7: maxMana = toVal
        default: break
        }
    }
    
    func toArray() -> NSArray {
        return NSArray(array: [health,defense,attack,speed,dexterity,mana, maxHealth, maxMana])
    }
    
    mutating func capAt(maxVal:CGFloat) {
        for i in 0..<Stats.numStats {
            setIndex(i, toVal: min(getIndex(i), maxVal))
        }
    }
    
    static func statsFrom(Array:NSArray) -> Stats {
        var out = nilStats
        for i in 0..<numStats {
            out.setIndex(i, toVal: Array[i] as! CGFloat)
        }
        return out
    }
    
    static func statsFrom(Element:AEXMLElement) -> Stats {
        return Stats(
            defense: CGFloat(Element["stats"]["def"].doubleValue),
            attack: CGFloat(Element["stats"]["atk"].doubleValue),
            speed: CGFloat(Element["stats"]["spd"].doubleValue),
            dexterity: CGFloat(Element["stats"]["dex"].doubleValue),
            health: CGFloat(Element["stats"]["health"].doubleValue),
            maxHealth: CGFloat(Element["stats"]["maxHealth"].doubleValue),
            mana: CGFloat(Element["stats"]["mana"].doubleValue),
            maxMana: CGFloat(Element["stats"]["maxMana"].doubleValue)
        )
    }
    
    static let nilStats = Stats(defense: 0, attack: 0, speed: 0, dexterity: 0, health: 0, maxHealth: 0, mana: 0, maxMana: 0)
}

func +(left:Stats?, right:Stats?) -> Stats{
    if (left != nil && right != nil) {
        return Stats(defense: left!.defense + right!.defense, attack: left!.attack + right!.attack, speed: left!.speed+right!.speed, dexterity: left!.dexterity + right!.dexterity, health: left!.health + right!.health, maxHealth: left!.maxHealth + right!.maxHealth,  mana: left!.mana+right!.mana, maxMana: left!.maxMana + right!.maxMana)
    }
    else if (left != nil) {
        return left!
    }
    else if (right != nil) {
        return right!
    }
    else {
        return Stats.nilStats
    }
}
//////////////////////


class Entity:SKSpriteNode {
    var stats:Stats
    
    let inventory:Inventory
    
    private var textures:[SKTexture] = [] //0 - north, 1 - east, 2 - south, 3 - west
    
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
    
    init(fromTexture: SKTexture, withStats:Stats, withInventory:Inventory)
    {
        inventory = withInventory
        fromTexture.filteringMode = .Nearest
        stats = withStats
        super.init(texture: fromTexture, color: UIColor.clearColor(), size: fromTexture.size())
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10.0) //TODO: fix this
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0
        
        self.zPosition = BaseLevel.LayerDef.Entity

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func struckByProjectile(p:Projectile) {
        fatalError("Must be overriden!")
    }
    
    private func setImageOrientation(toAngle:CGFloat) {
        let direction = Int((4 / 6.28) * toAngle)
        
        // change image direction
    }
    
    private func takeDamage(d:CGFloat) {
        stats.health -= d
        if (stats.health <= 0) {
            stats.health = 0
            die()
        }
    }
    
    func die() {
        
    }
    
}

//////////////////////

class ThisCharacter: Entity, Updatable {
    
    private var timeSinceProjectile:Double = 0
    var totalDamageInflicted:Int = 0
    //////////////
    //INIT
    init(withStats:Stats, withInventory:Inventory)
    {
        super.init(fromTexture: SKTextureAtlas(named: "chars").textureNamed("Character"), withStats: withStats, withInventory: withInventory)
        self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.ThisPlayer
        self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.Enemy | InGameScene.PhysicsCategory.EnemyProjectile | InGameScene.PhysicsCategory.Interactive
        self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        self.position = CGPoint(x: Int(screenSize.width/2), y: Int(screenSize.height/2))
        self.setScale(0.5)
    
    }
    
    convenience init() {
        self.init(withStats:Stats.nilStats, withInventory: Inventory(withSize: inventory_size))
        self.inventory.setItem(0, toItem: Item.initHandlerID("wep1")) //TODO: make these starting items
        self.inventory.setItem(1, toItem: Item.initHandlerID("wep2"))
        self.inventory.setItem(2, toItem: Item.initHandlerID("wep3"))
        
        stats.maxHealth = 20 + randomBetweenNumbers(0, secondNum: 10)
        stats.maxMana = 15 + randomBetweenNumbers(0, secondNum: 10)
        stats.health = stats.maxHealth
        stats.mana = stats.maxMana
        
        stats.defense = 15 + randomBetweenNumbers(0, secondNum: 10)
        stats.attack = 15 + randomBetweenNumbers(0, secondNum: 10)
        stats.dexterity = 15 + randomBetweenNumbers(0, secondNum: 10)
        stats.speed = 15 + randomBetweenNumbers(0, secondNum: 10)
        
        UIElements.HPBar.setProgress(Float(stats.health/stats.maxHealth), animated: true)
        
    }
    
    convenience init(fromSaveData:SaveData) {
        self.init(withStats: fromSaveData.stats, withInventory: fromSaveData.inventory)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///collision handling
    override func takeDamage(d: CGFloat) {
        super.takeDamage(d)
        UIElements.HPBar.setProgress(Float(stats.health/stats.maxHealth), animated: true) //div by zero error
    }
    
    override func struckByProjectile(p:Projectile) {
        takeDamage(p.attack - (stats.defense + inventory.stats.defense))
    }

    override func die() {
        //inventory.dropAllExceptInventory()
        //let rand = Int(randomBetweenNumbers(0, secondNum: CGFloat(inventory.baseSize)))
        //inventory.setItem(rand, toItem: nil)
        //save game
    }
    
    func killedEnemy(e:Enemy) {
        //gain exp
        //possibly increase level
        //add to kills
    }
    //ITEM HANDLER METHODS
    func consumeItem(c:Consumable) {
        stats = stats + c.statMods
        if (stats.health > stats.maxHealth) {
            stats.health = stats.maxHealth
        }
        if (stats.mana > stats.maxMana) {
            stats.mana = stats.maxMana
        }
    }

    func fireProjectile(withVelocity:CGVector) {
        if (weapon != nil) {
            let newProjectile = Projectile(withID: weapon!.projectile, fromPoint: position, withVelocity: withVelocity, isFriendly: true, withRange: weapon!.range, withAtk: stats.attack + inventory.stats.attack, reflects: weapon!.projectileReflects)
            (self.scene as! InGameScene).addObject(newProjectile)
        }
    }

    
    func update(deltaT:Double) { //as dex goes from 0-100, time between projectiles goes from 1000 to 20 ms
        if (UIElements.RightJoystick!.currentPoint != CGPointZero && timeSinceProjectile > 1000-9.8*Double(stats.dexterity+inventory.stats.dexterity) && weapon != nil) {
            fireProjectile(weapon!.projectileSpeed * UIElements.RightJoystick!.normalDisplacement)
            timeSinceProjectile = 0
        }
        else {
            timeSinceProjectile += deltaT
        }
        self.physicsBody?.velocity =  (stats.speed+inventory.stats.speed) * UIElements.LeftJoystick!.normalDisplacement
    }
}


class Enemy:Entity, Updatable{

    private var AI:EnemyAI?
    private var parentSpawner:Spawner?

    init(thisEnemy:AEXMLElement, atPosition:CGPoint, spawnedFrom:Spawner?) {
        super.init(fromTexture: SKTexture(imageNamed: thisEnemy["img"].stringValue), withStats: Stats.statsFrom(thisEnemy), withInventory: Inventory(fromElement: thisEnemy["inventory"]))
        name = thisEnemy["name"].stringValue
        AI = EnemyDictionary.EnemyDictionary[name!]!(parent: self)
        parentSpawner = spawnedFrom
        
        physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.FriendlyProjectile
        physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        position = atPosition
    }

    convenience init(withID:String, atPosition:CGPoint, spawnedFrom:Spawner?) {
        let thisEnemy = enemyXML.root["enemies"]["enemy"].allWithAttributes(["id":withID])!.first!
        self.init(thisEnemy: thisEnemy, atPosition: atPosition, spawnedFrom: spawnedFrom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fireProjectile(withVelocity:CGVector) {
        if (weapon != nil) {
            let newProjectile = Projectile(withID: weapon!.projectile, fromPoint: position, withVelocity: weapon!.projectileSpeed*withVelocity, isFriendly: false, withRange:weapon!.range, withAtk: stats.attack, reflects: weapon!.projectileReflects)
            //TODO: check if projectiles can be shot etc
            (self.scene as! InGameScene).addObject(newProjectile)
        }
    }
    
    func fireProjectileAngle(atAngle:CGFloat) {
        fireProjectile(CGVectorMake(cos(atAngle), sin(atAngle)))
    }
    
    override func struckByProjectile(p:Projectile) {
        takeDamage(p.attack - stats.defense)
    }
    
    func distanceToCharacter() -> CGFloat {
        return hypot(self.position.x - thisCharacter.position.x, self.position.y - thisCharacter.position.y)
    }
    
    func angleToCharacter() -> CGFloat {
        return atan2(thisCharacter.position.y - self.position.y, thisCharacter.position.x - self.position.x)
    }
    
    func normalVectorToCharacter() -> CGVector {
        let dist = distanceToCharacter()
        if (dist == 0) { return CGVector.zero }
        return CGVectorMake((self.position.x - thisCharacter.position.x)/dist, (self.position.y - thisCharacter.position.y)/dist)
    }
    
    func update(deltaT:Double) {
        AI?.update(deltaT)
    }
    
    override func die() {
        //do some kind of animation
        for item in inventory.dropAllItems() where item != nil {
                let newPoint = CGPointMake(randomBetweenNumbers(self.position.x-10, secondNum: self.position.x+10), randomBetweenNumbers(self.position.y-10, secondNum: self.position.y+10))
                (self.scene as! InGameScene).addObject(ItemBag(withItem: item!, loc: newPoint))
        } //drop inventory
        parentSpawner?.childDied()
        removeFromParent()
    }
    
}
