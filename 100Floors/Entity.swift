//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//
import SpriteKit

struct Stats {
    static let numStats = 7
    
    var health:CGFloat    // Health
    var defense:CGFloat   // Defense (% projectile is weakened by)
    var attack:CGFloat    // Attack (% own projectile is strengthened by)
    var speed:CGFloat     // Speed
    var dexterity:CGFloat // Dexterity (rate of projectile release)
    var mana:CGFloat      // Mana (used when casting spells)
    var rage:CGFloat      // Boosts with combos
    
    func getIndex(index:Int) -> CGFloat {
        switch (index) {
        case 0: return health
        case 1: return defense
        case 2: return attack
        case 3: return speed
        case 4: return dexterity
        case 5: return mana
        case 6: return rage
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
        case 6: rage = toVal
        default: break
        }
    }
    
    func toArray() -> NSArray {
        return NSArray(array: [health,defense,attack,speed,dexterity,mana,rage])
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
            health: CGFloat(Element["stats"]["health"].doubleValue),
            defense: CGFloat(Element["stats"]["def"].doubleValue),
            attack: CGFloat(Element["stats"]["atk"].doubleValue),
            speed: CGFloat(Element["stats"]["spd"].doubleValue),
            dexterity: CGFloat(Element["stats"]["dex"].doubleValue),
            mana: CGFloat(Element["stats"]["mana"].doubleValue),
            rage: CGFloat(Element["stats"]["rage"].doubleValue))
    }
    
    static let nilStats = Stats(health: 0, defense: 0, attack: 0, speed: 0, dexterity: 0, mana: 0, rage: 0)
}

func +(left:Stats?, right:Stats?) -> Stats{
    if (left != nil && right != nil) {
        return Stats(health: left!.health + right!.health,  defense: left!.defense + right!.defense, attack: left!.attack + right!.attack, speed: left!.speed+right!.speed, dexterity: left!.dexterity + right!.dexterity, mana: left!.mana+right!.mana, rage: left!.rage + right!.rage)
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
    var currStats:Stats
    var baseStats:Stats
    
    var equipStats:Stats = Stats.nilStats
    
    let inventory:Inventory
    
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
        fromTexture.filteringMode = .Nearest
        super.init(texture: fromTexture, color: UIColor.clearColor(), size: fromTexture.size())
        
        inventory.setParent(self)
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
        currStats.health -= d
        if (currStats.health <= 0) {
            currStats.health = 0
            die()
        }
    }
    
    func die() {
        
    }
    
    func updateEquipStats() {
        equipStats = weapon?.statMods + shield?.statMods + skill?.statMods + enhancer?.statMods
    }
    
}

//////////////////////

class ThisCharacter: Entity, Updatable {
    
    private var timeSinceProjectile:Double = 0
    var totalDamageInflicted:Int = 0
    //////////////
    //INIT
    init(withCurrStats:Stats, withBaseStats:Stats, withInventory:Inventory)
    {
        super.init(fromTexture: SKTextureAtlas(named: "chars").textureNamed("character"), withCurrStats: withCurrStats, withBaseStats: withBaseStats, withInventory: withInventory)
        self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.ThisPlayer
        self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.Enemy | InGameScene.PhysicsCategory.EnemyProjectile | InGameScene.PhysicsCategory.Interactive
        self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        self.position = screenCenter
        self.setScale(0.5)
    
    }
    
    convenience init() { //probably delete this
        self.init(withCurrStats:Stats.nilStats, withBaseStats: Stats.nilStats, withInventory: Inventory(withSize: inventory_size))
        self.inventory.setItem(0, toItem: Item.initHandlerID("wep1"))
        self.inventory.setItem(1, toItem: Item.initHandlerID("wep2"))
        self.inventory.setItem(2, toItem: Item.initHandlerID("wep3"))
        
    }
    
    convenience init(fromSaveData:SaveData) {
        self.init(withCurrStats:fromSaveData.currStats, withBaseStats: fromSaveData.baseStats, withInventory: fromSaveData.inventory)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///collision handling
    override func takeDamage(d: CGFloat) {
        super.takeDamage(d)
       // UIElements.HPBar.setProgressWithBounce(currStats.health/baseStats.health) //div by zero error
    }
    
    override func struckByProjectile(p:Projectile) {
        takeDamage(p.attack - currStats.defense)
    }

    override func die() {
        GameLogic.characterDeath()
        //inventory.dropAllExceptInventory()
        //let rand = Int(randomBetweenNumbers(0, secondNum: CGFloat(inventory.baseSize)))
        //inventory.setItem(rand, toItem: nil)
        //save game
    }
    
    //ITEM HANDLER METHODS
    func consumeItem(c:Consumable) {
        if (c.permanent) {
            baseStats = baseStats + c.statMods
        }
        else {
            currStats = currStats + c.statMods
        }
    }

    func fireProjectile(withVelocity:CGVector) {
        if (weapon != nil) {
            let newProjectile = Projectile(withID: weapon!.projectile, fromPoint: position, withVelocity: withVelocity, isFriendly: true, withRange: weapon!.range, withAtk: currStats.attack + equipStats.attack, reflects: weapon!.projectileReflects)
            GameLogic.addObject(newProjectile)
        }
    }

    
    func update(deltaT:Double) { //as dex goes from 0-100, time between projectiles goes from 1000 to 20 ms
        if (UIElements.RightJoystick!.currentPoint != CGPointZero && timeSinceProjectile > 1000-9.8*Double(currStats.dexterity+equipStats.dexterity) && weapon != nil) {
            fireProjectile(weapon!.projectileSpeed * UIElements.RightJoystick!.normalDisplacement)
            timeSinceProjectile = 0
         //   let rand = randomBetweenNumbers(0, secondNum: 1.0)
         //   UIElements.HPBar.setProgressWithBounce(rand)
        }
        else {
            timeSinceProjectile += deltaT
        }
        self.physicsBody?.velocity = 0.3*(currStats.speed + equipStats.speed + 100) * UIElements.LeftJoystick!.normalDisplacement
    }
}


class Enemy:Entity, Updatable{

    private var AI:EnemyAI?
    
    init(thisEnemy:AEXMLElement, atPosition:CGPoint) {
        let _baseStats = Stats.statsFrom(thisEnemy)
        super.init(fromTexture: SKTexture(imageNamed: thisEnemy["img"].stringValue), withCurrStats: _baseStats, withBaseStats: _baseStats, withInventory: Inventory(fromElement: thisEnemy["inventory"]))
        AI = EnemyAI(parent: self, withBehaviors: thisEnemy["behaviors"]["behavior"].all!)

        physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.FriendlyProjectile
        physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        position = atPosition
    }
    

    convenience init(withID:String, atPosition:CGPoint) {
        var thisEnemy:AEXMLElement
        if let enemies = enemyXML.root["enemies"]["enemy"].allWithAttributes(["id":withID]) {
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
        for item in inventory.dropAllItems() {
            if (item != nil) {
                let newPoint = CGPointMake(randomBetweenNumbers(self.position.x-20, secondNum: self.position.x+20), randomBetweenNumbers(self.position.y-20, secondNum: self.position.y+20))
                GameLogic.addObject(ItemBag(withItem: item!, loc: newPoint))
            }
        } //drop inventory
        removeFromParent()
    }
    
}
