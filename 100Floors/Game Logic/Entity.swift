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
        default: fatalError()
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
        default: fatalError()
        }
    }
    
    func toArray() -> NSArray {
        return NSArray(array: [health,defense,attack,speed,dexterity,mana, maxHealth, maxMana])
    }
    
    func toSwiftArray() -> [CGFloat] {
        return [health,defense,attack,speed,dexterity,mana, maxHealth, maxMana]
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
    
    static func statsFrom(fromBase64:String) -> Stats {
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
    static let expForLevel:[Int] =  [0, 0, 250, 500, 1000, 1750, 2750, 4500, 6500, 8500, 10500, 14000, 18000, 23000, 29000, 36000] //TODO: balance this
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
    case Stuck = 2000, Confused = 3000, Weak = 5000, Poisoned = 10000, Blinded = 1500, Disturbed = 5001, Chilled = 5002, Cursed = 3001, Bleeding = 4000, Invincible = 5003, Burned = 8000
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
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSizeZero)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 6) //TODO: fix this
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.friction = 0
        self.physicsBody!.restitution = 0
        self.zPosition = MapLevel.LayerDef.Entity - 0.0001 * (self.position.y - self.frame.height/2)
        self.addChild(popups)
        popups.zPosition = 50
    }
    
    func setTextureDict(to:[String:[SKTexture]], beginTexture:String) {
        currentTextureSet = beginTexture
        textureDict = to
        self.texture = textureDict[beginTexture]![0]
        self.size = CGSize(width: self.texture!.size().width/2, height: self.texture!.size().height/2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func struckByProjectile(p:Projectile) {
        if (condition?.conditionType != .Invincible) {
            if (self.actionForKey("flash") == nil) {
                self.runAction(SKAction.sequence([SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1, duration: 0.125), SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1, duration: 0.125)]), withKey:"flash")
            }
            if let cond = p.statusCondition {
                if (randomBetweenNumbers(0, secondNum: 1) <= cond.probability) {
                    enableCondition(cond.condition, duration: cond.condition.rawValue)
                }
            }
            let damage = getDamage(p.attack)
            adjustHealth(-damage, withPopup: true)
        }}

    func adjustHealth(amount:CGFloat, withPopup:Bool) {
        if (amount == 0) {
            return
        }
        stats.health += amount
        if (withPopup) {
            if (amount < 0) {
                addPopup(UIColor.redColor(), text: "\(Int(amount))")
            }
            else {
                addPopup(UIColor.greenColor(), text: "+\(Int(amount))")
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
    
    func getDamage(attack: CGFloat) -> CGFloat {
        return max(5,randomBetweenNumbers(0.9, secondNum: 1.2)*(10*attack / (stats.defense*statusFactors.defMod))) * statusFactors.damageMod
    }
    
    func getStats() -> Stats {
        return self.stats
    }
    
    func die() {
        
    }
    /////////////////////
    func enableCondition(type:StatusCondition, duration:Double) { //TODO: finish status effects
        if (condition == nil) {
            removeAllPopups()
            condition = (type, type.rawValue)
            switch (type) {
            case .Stuck:
                addPopup(UIColor.yellowColor(), text: "STUCK")
                self.physicsBody?.velocity = CGVector.zero
                statusFactors.movementMod = 0
            case .Confused:
                addPopup(UIColor.greenColor(), text: "CONFUSED")
                statusFactors.movementMod = -1
            case .Weak:
                addPopup(UIColor.blueColor(), text: "WEAKENED")
                statusFactors.atkMod = 0.5
            case .Poisoned:
                addPopup(UIColor.purpleColor(), text: "POISONED")
                statusFactors.healthRegenMod = -10
                runEffect("Poison")
            case .Blinded:
                addPopup(UIColor.whiteColor(), text: "BLINDED") //probably unnecessary
            case .Disturbed:
                addPopup(UIColor.magentaColor(), text: "DISTURBED")
                statusFactors.manaRegenMod = -10
            case .Chilled:
                addPopup(UIColor.cyanColor(), text: "CHILLED")
                statusFactors.movementMod = 0.5
            case .Cursed:
                addPopup(UIColor.purpleColor(), text: "CURSED")
                runEffect("Dark")
            case .Bleeding:
                addPopup(UIColor.redColor(), text: "BLEEDING")
                statusFactors.atkMod = 0.5
                statusFactors.defMod = 0.5
                statusFactors.movementMod = 0.5
                statusFactors.dexMod = 0.5
                statusFactors.healthRegenMod = -5
                runEffect("BloodSplatterA")
            case .Invincible:
                statusFactors.damageMod = 0
                addPopup(UIColor.blueColor(), text: "INVINCIBLE")
                
            case .Burned:
                addPopup(UIColor.orangeColor(), text: "BURNED")
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
    
    func runEffect(name:String, completion:() -> () = {}) {
        if (effectNode?.parent != nil) {
            effectNode?.completion()
            effectNode?.removeFromParent()
        }
        effectNode = PixelEffect(name:name, completion: completion)
        effectNode!.setScale(0.5)
        switch (effectNode!.alignment) {
        case .Bottom:
        effectNode!.position.y = (effectNode!.size.height*effectNode!.xScale)-self.size.height/2
        default: break
        }
        self.addChild(effectNode!)
        effectNode!.runAnimation()
    }
    
    private func removeAllPopups() {
        popups.removeAllChildren()
    }
    
    private func addPopup(color:UIColor, text:String) {
        if (popups.children.count > 5){
            popups.children.first?.removeFromParent()
        }
        let newPopup = StatUpdatePopup(color: color, text: text, velocity: CGVectorMake(5, 5), zoomRate: 1.2)
        popups.addChild(newPopup)
    }
    
    func runAnimation(frameDuration:Double) {
        runAction(SKAction.animateWithTextures(textureDict[currentTextureSet]!, timePerFrame: frameDuration, resize: false, restore: false), withKey: "animation")
    }
    
    func isCurrentlyAnimating() -> Bool {
        return actionForKey("animation") != nil
    }
    
    func setCurrentTextures(to:String) {
        currentTextureSet = to
    }
    
    ////////////////
   
    
    func update(deltaT: Double) {
        if (condition != nil) {
            condition!.timeLeft -= deltaT
            if (condition!.timeLeft <= 0) {
                removeAllPopups()
                addPopup(UIColor.greenColor(), text: "STATUS CLEARED")
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
    //var totalDamageInflicted:Int = 0
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
                newTexture.filteringMode = .Nearest
                standingArr.append(newTexture)
            }
            dict["standing\(n)"] = standingArr
            var walkingArr:[SKTexture] = []
            for i in 5...6 {
                let newTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("Hero\(n)\(i)")
                newTexture.filteringMode = .Nearest
                walkingArr.append(newTexture)
            }
            dict["walking\(n)"] = walkingArr
        }
        super.setTextureDict(dict, beginTexture: "standing3")
        self.size = CGSizeMake(8, 8)
        SKTextureAtlas.preloadTextureAtlases([SKTextureAtlas(named: "Heal1")], withCompletionHandler: {})
        let shadowTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("Shadow")
        let shadow = SKSpriteNode(texture: shadowTexture)
        shadow.zPosition = -0.01
        shadow.setScale(0.5)
        shadow.position = CGPointMake(0,-2)
        self.addChild(shadow)
        //self.reset()
        inventory.setTextureDict()
        Projectile.shadowTexture = shadowTexture
    }
    
    convenience init(inventorySize:Int) {
        self.init(withStats:Stats.nilStats, withInventory: Inventory(withSize: inventorySize), withLevel: 1, withExp: 0)

        inventory.setItem(0, toItem: Item.initHandlerID("w9"))
        inventory.setItem(1, toItem: Item.initHandlerID("s7"))
        inventory.setItem(2, toItem: Item.initHandlerID("c11"))


     //   inventory.setItem(1, toItem: Scroll(fromBase64: "NSx0ZXN0c2tpbGwsdGVzdGRlc2Msbm9uZSwxMCwxMCwwLEVhcnRoQywwLjUsMjAwMCwwLjU="))
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
        static let levelKey = "level"
        static let inventoryKey = "inventory"
        static let expKey = "exp"
        static let statsKey = "stats"
    }
    required convenience init?(coder aDecoder: NSCoder) {
        var newStats = Stats.statsFrom(aDecoder.decodeObjectForKey(PropertyKey.statsKey) as! NSArray)
        newStats.health = newStats.maxHealth
        newStats.mana = newStats.maxMana
        let level = aDecoder.decodeObjectForKey(PropertyKey.levelKey) as! Int
        let exp = aDecoder.decodeObjectForKey(PropertyKey.expKey) as! Int
        let inv = aDecoder.decodeObjectForKey(PropertyKey.inventoryKey) as! Inventory
        self.init(withStats: newStats, withInventory: inv, withLevel: level, withExp: exp)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(inventory, forKey: PropertyKey.inventoryKey)
        aCoder.encodeObject(stats.toArray(), forKey: PropertyKey.statsKey)
        aCoder.encodeObject(expPoints, forKey: PropertyKey.expKey)
        aCoder.encodeObject(level, forKey: PropertyKey.levelKey)
    }
    
    override func adjustHealth(amount: CGFloat, withPopup: Bool) {
        super.adjustHealth(amount, withPopup: withPopup)
        var color:UIColor
        let progress = stats.health/stats.maxHealth
        if progress <= 0.2 {
            color = UIColor.redColor()
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
    func adjustMana(amount:CGFloat) {
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
        UIElements.SkillButton.setProgress(stats.mana/stats.maxMana)
    }
    
    override func getStats() -> Stats {
        return stats + inventory.stats
    }
  
    private func setHealth(to:CGFloat, withPopup:Bool) {
        let amount = to*(stats.maxHealth) - stats.health
        adjustHealth(amount, withPopup: withPopup)
    }
    
    override func getDamage(attack: CGFloat) -> CGFloat {
        return max(randomBetweenNumbers(1, secondNum: 4),randomBetweenNumbers(0.9, secondNum: 1.2)*(10 * attack / (stats.defense + inventory.stats.defense)*statusFactors.defMod)) * statusFactors.damageMod
    }

    override func die() {
        NSNotificationCenter.defaultCenter().postNotificationName("levelEndedDefeat", object: nil)
        self.scene?.paused = true
    }
    
    func reset() {
        stats.health = stats.maxHealth
        stats.mana = stats.maxMana
        condition = nil
        statusFactors = StatusFactors()
        pointers.removeAllChildren()
        removeAllPopups()
        removeAllActions()
        runAction(SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1, duration: 0))
        timeSinceProjectile = 0
        currentTextureSet = "standing3"
        UIElements.HPBar.setProgress(UIColor.greenColor(), progress: 1, animated: true)
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
    
    func killedEnemy(e:Enemy) {
        let newExp = e.stats.sumStats()
        expPoints += newExp
        addPopup(UIColor.greenColor(), text: "+\(newExp)EXP")
        if (level < StatLimits.MAX_LEVEL && expPoints >= StatLimits.expForLevel[level+1]) {
            level += 1
            removeAllPopups()
            addPopup(UIColor.greenColor(), text: "LEVEL UP: \(level)")
            runEffect("Heal1")
            for i in 0..<Stats.numStats {
                stats.setIndex(i, toVal: stats.getIndex(i) + randomBetweenNumbers(StatLimits.MIN_LVLUP_STAT_GAIN, secondNum: StatLimits.MAX_LVLUP_STAT_GAIN))
            }
            stats.health = stats.maxHealth
            stats.mana = stats.maxMana
            stats.capAt(StatLimits.BASE_STAT_MAX)
            UIElements.HPBar.setProgress(UIColor.greenColor(), progress: 1, animated: true)
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
    override func enableCondition(type: StatusCondition, duration: Double) {
        if (type != armor?.protectsAgainst) {
            super.enableCondition(type, duration: duration)
        }
    }
    
    func consumeItem(c:Consumable) {
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

    func fireProjectile(withVelocity:CGVector, withSpeed:CGFloat) {
        if (weapon != nil) {
            let projectiles = weapon!.getProjectile((stats.attack + inventory.stats.attack) * statusFactors.atkMod, fromPoint: position, withAngle: atan2(withVelocity.dy, withVelocity.dx), withSpeed: withSpeed, isFriendly: true)
            for projectile in projectiles {
                (self.scene as! InGameScene).addObject(projectile)
            }
            if (condition?.conditionType == .Cursed) {
                adjustHealth(-0.01*stats.maxHealth, withPopup: true)
            }
        }
    }
    
    @objc func useSkill(sender:UIButton) {
        if let skill = skill {
            if (stats.mana >= skill.mana && condition?.conditionType != .Disturbed) {
                skill.execute(self)
                adjustMana(-skill.mana)
                if (skill.mana > stats.mana) {
                    (sender as! ProgressRectButton).setEnabledTo(false)
                }
            }
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName("postInfoToDisplay", object: "Press Inventory to equip a skill!")
        }
    }

    private var didNotifyNilWeapon = false
    private var statRegenTimeElapsed:Double = 0
    private let statRegenInterval:Double = 1000
    
    override func update(deltaT:Double) {         super.update(deltaT)
        if (statRegenTimeElapsed >= statRegenInterval) {
            statRegenTimeElapsed = 0
            adjustHealth(0.005*stats.maxHealth*statusFactors.healthRegenMod, withPopup: false)
            adjustMana(0.01*stats.maxMana*statusFactors.manaRegenMod)
            if (skill != nil && skill!.mana <= stats.mana) { 
                UIElements.SkillButton.setEnabledTo(true)
            }
        }
        else {
            statRegenTimeElapsed += deltaT
        }
        var animationType:String
        if (UIElements.RightJoystick!.currentPoint != CGPointZero) {
            currentDirection = ((Int(UIElements.RightJoystick.getAngle() * 1.274 + 3.987) + 5) % 8)/2
            animationType = UIElements.LeftJoystick.currentPoint != CGPointZero ? "walking" : "standing"
            if (timeSinceProjectile > 500-0.4*Double((stats.dexterity+inventory.stats.dexterity)*statusFactors.dexMod) && weapon != nil) { //as dex goes from 0-1000, time between projectiles goes from 1000 to 100 ms
                fireProjectile(UIElements.RightJoystick!.normalDisplacement, withSpeed: (stats.dexterity+inventory.stats.dexterity)*statusFactors.dexMod/20 + 100)
                timeSinceProjectile = 0
            }
            else if (weapon == nil && !didNotifyNilWeapon) {
                NSNotificationCenter.defaultCenter().postNotificationName("postInfoToDisplay", object: "Press Inventory to equip a weapon!")
                didNotifyNilWeapon = true
            }
            else {
                timeSinceProjectile += deltaT
            }
        }
        else {
            didNotifyNilWeapon = false
            if (UIElements.LeftJoystick.currentPoint != CGPointZero) {
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
    let indicatorArrow = IndicatorArrow(color: UIColor.redColor(), radius: 20)
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
        
    func fireProjectile(texture:SKTexture, range:CGFloat, reflects:Bool = false, withVelocity:CGVector, status:(StatusCondition, CGFloat)? = nil) {
        let newProjectile = Projectile(fromTexture: texture, fromPoint: self.position, withVelocity: withVelocity, withAngle: atan2(withVelocity.dy, withVelocity.dx), isFriendly: false, withRange: range, withAtk: statusFactors.atkMod * stats.attack, reflects: reflects, statusInflicted: status)
        (self.scene as? InGameScene)?.addObject(newProjectile)
    }
    
    func getEnemiesWithID(id:String) -> [Enemy] {
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
        if (condition?.conditionType == .Blinded) {
            loc = CGPointMake(randomBetweenNumbers(position.x-20, secondNum: position.x+20), randomBetweenNumbers(position.y-20, secondNum: position.y+20))
        }
        else {
            loc = thisCharacter.position
        }
        return atan2(loc.y - self.position.y, loc.x - self.position.x)
    }
    
    func normalVectorToCharacter() -> CGVector {
        let dist = distanceToCharacter()
        if (dist == 0) { return CGVector.zero }
        return CGVectorMake((thisCharacter.position.x - self.position.x)/dist, (thisCharacter.position.y - self.position.y)/dist)
    }
    
    func isOnScreen() -> Bool {
        let ret = (self.scene as? InGameScene)?.currScreenBounds.contains(self.position)
        return (ret == nil ? false:ret!)
    }
    
    func struckMapBoundary(point:CGPoint) {
        AI?.struckMapBoundary(point)
    }
    
    func setVelocity(v:CGVector) { //v is unit vector
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
    
    override func update(deltaT:Double) {
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
            drop.position = CGPointMake(randomBetweenNumbers(self.position.x-10, secondNum: self.position.x+10), randomBetweenNumbers(self.position.y-10, secondNum: self.position.y+10))
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
    override func setVelocity(v:CGVector) { //v is unit vector
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
        return CGVectorMake(cos(angle), sin(angle))
    }
    
    override func isOnScreen() -> Bool {
        return screenSize.contains(self.position)
    }
    var elapsedSinceCheck:Double = 0
    override func update(deltaT: Double) {
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
    
    override func fireProjectile(texture: SKTexture, range: CGFloat, reflects: Bool, withVelocity: CGVector, status: (StatusCondition, CGFloat)?) {
        let newProjectile = Projectile(fromTexture: texture, fromPoint: self.position, withVelocity: withVelocity, withAngle: atan2(withVelocity.dy, withVelocity.dx), isFriendly: false, withRange: range, withAtk: statusFactors.atkMod * stats.attack, reflects: reflects, statusInflicted: status)
        parent?.addChild(newProjectile)
    }
    
    override func die() {
        removeFromParent()
        parentSpawner?.childDied()
    }
    
}
