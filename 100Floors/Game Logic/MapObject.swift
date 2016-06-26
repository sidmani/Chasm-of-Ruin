//
//  MapObject.swift
//  100Floors
//
//  Created by Sid Mani on 2/13/16.
//
//
import UIKit
import SpriteKit

protocol Interactive {
    var thumbnailImg:String { get }
    var autotrigger:Bool { get }
    func trigger()
    func displayPopup(state:Bool)
}

extension String {
    func base64Encoded() -> String {
        let plainData = dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return base64String!
    }
    
    func base64Decoded() -> String {
        let decodedData = NSData(base64EncodedString: self, options:NSDataBase64DecodingOptions(rawValue: 0))
        return NSString(data: decodedData!, encoding: NSUTF8StringEncoding)! as String
    }
    
    func splitBase64IntoArray() -> [String] {
        return self.base64Decoded().componentsSeparatedByString(",")
    }
}

class MapObject:SKNode {
    static func initHandler(type:String, fromBase64:String, loc:CGPoint) -> MapObject {
        switch (type) {
        case "Portal":
           return Portal(fromBase64: fromBase64, loc: loc)
        case "ItemBag":
            return ItemBag(withItem: Item.initHandlerID(fromBase64), loc: loc)
        case "ConstantRateSpawner":
            return ConstantRateSpawner(fromBase64: fromBase64, loc: loc)
        case "FixedNumSpawner":
            return FixedNumSpawner(fromBase64: fromBase64, loc: loc)
        case "OneTimeSpawner":
            return OneTimeSpawner(fromBase64: fromBase64, loc: loc)
        case "UsableItemResponder":
            return UsableItemResponder(loc: loc, eventKey: fromBase64)
        case "InfoDisplay":
            return InfoDisplay(fromBase64: fromBase64, loc: loc)
        default:
            fatalError()
        }
    }
    
    init(loc:CGPoint) {
        super.init()
        self.position = loc
        self.zPosition = BaseLevel.LayerDef.MapObjects - 0.0001 * (self.position.y - self.frame.height/2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Spawner:MapObject, Updatable {
    private var playerIsWithinRadius:Bool = false
    ///enemy data
    private let enemyID:String
    private var enemyTextureDict:[String:[SKTexture]] = [:]
    private var drops:[Enemy.Drop] = []
    private let stats:Stats
    private var beginTexture:String = ""
    
    init(loc: CGPoint, withEnemyID:String, threshold:CGFloat) {
        let thisEnemy = enemyXML.root["enemy"].allWithAttributes(["id":withEnemyID])!.first!

        enemyID = withEnemyID
        stats = Stats.statsFrom(thisEnemy)
        // initialize textures/animations
        if let animations = thisEnemy["animation"].all {
            for animation in animations {
                var textArr:[SKTexture] = []
                let frames = Int(animation.attributes["frames"]!)!
                for i in 0..<frames {
                    let newTexture = SKTextureAtlas(named: "Entities").textureNamed("\(animation.stringValue)\(i)")
                    newTexture.filteringMode = .Nearest
                    textArr.append(newTexture)
                }
                enemyTextureDict[animation.attributes["name"]!] = textArr
                if (beginTexture == "") {
                    beginTexture = animation.attributes["name"]!
                }
            }
        }
        // initalize drops
        if let enemyDrops =  thisEnemy["drop"].all {
            for drop in enemyDrops {
                drops.append(Enemy.Drop(type: drop.attributes["type"]!, chance: CGFloat(s: drop.attributes["chance"]!), data: drop.stringValue))
            }
        }
        
        super.init(loc: loc)

        physicsBody = SKPhysicsBody(circleOfRadius: threshold)
        physicsBody!.pinned = true
        physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Spawner
        physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.ThisPlayer
        physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaT: Double) {
        //nothing here
    }
    
    func childDied() {
        //nothing here either
    }
    
    func playerIsInRadius(val:Bool) {
        playerIsWithinRadius = val
    }
}

class ConstantRateSpawner:Spawner {
    private let rateOfSpawning:Double
    private var elapsedTime:Double = 0
    
    init(loc:CGPoint, withEnemyID:String, threshold:CGFloat, rate:Double) {
        rateOfSpawning = rate
        super.init(loc: loc, withEnemyID:withEnemyID, threshold:threshold)
    }
    convenience init(fromBase64:String, loc:CGPoint) {
        // "enemyID, threshold, rate"
        let optArr = fromBase64.splitBase64IntoArray()
        if (optArr.count != 3) {
            fatalError()
        }
        let enemyID = optArr[0]
        let threshold = CGFloat(s:optArr[1])
        let rate = Double(optArr[2])!
        self.init(loc:loc, withEnemyID: enemyID, threshold: threshold, rate: rate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaT:Double) {
        if (elapsedTime > rateOfSpawning && playerIsWithinRadius) {
            elapsedTime = 0
            let newEnemy = Enemy(name: enemyID, textureDict: enemyTextureDict, beginTexture: beginTexture, drops: drops, stats: stats, atPosition: self.position, spawnedFrom: self)
            (self.scene as! InGameScene).addObject(newEnemy)
        }
        else {
            elapsedTime += deltaT
        }
    }
    
    func setEnabled(toVal:Bool) {
        
    }
    
}

class FixedNumSpawner:Spawner {
    private let rateOfSpawning:Double
    private let maxNumOfEnemies:Int
    private var currNumOfEnemies:Int = 0
    private var elapsedTime:Double = 0
    init(loc:CGPoint, withEnemyID:String, threshold:CGFloat, rate:Double, maxNumEnemies:Int) {
        maxNumOfEnemies = maxNumEnemies
        rateOfSpawning = rate
        super.init(loc: loc, withEnemyID:withEnemyID, threshold:threshold)
    }
    
    convenience init(fromBase64:String, loc:CGPoint) {
        // "enemyID, threshold, rate, maxNumEnemies"
        let optArr = fromBase64.splitBase64IntoArray()
        if (optArr.count != 4) {
            fatalError()
        }
        let enemyID = optArr[0]
        let threshold = CGFloat(s:optArr[1])
        let rate = Double(optArr[2])!
        let maxNumEnemies = Int(optArr[3])!
        self.init(loc:loc, withEnemyID: enemyID, threshold: threshold, rate: rate, maxNumEnemies: maxNumEnemies)
    }
    

    override func update(deltaT: Double) {
        if (playerIsWithinRadius && currNumOfEnemies < maxNumOfEnemies && elapsedTime > rateOfSpawning) {
           // let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
            let newEnemy = Enemy(name: enemyID, textureDict: enemyTextureDict, beginTexture: beginTexture, drops: drops, stats: stats, atPosition: self.position, spawnedFrom: self)
            (self.scene as! InGameScene).addObject(newEnemy)
            currNumOfEnemies += 1
            elapsedTime = 0
        }
        else {
            elapsedTime += deltaT
        }
    }
    
    override func childDied() {
        currNumOfEnemies -= 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
}

class OneTimeSpawner:Spawner {
    
    override init(loc: CGPoint, withEnemyID: String, threshold: CGFloat) {
        super.init(loc: loc, withEnemyID: withEnemyID, threshold: threshold)
    }
    
    convenience init(fromBase64:String, loc:CGPoint) {
        // "enemyID, threshold"
        let optArr = fromBase64.splitBase64IntoArray()
        if (optArr.count != 2) {
            fatalError()
        }
        let enemyID = optArr[0]
        let threshold = CGFloat(s:optArr[1])
        self.init(loc:loc, withEnemyID: enemyID, threshold: threshold)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaT: Double) {
        if (playerIsWithinRadius) {
           // let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
            let newEnemy = Enemy(name: enemyID, textureDict: enemyTextureDict, beginTexture: beginTexture, drops: drops, stats: stats, atPosition: self.position, spawnedFrom: self)
            (self.scene as! InGameScene).addObject(newEnemy)
            self.removeFromParent()
        }
    }
}

class Portal:MapObject, Interactive {
    
    let thumbnailImg:String
    let autotrigger:Bool

    private let destinationLevel:LevelHandler.LevelDefinition
    private let endsLevel:Bool
    init(loc:CGPoint, destinationIndex:Int, autotrigger:Bool, thumbnailImg:String, endsLevel:Bool) {
        self.destinationLevel = defaultLevelHandler.levelDict[destinationIndex]!
        self.autotrigger = autotrigger
        self.thumbnailImg = thumbnailImg
        self.endsLevel = endsLevel
        
        super.init(loc: loc)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20) //TODO: standardize interaction radius
        self.physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Interactive
        self.physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody!.pinned = true
    }
    
    convenience init(fromBase64:String, loc:CGPoint) {
        // "destination_index, autotrigger, thumbnailImg"
        let optArr = fromBase64.splitBase64IntoArray()
        if (optArr.count != 4) {
            fatalError()
        }
        let destInd = Int(optArr[0])!
        let autotrigger = optArr[1] == "true"
        let thumbnail = optArr[2]
        let endsLevel = optArr[3] == "true"
        self.init(loc:loc, destinationIndex: destInd, autotrigger: autotrigger, thumbnailImg: thumbnail, endsLevel: endsLevel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trigger() {
        if (endsLevel) {
            NSNotificationCenter.defaultCenter().postNotificationName("levelEndedVictory", object: nil)
        }
        else {
            (self.scene as! InGameScene).setLevel(MapLevel(level: destinationLevel))
        }
    }
    
    func displayPopup(state: Bool) {
        
    }
}


class ItemBag:MapObject, Interactive {
    let autotrigger:Bool = false
    var thumbnailImg: String {
        return item.img
    }
    
    var item:Item
    
    init (withItem: Item, loc:CGPoint) {
        item = withItem
        super.init(loc: loc)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20) //TODO: standardize interaction radius
        self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.Interactive
        self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody?.pinned = true
        self.runAction(SKAction.waitForDuration(20, withRange: 2), completion: {[unowned self] in
            self.removeAllChildren()
            self.removeFromParent()
        })
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trigger() {
        NSNotificationCenter.defaultCenter().postNotificationName("groundBagTapped", object: self)
    }
        
    func displayPopup(state:Bool) {
        if (state) {
            addChild(PopUp(image: thumbnailImg, size: CGSizeMake(8, 8), parent:self))
        }
        else {
            removeAllChildren()
        }
    }
    
    func setItemTo(_item:Item?) {
        if (_item == nil) {
            removeFromParent()
        }
        else {
            item = _item!
        }
    }
}

class UsableItemResponder:MapObject {
    private let eventKey:String
    
    init(loc:CGPoint, eventKey:String) {
        self.eventKey = eventKey
        super.init(loc: loc)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(eventTriggered), name: "UsableItemUsed", object: nil)
    }
    
    @objc final private func eventTriggered(notification:NSNotification) {
        if (notification.object as! String == eventKey) {
            triggerAction()
        }
    }
    func triggerAction() {
        //override me
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InfoDisplay:MapObject {
    private let infoToDisplay:String
    private let triggerDistance:CGFloat

    init (fromBase64:String, loc:CGPoint) {
        let optArr = fromBase64.splitBase64IntoArray()
        infoToDisplay = optArr[0]
        triggerDistance = CGFloat(s: optArr[1])
        super.init(loc: loc)
        physicsBody = SKPhysicsBody(circleOfRadius: triggerDistance)
        physicsBody!.pinned = true
        physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.InfoDisplay
        physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.ThisPlayer
        physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func postInfo() {
        NSNotificationCenter.defaultCenter().postNotificationName("postInfoToDisplay", object: infoToDisplay)
    }
}

/*class Trap:MapObject { //TODO: finish this
    private let triggerDistance:CGFloat
    let damage:CGFloat
    private let node:SKSpriteNode
    private let statusInflicted:StatusCondition?
    init(fromBase64:String, loc:CGPoint) {
    //texture name, damage, side effect rawvalue
        let optArr = fromBase64.splitBase64IntoArray()
        node = SKSpriteNode(imageNamed: optArr[0])
        node.texture?.filteringMode = .Nearest
        node.hidden = true
        self.addChild(node)
        
        
    }
}*/


