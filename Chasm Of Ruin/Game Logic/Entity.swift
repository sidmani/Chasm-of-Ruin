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

    func getIndex(_ index:Int) -> CGFloat {
        switch (index) {
        case 0: return health
        case 1: return defense
        case 2: return attack
        case 3: return speed
        case 4: return dexterity
        case 5: return mana
        case 6: return maxHealth
        case 7: return maxMana
        default: fatalError()
        }
    }
    
    mutating func setIndex(_ index:Int, toVal:CGFloat) {
        switch (index) {
        case 0: health = toVal
        case 1: defense = toVal
        case 2: attack = toVal
        case 3: speed = toVal
        case 4: dexterity = toVal
        case 5: mana = toVal
        case 6: maxHealth = toVal
        case 7: maxMana = toVal
        default: fatalError()
        }
    }
    
    func toArray() -> NSArray {
        return NSArray(array: [health,defense,attack,speed,dexterity,mana, maxHealth, maxMana])
    }
    
    func toSwiftArray() -> [CGFloat] {
        return [health,defense,attack,speed,dexterity,mana, maxHealth, maxMana]
    }
    
    mutating func capAt(_ maxVal:CGFloat) {
        for i in 0..<Stats.numStats {
            setIndex(i, toVal: min(getIndex(i), maxVal))
        }
    }
    
    static func statsFrom(_ Array:NSArray) -> Stats {
        var out = nilStats
        for i in 0..<numStats {
            out.setIndex(i, toVal: Array[i] as! CGFloat)
        }
        return out
    }
    
    static func statsFrom(_ fromBase64:String) -> Stats {
        let optArr = fromBase64.splitBase64IntoArray("|")
        return Stats(
            defense: CGFloat(optArr[0]),
            attack: CGFloat(optArr[1]),
            speed: CGFloat(optArr[2]),
            dexterity: CGFloat(optArr[3]),
            health: CGFloat(optArr[4]),
            maxHealth: CGFloat(optArr[5]),
            mana: CGFloat(optArr[6]),
            maxMana: CGFloat(optArr[7])
        )
    }

    func sumStats() -> Int {
        return Int(defense + attack + speed + dexterity)
    }
    
    static let nilStats = Stats(defense: 0, attack: 0, speed: 0, dexterity: 0, health: 0, maxHealth: 0, mana: 0, maxMana: 0)
}

struct StatLimits {
    static let expForLevel:[Int] =  [0, 0, 500, 1000, 2500, 5000, 8000, 12000, 17000, 23000, 30000, 38000, 49000, 60000, 72000, 85000]
    static let MAX_LEVEL = 15
    
    static let MIN_LVLUP_STAT_GAIN:CGFloat = 10
    static let MAX_LVLUP_STAT_GAIN:CGFloat = 20

    static let GLOBAL_STAT_MAX:CGFloat = 1000
    static let GLOBAL_STAT_MIN:CGFloat = 20
    static let BASE_STAT_MAX:CGFloat = 500
    static let EQUIP_STAT_MAX:CGFloat = 400
    
    static let SINGLE_ITEM_STAT_MAX:CGFloat = 100
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
enum StatusCondition:Double {
    // Stuck - immobilized. x
    // Confused - actions reversed. x
    // Weak - atk halved. x
    // Poisoned - lose hp every second. x
    // Blinded - (player -> cannot see enemies) (enemy -> cannot see player location)
    // Disturbed - player-> cannot use skill enemy-> 1/2 attacks failx
    // Chilled - speed halved x
    // Cursed - attack causes recoil damage x
    // Bleeding - same as poisoned, but stats drop by half x
    // Invincible - cannot be affected by anything x
    // Burned - lose HP every second, dex dropped by half x
    case stuck = 2000, confused = 3000, weak = 5000, poisoned = 10000, blinded = 1500, disturbed = 5001, chilled = 5002, cursed = 3001, bleeding = 4000, invincible = 5003, burned = 8000
}

//////////////////////
class Entity:SKSpriteNode, Updatable {

    private var stats:Stats
    
    
    private var textureDict:[String:[SKTexture]] = [:]
    private var currentTextureSet = ""
    private var currentDirection:Int = 1 // 0-east, 1-south, 2-west, 3-north
    
    private struct StatusFactors {
        var movementMod:CGFloat = 1
        var atkMod:CGFloat = 1
        var defMod:CGFloat = 1
        var dexMod:CGFloat = 1
        var damageMod:CGFloat = 1
        var healthRegenMod:CGFloat = 1
        var manaRegenMod:CGFloat = 1
    }
    
    private var statusFactors = StatusFactors()
    private var popups = SKNode()
    
    var condition:(conditionType: StatusCondition, timeLeft: Double)?
    
    init(withStats:Stats)
    {
        stats = withStats
        super.init(texture: nil, color: UIColor.clear, size: CGSize.zero)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0
        self.zPosition = MapLevel.LayerDef.Entity - 0.0001 * (self.position.y - self.frame.height/2)
        self.addChild(popups)
        popups.zPosition = 50
    }
    
    func setTextureDict(_ to:[String:[SKTexture]], beginTexture:String) {
        currentTextureSet = beginTexture
        textureDict = to
        self.texture = textureDict[beginTexture]![0]
        self.size = CGSize(width: self.texture!.size().width/2, height: self.texture!.size().height/2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func struckByProjectile(_ p:Projectile) {
        if (condition?.conditionType != .invincible) {
            if (self.action(forKey: "flash") == nil) {
                self.run(SKAction.sequence([SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0.125), SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0.125)]), withKey:"flash")
            }
            if let cond = p.statusCondition {
                if (randomBetweenNumbers(0, secondNum: 1) <= cond.probability) {
                    enableCondition(cond.condition, duration: cond.condition.rawValue)
                }
            }
            let damage = getDamage(p.attack)
            adjustHealth(-damage, withPopup: true)
        }}

    func adjustHealth(_ amount:CGFloat, withPopup:Bool) {
        if (amount == 0) {
            return
        }
        stats.health += amount
        if (withPopup) {
            if (amount < 0) {
                addPopup(UIColor.red, text: "\(Int(amount))")
            }
            else {
                addPopup(UIColor.green, text: "+\(Int(amount))")
            }
        }
        if (stats.health <= 0) {
            stats.health = 0
            die()
        }
        else if (stats.health >= stats.maxHealth) {
            stats.health = stats.maxHealth
        }
    }
    
    func getDamage(_ attack: CGFloat) -> CGFloat {
        return max(5,randomBetweenNumbers(0.9, secondNum: 1.2)*(10*attack / (stats.defense*statusFactors.defMod))) * statusFactors.damageMod
    }
    
    func getStats() -> Stats {
        return self.stats
    }
    
    func die() {
        
    }
    /////////////////////
    func enableCondition(_ type:StatusCondition, duration:Double) { 
        if (condition == nil) {
            removeAllPopups()
            condition = (type, type.rawValue)
            switch (type) {
            case .stuck:
                addPopup(UIColor.yellow, text: "STUCK")
                self.physicsBody?.velocity = CGVector.zero
                statusFactors.movementMod = 0
            case .confused:
                addPopup(UIColor.green, text: "CONFUSED")
                statusFactors.movementMod = -1
            case .weak:
                addPopup(UIColor.blue, text: "WEAKENED")
                statusFactors.atkMod = 0.5
            case .poisoned:
                addPopup(UIColor.purple, text: "POISONED")
                statusFactors.healthRegenMod = -10
                runEffect("Poison")
            case .blinded:
                addPopup(UIColor.white, text: "BLINDED")
            case .disturbed:
                addPopup(UIColor.magenta, text: "DISTURBED")
                statusFactors.manaRegenMod = -10
            case .chilled:
                addPopup(UIColor.cyan, text: "CHILLED")
                statusFactors.movementMod = 0.5
            case .cursed:
                addPopup(UIColor.purple, text: "CURSED")
                runEffect("Dark")
            case .bleeding:
                addPopup(UIColor.red, text: "BLEEDING")
                statusFactors.atkMod = 0.5
                statusFactors.defMod = 0.5
                statusFactors.movementMod = 0.5
                statusFactors.dexMod = 0.5
                statusFactors.healthRegenMod = -5
                runEffect("BloodSplatterA")
            case .invincible:
                statusFactors.damageMod = 0
                addPopup(UIColor.blue, text: "INVINCIBLE")
                
            case .burned:
                addPopup(UIColor.orange, text: "BURNED")
                statusFactors.dexMod = 0.5
                statusFactors.healthRegenMod = -10
                statusFactors.manaRegenMod = 0
                runEffect("FlameAlt")
            }
        }
    }
   
    ////////////////
    ////ANIMATIONS
    
    private var effectNode:PixelEffect?
    
    func runEffect(_ name:String, completion:() -> () = {}) {
        if (effectNode?.parent != nil) {
            effectNode?.completion()
            effectNode?.removeFromParent()
        }
        effectNode = PixelEffect(name:name, completion: completion)
        effectNode!.setScale(0.5)
        switch (effectNode!.alignment) {
        case .bottom:
        effectNode!.position.y = (effectNode!.size.height*effectNode!.xScale)-self.size.height/2
        default: break
        }
        self.addChild(effectNode!)
        effectNode!.runAnimation()
    }
    
    private func removeAllPopups() {
        popups.removeAllChildren()
    }
    
    private func addPopup(_ color:UIColor, text:String) {
        if (popups.children.count > 5){
            popups.children.first?.removeFromParent()
        }
        let newPopup = StatUpdatePopup(color: color, text: text, velocity: CGVector(dx: 5, dy: 5), zoomRate: 1.2)
        popups.addChild(newPopup)
    }
    
    func runAnimation(_ frameDuration:Double) {
        run(SKAction.animate(with: textureDict[currentTextureSet]!, timePerFrame: frameDuration, resize: false, restore: false), withKey: "animation")
    }
    
    func isCurrentlyAnimating() -> Bool {
        return action(forKey: "animation") != nil
    }
    
    func setCurrentTextures(_ to:String) {
        currentTextureSet = to
    }
    
    ////////////////
   
    
    func update(_ deltaT: Double) {
        if (condition != nil) {
            condition!.timeLeft -= deltaT
            if (condition!.timeLeft <= 0) {
                removeAllPopups()
                addPopup(UIColor.green, text: "STATUS CLEARED")
                statusFactors = StatusFactors()
                condition = nil
            }
        }
        self.zPosition = MapLevel.LayerDef.Entity - 0.0001 * (self.position.y - self.frame.height/2)
    }
    
    
}

//////////////////////

class ThisCharacter: Entity {
    var level:Int
    var expPoints:Int
    
    let inventory:Inventory
    private var weapon:Weapon? {
        return inventory.getItem(inventory.weaponIndex) as? Weapon
    }
    private var skill:Skill? {
        return inventory.getItem(inventory.skillIndex) as? Skill
    }
    private var armor:Armor? {
        return inventory.getItem(inventory.armorIndex) as? Armor
    }
    private var enhancer:Enhancer? {
        return inventory.getItem(inventory.enhancerIndex) as? Enhancer
    }
    let pointers = SKNode()
    private var timeSinceProjectile:Double = 0
    //////////////
    //INIT
    init(withStats:Stats, withInventory:Inventory, withLevel:Int, withExp:Int)
    {
        level = withLevel
        expPoints = withExp
        inventory = withInventory
        super.init(withStats: withStats)
        self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.ThisPlayer
        self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.Enemy | InGameScene.PhysicsCategory.EnemyProjectile | InGameScene.PhysicsCategory.Interactive
        self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        self.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        self.addChild(pointers)
    }
    
    func setTextureDict() {
        var dict = [String:[SKTexture]]()
        for n in 0...3 {
            var standingArr:[SKTexture] = []
            for i in 0...4 {
                let newTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("Hero\(n)\(i)")
                newTexture.filteringMode = .nearest
                standingArr.append(newTexture)
            }
            dict["standing\(n)"] = standingArr
            var walkingArr:[SKTexture] = []
            for i in 5...6 {
                let newTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("Hero\(n)\(i)")
                newTexture.filteringMode = .nearest
                walkingArr.append(newTexture)
            }
            dict["walking\(n)"] = walkingArr
        }
        super.setTextureDict(dict, beginTexture: "standing3")
        self.size = CGSize(width: 8, height: 8)
        SKTextureAtlas.preloadTextureAtlases([SKTextureAtlas(named: "Heal1")], withCompletionHandler: {})
        let shadowTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("Shadow")
        let shadow = SKSpriteNode(texture: shadowTexture)
        shadow.zPosition = -0.01
        shadow.setScale(0.5)
        shadow.position = CGPoint(x: 0,y: -2)
        self.addChild(shadow)
        //self.reset()
        inventory.setTextureDict()
        Projectile.shadowTexture = shadowTexture
    }
    
    convenience init(inventorySize:Int) {
        self.init(withStats:Stats.nilStats, withInventory: Inventory(withSize: inventorySize), withLevel: 1, withExp: 0)

        inventory.setItem(0, toItem: Item.initHandlerID("w9"))
        inventory.setItem(1, toItem: Item.initHandlerID("s7"))
        inventory.setItem(2, toItem: Item.initHandlerID("sc1"))
        inventory.setItem(3, toItem: Item.initHandlerID("c11"))
        

        stats.maxHealth = StatLimits.GLOBAL_STAT_MIN + randomBetweenNumbers(0, secondNum: 10)
        stats.maxMana = StatLimits.GLOBAL_STAT_MIN + randomBetweenNumbers(0, secondNum: 10)
        stats.health = stats.maxHealth
        stats.mana = stats.maxMana
        
        stats.defense = StatLimits.GLOBAL_STAT_MIN + randomBetweenNumbers(0, secondNum: 10)
        stats.attack = StatLimits.GLOBAL_STAT_MIN + randomBetweenNumbers(0, secondNum: 10)
        stats.dexterity = StatLimits.GLOBAL_STAT_MIN + randomBetweenNumbers(0, secondNum: 10)
        stats.speed = StatLimits.GLOBAL_STAT_MIN + randomBetweenNumbers(0, secondNum: 10)
    }
    
    /////////NSCoding
    private struct PropertyKey {
        static let levelKey = "kLevel"
        static let inventoryKey = "inventory"
        static let expKey = "exp"
        static let statsKey = "stats"
    }
    required convenience init?(coder aDecoder: NSCoder) {
        var newStats = Stats.statsFrom(aDecoder.decodeObject(forKey: PropertyKey.statsKey) as! NSArray)
        newStats.health = newStats.maxHealth
        newStats.mana = newStats.maxMana
        let level = aDecoder.decodeInteger(forKey: PropertyKey.levelKey)
        let exp = aDecoder.decodeInteger(forKey: PropertyKey.expKey)
        let inv = aDecoder.decodeObject(forKey: PropertyKey.inventoryKey) as! Inventory
        self.init(withStats: newStats, withInventory: inv, withLevel: level, withExp: exp)
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(inventory, forKey: PropertyKey.inventoryKey)
        aCoder.encode(stats.toArray(), forKey: PropertyKey.statsKey)
        aCoder.encode(expPoints, forKey: PropertyKey.expKey)
        aCoder.encode(level, forKey: PropertyKey.levelKey)
    }
    
    override func adjustHealth(_ amount: CGFloat, withPopup: Bool) {
        super.adjustHealth(amount, withPopup: withPopup)
        var color:UIColor
        let progress = stats.health/stats.maxHealth
        if progress <= 0.2 {
            color = UIColor.red
        }
        else if progress < 0.7 {
            color = UIColor(red: 255, green: (progress-0.2)/0.3, blue: 0, alpha: 1.0)
        }
        else {
            color = UIColor(red: 2-2*progress, green: 255, blue: 0, alpha: 1.0)
        }
        UIElements.HPBar.setProgress(color, progress: progress, animated: true)
        UIElements.HPBar.label.text = "\(Int(max(stats.health,1)))/\(Int(stats.maxHealth))"
    }
    //////
    func adjustMana(_ amount:CGFloat) {
        if (amount == 0) {
            return
        }
        stats.mana += amount
        if (stats.mana < 0) {
            stats.mana = 0
        }
        else if (stats.mana > stats.maxMana) {
            stats.mana = stats.maxMana
        }
        UIElements.SkillButton.setProgress(stats.mana/stats.maxMana, animated: true)
    }
    
    override func getStats() -> Stats {
        return stats + inventory.stats
    }
  
    private func setHealth(_ to:CGFloat, withPopup:Bool) {
        let amount = to*(stats.maxHealth) - stats.health
        adjustHealth(amount, withPopup: withPopup)
    }
    
    override func getDamage(_ attack: CGFloat) -> CGFloat {
        return max(randomBetweenNumbers(1, secondNum: 4),randomBetweenNumbers(0.9, secondNum: 1.2)*(10 * attack / (stats.defense + inventory.stats.defense)*statusFactors.defMod)) * statusFactors.damageMod
    }

    override func die() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "levelEndedDefeat"), object: nil)
        self.scene?.isPaused = true
    }
    
    func reset() {
        stats.health = stats.maxHealth
        stats.mana = stats.maxMana
        condition = nil
        statusFactors = StatusFactors()
        pointers.removeAllChildren()
        removeAllPopups()
        removeAllActions()
        run(SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0))
        timeSinceProjectile = 0
        currentTextureSet = "standing3"
        UIElements.HPBar.setProgress(UIColor.green, progress: 1, animated: true)
        UIElements.HPBar.label.text = "\(Int(max(stats.health,1)))/\(Int(stats.maxHealth))"
        if (level < StatLimits.MAX_LEVEL) {
            UIElements.EXPBar.setProgress(Float(expPoints - StatLimits.expForLevel[level])/Float(StatLimits.expForLevel[level+1] - StatLimits.expForLevel[level]), animated: true)
        }
        else {
            UIElements.EXPBar.setProgress(1, animated: false)
        }
    }

    func confirmDeath() {
        //delete random items
        for i in 0..<inventory.baseSize {
            if (randomBetweenNumbers(0, secondNum: 1) < 0.2) {
                inventory.setItem(i, toItem: nil)
            }
        }
    }
    
    func killedEnemy(_ e:Enemy) {
        let newExp = e.stats.sumStats()
        expPoints += newExp
        addPopup(UIColor.green, text: "+\(newExp)EXP")
        if (level < StatLimits.MAX_LEVEL && expPoints >= StatLimits.expForLevel[level+1]) {
            level += 1
            removeAllPopups()
            addPopup(UIColor.green, text: "LEVEL UP: \(level)")
            runEffect("Heal1")
            for i in 0..<Stats.numStats {
                stats.setIndex(i, toVal: stats.getIndex(i) + randomBetweenNumbers(StatLimits.MIN_LVLUP_STAT_GAIN, secondNum: StatLimits.MAX_LVLUP_STAT_GAIN))
            }
            stats.health = stats.maxHealth
            stats.mana = stats.maxMana
            stats.capAt(StatLimits.BASE_STAT_MAX)
            UIElements.HPBar.setProgress(UIColor.green, progress: 1, animated: true)
            UIElements.HPBar.label.text = "\(Int(max(stats.health,1)))/\(Int(stats.maxHealth))"
            UIElements.EXPBar.setProgress(0, animated: false)
        }
        if (level < StatLimits.MAX_LEVEL) {
            UIElements.EXPBar.setProgress(Float(expPoints - StatLimits.expForLevel[level])/Float(StatLimits.expForLevel[level+1] - StatLimits.expForLevel[level]), animated: true)
        }
        else {
            UIElements.EXPBar.setProgress(1, animated: false)
        }
        //add to kills
    }
    override func enableCondition(_ type: StatusCondition, duration: Double) {
        if (type != armor?.protectsAgainst) {
            super.enableCondition(type, duration: duration)
        }
    }
    
    func consumeItem(_ c:Consumable) {
        stats = stats + c.statMods
        stats.capAt(StatLimits.BASE_STAT_MAX)
        adjustHealth(0, withPopup: false)
        if (stats.health > stats.maxHealth) {
            stats.health = stats.maxHealth
        }
        if (stats.mana > stats.maxMana) {
            stats.mana = stats.maxMana
        }
    }

    func fireProjectile(_ withVelocity:CGVector, withSpeed:CGFloat) {
        if (weapon != nil) {
            var velocity:CGVector
            if (condition?.conditionType == .confused) {
                velocity = -1 * withVelocity
            }
            else {
                velocity = withVelocity
            }
            let projectiles = weapon!.getProjectile((stats.attack + inventory.stats.attack) * statusFactors.atkMod, fromPoint: position, withAngle: atan2(velocity.dy, velocity.dx), withSpeed: withSpeed, isFriendly: true)
            for projectile in projectiles {
                (self.scene as! InGameScene).addObject(projectile)
            }
            if (condition?.conditionType == .cursed) {
                adjustHealth(-0.01*stats.maxHealth, withPopup: true)
            }
        }
    }
    
    @objc func useSkill(_ sender:UIButton) {
        if let skill = skill {
            if (stats.mana >= skill.mana && condition?.conditionType != .disturbed) {
                if (skill.execute(self)) {
                    adjustMana(-skill.mana)
                    if (skill.mana > stats.mana) {
                        (sender as! ProgressRectButton).setEnabledTo(false)
                    }
                }
            }
        }
        else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "postInfoToDisplay"), object: "Press Inventory to equip a skill!")
        }
    }

    private var didNotifyNilWeapon = false
    private var statRegenTimeElapsed:Double = 0
    private let statRegenInterval:Double = 1000
    
    override func update(_ deltaT:Double) {
        super.update(deltaT)
        if (statRegenTimeElapsed >= statRegenInterval) {
            statRegenTimeElapsed = 0
            adjustHealth(0.01*stats.maxHealth*statusFactors.healthRegenMod, withPopup: false)
            adjustMana(0.02*stats.maxMana*statusFactors.manaRegenMod)
            if (skill != nil && skill!.mana <= stats.mana) {
                UIElements.SkillButton.setEnabledTo(true)
            }
        }
        else {
            statRegenTimeElapsed += deltaT
        }
        var animationType:String
        if (UIElements.RightJoystick!.currentPoint != CGPoint.zero) {
            currentDirection = ((Int(UIElements.RightJoystick.getAngle() * 1.274 + 3.987) + 5) % 8)/2
            animationType = UIElements.LeftJoystick.currentPoint != CGPoint.zero ? "walking" : "standing"
            if (timeSinceProjectile > 500-0.4*Double((stats.dexterity+inventory.stats.dexterity)*statusFactors.dexMod) && weapon != nil) { //as dex goes from 0-1000, time between projectiles goes from 1000 to 100 ms
                fireProjectile(UIElements.RightJoystick!.normalDisplacement, withSpeed: (stats.dexterity+inventory.stats.dexterity)*statusFactors.dexMod/20 + 100)
                timeSinceProjectile = 0
            }
            else if (weapon == nil && !didNotifyNilWeapon) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "postInfoToDisplay"), object: "Press Inventory to equip a weapon!")
                didNotifyNilWeapon = true
            }
            else {
                timeSinceProjectile += deltaT
            }
        }
        else {
            didNotifyNilWeapon = false
            if (UIElements.LeftJoystick.currentPoint != CGPoint.zero) {
                currentDirection = ((Int(UIElements.LeftJoystick.getAngle() * 1.274 + 3.987) + 5) % 8)/2
                animationType = "walking"
            }
            else {
                animationType = "standing"
            }
        }
        
        self.physicsBody?.velocity = (0.03 * (stats.speed+inventory.stats.speed) + 30) * statusFactors.movementMod * UIElements.LeftJoystick!.normalDisplacement
        
        if (!isCurrentlyAnimating() || (currentTextureSet != "\(animationType)\(currentDirection)")) {
            setCurrentTextures("\(animationType)\(currentDirection)")
            runAnimation(0.25)
        }
    }
}


class Enemy:Entity {

    private var AI:EnemyAI?
    struct Drop {
        let type:String
        let chance:CGFloat
        let data:String
    }
    weak var wave:Wave?
    
    private var drops:[MapObject]
    let indicatorArrow = IndicatorArrow(color: UIColor.red, radius: 20)
    private let textureFlip:Bool
    private let initialTextureOrientation:CGFloat
    
    init(name:String, textureDict:[String:[SKTexture]], beginTexture:String, drops:[MapObject], stats:Stats, atPosition:CGPoint, textureFlipEnabled:Bool = true, initialTextureOrientation:CGFloat = 1, wave:Wave? = nil) {
        self.textureFlip = textureFlipEnabled
        self.initialTextureOrientation = initialTextureOrientation
        self.drops = drops
        self.wave = wave
        super.init(withStats: stats)
        setTextureDict(textureDict, beginTexture: beginTexture)
        self.name = name
        AI = EnemyDictionary.Dict[name]!(parent: self)
        physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.FriendlyProjectile | InGameScene.PhysicsCategory.MapBoundary
        physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        position = atPosition
        self.runEffect("TeleportC")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func fireProjectile(_ texture:SKTexture, range:CGFloat, reflects:Bool = false, withVelocity:CGVector, status:(StatusCondition, CGFloat)? = nil) {
        var velocity:CGVector
        if (condition?.conditionType == .confused) {
            velocity = -1 * withVelocity
        }
        else {
            velocity = withVelocity
        }
        let newProjectile = Projectile(fromTexture: texture, fromPoint: self.position, withVelocity: velocity, withAngle: atan2(velocity.dy, velocity.dx), isFriendly: false, withRange: range, withAtk: statusFactors.atkMod * stats.attack, reflects: reflects, statusInflicted: status)
        (self.scene as? InGameScene)?.addObject(newProjectile)
        if (condition?.conditionType == .cursed && randomBetweenNumbers(0, secondNum: 1) < 0.02) {
            adjustHealth(-0.01*stats.maxHealth, withPopup: true)
        }
    }
    
    func getEnemiesWithID(_ id:String) -> [Enemy] {
        var ret:[Enemy] = []
        for enemy in (self.scene as! InGameScene).enemiesOnScreen() where enemy.name == id {
            ret.append(enemy)
        }
        return ret
    }
    
    func distanceToCharacter() -> CGFloat {
        return hypot(self.position.x - thisCharacter.position.x, self.position.y - thisCharacter.position.y)
    }
    
    func angleToCharacter() -> CGFloat {
        var loc:CGPoint
        if (condition?.conditionType == .blinded) {
            loc = CGPoint(x: randomBetweenNumbers(position.x-20, secondNum: position.x+20), y: randomBetweenNumbers(position.y-20, secondNum: position.y+20))
        }
        else {
            loc = thisCharacter.position
        }
        return atan2(loc.y - self.position.y, loc.x - self.position.x)
    }
    
    func normalVectorToCharacter() -> CGVector {
        let dist = distanceToCharacter()
        if (dist == 0) { return CGVector.zero }
        if (condition?.conditionType == .blinded) {
            let angle = randomBetweenNumbers(0, secondNum: 6.27)
            return CGVector(dx: cos(angle), dy: sin(angle))
        }
        return CGVector(dx: (thisCharacter.position.x - self.position.x)/dist, dy: (thisCharacter.position.y - self.position.y)/dist)
    }
    
    func isOnScreen() -> Bool {
        let ret = (self.scene as? InGameScene)?.currScreenBounds.contains(self.position)
        return (ret == nil ? false:ret!)
    }
    
    func struckMapBoundary(_ point:CGPoint) {
        AI?.struckMapBoundary(point)
    }
    
    func setVelocity(_ v:CGVector) { //v is unit vector
        physicsBody?.velocity = (0.03 * (stats.speed) + 30) * statusFactors.movementMod * v
        if (textureFlip) {
            if (physicsBody!.velocity.dx < 0) {
                self.xScale = abs(self.xScale) * initialTextureOrientation
            }
            else {
                self.xScale = abs(self.xScale) * -initialTextureOrientation
            }
            if (self.xScale < 0) {
                popups.xScale = -abs(popups.xScale)
            }
            else {
                popups.xScale = abs(popups.xScale)
            }
        }
    }
    
    let statusHarmInterval:Double = 2000
    var currentStatusElapsed:Double = 0
    
    override func update(_ deltaT:Double) {
        super.update(deltaT)
        AI?.update(deltaT)
        if (condition != nil && currentStatusElapsed > statusHarmInterval) {
            currentStatusElapsed = 0
            if (statusFactors.healthRegenMod < 0) {
                adjustHealth(statusFactors.healthRegenMod*0.005*stats.maxHealth, withPopup: true)
            }
        }
        else if (condition != nil) {
            currentStatusElapsed += deltaT
        }
        
        if (thisCharacter.condition?.conditionType == .blinded) {
            self.alpha = 0
        }
        else {
            self.alpha = 1
        }
        
        if (!isOnScreen()) {
            if (indicatorArrow.parent == nil) {
                thisCharacter.pointers.addChild(indicatorArrow)
            }
            indicatorArrow.setRotation(angleToCharacter())
        }
        else {
            indicatorArrow.removeFromParent()
        }
    }

    override func die() {
        thisCharacter.killedEnemy(self)
        for drop in self.drops {
            drop.position = CGPoint(x: randomBetweenNumbers(self.position.x-10, secondNum: self.position.x+10), y: randomBetweenNumbers(self.position.y-10, secondNum: self.position.y+10))
            drop.updateZPosition()
            (self.scene as? InGameScene)?.addObject(drop)
        }
        wave?.enemyDied(self)
        removeFromParent()
        indicatorArrow.removeFromParent()
    }
}

class DisplayEnemy:Enemy {
    var parentSpawner:DisplaySpawner? = nil
    override func setVelocity(_ v:CGVector) { //v is unit vector
        physicsBody?.velocity = 30 * v
        if (textureFlip) {
            if (physicsBody!.velocity.dx < 0) {
                self.xScale = abs(self.xScale) * initialTextureOrientation
            }
            else {
                self.xScale = abs(self.xScale) * -initialTextureOrientation
            }
        }
    }

    override func distanceToCharacter() -> CGFloat {
        return randomBetweenNumbers(1, secondNum: 100)
    }
    
    override func angleToCharacter() -> CGFloat {
        return randomBetweenNumbers(0, secondNum: 6.28)
    }
    
    override func normalVectorToCharacter() -> CGVector {
        let angle = angleToCharacter()
        return CGVector(dx: cos(angle), dy: sin(angle))
    }
    
    override func isOnScreen() -> Bool {
        return screenSize.contains(self.position)
    }
    var elapsedSinceCheck:Double = 0
    override func update(_ deltaT: Double) {
        AI?.update(deltaT)
        if (elapsedSinceCheck > 1000) {
            if (!isOnScreen()) {
                die()
            }
            elapsedSinceCheck = 0
        }
        else {
            elapsedSinceCheck += deltaT
        }
        self.zPosition = MapLevel.LayerDef.Entity - 0.0001 * (self.position.y - self.frame.height/2)
    }
    
    override func fireProjectile(_ texture: SKTexture, range: CGFloat, reflects: Bool, withVelocity: CGVector, status: (StatusCondition, CGFloat)?) {
        let newProjectile = Projectile(fromTexture: texture, fromPoint: self.position, withVelocity: withVelocity, withAngle: atan2(withVelocity.dy, withVelocity.dx), isFriendly: false, withRange: range, withAtk: statusFactors.atkMod * stats.attack, reflects: reflects, statusInflicted: status)
        parent?.addChild(newProjectile)
    }
    
    override func die() {
        removeFromParent()
        parentSpawner?.childDied()
    }
    
}
