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
    func displayPopup(_ state:Bool)
}

protocol Activate {
    func activate()
    func deactivate()
}


extension String {
    func base64Encoded() -> String {
        let plainData = data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return base64String!
    }
    
    func base64Decoded() -> String {
        let decodedData = Data(base64Encoded: self, options:NSData.Base64DecodingOptions(rawValue: 0))
        return NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue)! as String
    }
    
    func splitBase64IntoArray(_ separator:String) -> [String] {
        return self.base64Decoded().components(separatedBy: separator)
    }
}

class MapObject:SKNode {
    static func initHandler(_ type:String, fromBase64:String, loc:CGPoint) -> MapObject {
        switch (type) {
    //    case "Portal":
    //       return Portal(fromBase64: fromBase64, loc: loc)
        case "ItemBag":
            return ItemBag(withItem: Item.initHandlerID(fromBase64), loc: loc)
    //    case "ConstantRateSpawner":
    //        return ConstantRateSpawner(fromBase64: fromBase64, loc: loc)
    //    case "FixedNumSpawner":
    //       return FixedNumSpawner(fromBase64: fromBase64, loc: loc)
    //    case "OneTimeSpawner":
   //         return OneTimeSpawner(fromBase64: fromBase64, loc: loc)
   //     case "UsableItemResponder":
   //         return UsableItemResponder(loc: loc, eventKey: fromBase64)
        case "InfoDisplay":
            return InfoDisplay(fromBase64: fromBase64, loc: loc)
      //  case "Trap":
      //      return Trap(fromBase64: fromBase64, loc: loc)
        default:
            fatalError()
        }
    }
    
    init(loc:CGPoint) {
        super.init()
        self.position = loc
        self.zPosition = MapLevel.LayerDef.MapObjects - 0.0001 * (self.position.y - self.frame.height/2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateZPosition() {
        
    }
}
//
//protocol EnemyCreator {
//    func childDied()
//}

class DisplaySpawner:MapObject, Updatable {
    let enemyName:String
    var currNumOfEnemies = 0
    let maxNumEnemies:Int
    var textureArr:[SKTexture] = []
    init(enemyImageName:String, numFrames:Int, maxNumEnemies:Int) {
        enemyName = enemyImageName
        self.maxNumEnemies = maxNumEnemies
        for i in 0..<numFrames {
            let newTexture = SKTextureAtlas(named: "Menu").textureNamed("\(enemyImageName)\(i)")
            newTexture.filteringMode = .nearest
            textureArr.append(newTexture)
        }
        super.init(loc: CGPoint.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let rateOfSpawning:Double = Double(randomBetweenNumbers(3000, secondNum: 6000))
    var elapsedTime:Double = 0
    func update(_ deltaT: Double) {
        if (currNumOfEnemies < maxNumEnemies && elapsedTime > rateOfSpawning) {
            let newEnemy = DisplayEnemy(name: "DisplayEnemy", textureDict: ["default":textureArr], beginTexture: "default", drops: [], stats: Stats.nilStats, atPosition: CGPoint(x: randomBetweenNumbers(20, secondNum: screenSize.width-20), y: randomBetweenNumbers(20, secondNum: screenSize.height-20)))
            newEnemy.parentSpawner = self
            newEnemy.setScale(screenSize.width/160)
            self.scene?.addChild(newEnemy)
            currNumOfEnemies += 1
            elapsedTime = 0
        }
        else if (currNumOfEnemies < maxNumEnemies) {
            elapsedTime += deltaT
        }
    }
    
    func childDied() {
        currNumOfEnemies -= 1
    }
}

//class Spawner:MapObject, Updatable, Activate, EnemyCreator {
//    private var playerIsWithinRadius:Bool = false
//    ///enemy data
//    private let enemyID:String
//    private var enemyTextureDict:[String:[SKTexture]] = [:]
//    private var drops:[(object:MapObject, chance:CGFloat)] = []
//    private let stats:Stats
//    private var beginTexture:String = ""
//    
//    init(loc: CGPoint, withEnemyID:String, threshold:CGFloat) {
//        let thisEnemy = enemyXML.root["enemy"].allWithAttributes(["id":withEnemyID])!.first!
//
//        enemyID = withEnemyID
//        stats = Stats.statsFrom(thisEnemy["stats"].stringValue)
//        // initialize textures/animations
//        if let animations = thisEnemy["animation"].all {
//            for animation in animations {
//                var textArr:[SKTexture] = []
//                let frames = Int(animation.attributes["frames"]!)!
//                for i in 0..<frames {
//                    let newTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("\(animation.stringValue)\(i)")
//                    newTexture.filteringMode = .Nearest
//                    textArr.append(newTexture)
//                }
//                enemyTextureDict[animation.attributes["name"]!] = textArr
//                if (beginTexture == "") {
//                    beginTexture = animation.attributes["name"]!
//                }
//            }
//        }
//        SKTextureAtlas.preloadTextureAtlases([SKTextureAtlas(named: "WarpB")], withCompletionHandler: {})
//        // initalize drops
//        if let enemyDrops = thisEnemy["drop"].all {
//            for drop in enemyDrops {
//                drops.append((object: MapObject.initHandler(drop.attributes["type"]!, fromBase64: drop.stringValue, loc: CGPointZero), chance: CGFloat(drop.attributes["chance"]!)))
//            }
//        }
//        
//        super.init(loc: loc)
//
//        physicsBody = SKPhysicsBody(circleOfRadius: threshold)
//        physicsBody!.pinned = true
//        physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Activate
//        physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.ThisPlayer
//        physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
//
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func update(deltaT: Double) {
//        //nothing here
//    }
//    
//    func childDied() {
//        //nothing here either
//    }
//    
//    func activate() {
//        playerIsWithinRadius = true
//    }
//    
//    func deactivate() {
//        playerIsWithinRadius = false
//    }
//}

//
//class ConstantRateSpawner:Spawner {
//    private let rateOfSpawning:Double
//    private var elapsedTime:Double = 0
//    
//    init(loc:CGPoint, withEnemyID:String, threshold:CGFloat, rate:Double) {
//        rateOfSpawning = rate
//        super.init(loc: loc, withEnemyID:withEnemyID, threshold:threshold)
//    }
//    convenience init(fromBase64:String, loc:CGPoint) {
//        // "enemyID, threshold, rate"
//        let optArr = fromBase64.splitBase64IntoArray(",")
//        if (optArr.count != 3) {
//            fatalError()
//        }
//        let enemyID = optArr[0]
//        let threshold = CGFloat(optArr[1])
//        let rate = Double(optArr[2])!
//        self.init(loc:loc, withEnemyID: enemyID, threshold: threshold, rate: rate)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func update(deltaT:Double) {
//        if (elapsedTime > rateOfSpawning && playerIsWithinRadius) {
//            elapsedTime = 0
//            let newEnemy = Enemy(name: enemyID, textureDict: enemyTextureDict, beginTexture: beginTexture, drops: drops, stats: stats, atPosition: self.position, spawnedFrom: self)
//            (self.scene as! InGameScene).addObject(newEnemy)
//        }
//        else {
//            elapsedTime += deltaT
//        }
//    }
//}

//class FixedNumSpawner:Spawner {
//    private let rateOfSpawning:Double
//    private let maxNumOfEnemies:Int
//    private var currNumOfEnemies:Int = 0
//    private var elapsedTime:Double = 0
//    
//    init(loc:CGPoint, withEnemyID:String, threshold:CGFloat, rate:Double, maxNumEnemies:Int) {
//        maxNumOfEnemies = maxNumEnemies
//        rateOfSpawning = rate
//        super.init(loc: loc, withEnemyID:withEnemyID, threshold:threshold)
//    }
//    
//    convenience init(fromBase64:String, loc:CGPoint) {
//        // "enemyID, threshold, rate, maxNumEnemies"
//        let optArr = fromBase64.splitBase64IntoArray(",")
//        if (optArr.count != 4) {
//            fatalError()
//        }
//        let enemyID = optArr[0]
//        let threshold = CGFloat(optArr[1])
//        let rate = Double(optArr[2])!
//        let maxNumEnemies = Int(optArr[3])!
//        self.init(loc:loc, withEnemyID: enemyID, threshold: threshold, rate: rate, maxNumEnemies: maxNumEnemies)
//    }
//    
//
//    override func update(deltaT: Double) {
//        if (playerIsWithinRadius && currNumOfEnemies < maxNumOfEnemies && elapsedTime > rateOfSpawning) {
//            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)) {
//                let newEnemy = Enemy(name: self.enemyID, textureDict: self.enemyTextureDict, beginTexture: self.beginTexture, drops: self.drops, stats: self.stats, atPosition: self.position, spawnedFrom: self)
//                (self.scene as! InGameScene).addObject(newEnemy)
//            }
//            currNumOfEnemies += 1
//            elapsedTime = 0
//        }
//        else {
//            elapsedTime += deltaT
//        }
//    }
//    
//    override func childDied() {
//        currNumOfEnemies -= 1
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
// 
//}

//class OneTimeSpawner:Spawner {
//    
//    override init(loc: CGPoint, withEnemyID: String, threshold: CGFloat) {
//        super.init(loc: loc, withEnemyID: withEnemyID, threshold: threshold)
//    }
//    
//    convenience init(fromBase64:String, loc:CGPoint) {
//        // "enemyID, threshold"
//        let optArr = fromBase64.splitBase64IntoArray(",")
//        if (optArr.count != 2) {
//            fatalError()
//        }
//        let enemyID = optArr[0]
//        let threshold = CGFloat(optArr[1])
//        self.init(loc:loc, withEnemyID: enemyID, threshold: threshold)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func update(deltaT: Double) {
//        if (playerIsWithinRadius) {
//           // let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
//            let newEnemy = Enemy(name: enemyID, textureDict: enemyTextureDict, beginTexture: beginTexture, drops: drops, stats: stats, atPosition: self.position, spawnedFrom: self)
//            (self.scene as! InGameScene).addObject(newEnemy)
//            self.removeFromParent()
//        }
//    }
//}

//class Portal:MapObject, Interactive {
//    
//    let thumbnailImg:String
//    let autotrigger:Bool
//
//    private let destinationLevel:LevelHandler.LevelDefinition?
//    private let endsLevel:Bool
//    init(loc:CGPoint, destinationIndex:Int, autotrigger:Bool, endsLevel:Bool) {
//        self.destinationLevel = defaultLevelHandler.levelDict[destinationIndex]
//        self.autotrigger = autotrigger
//        self.thumbnailImg = (destinationLevel?.thumb == nil ? "exit_lvl_img" : destinationLevel!.thumb)
//        self.endsLevel = endsLevel
//        
//        super.init(loc: loc)
//        self.physicsBody = SKPhysicsBody(circleOfRadius: 20)
//        self.physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Interactive
//        self.physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.None
//        self.physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
//        self.physicsBody!.pinned = true
//    }
//    
//    convenience init(fromBase64:String, loc:CGPoint) {
//        // "destination_index, autotrigger, endsLevel"
//        let optArr = fromBase64.splitBase64IntoArray(",")
//        if (optArr.count != 3) {
//            fatalError()
//        }
//        let destInd = Int(optArr[0])!
//        let autotrigger = optArr[1] == "true"
//        let endsLevel = optArr[2] == "true"
//        self.init(loc:loc, destinationIndex: destInd, autotrigger: autotrigger, endsLevel: endsLevel)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func trigger() {
//        if (endsLevel) {
//            NSNotificationCenter.defaultCenter().postNotificationName("levelEndedVictory", object: nil)
//        }
//        else {
//            (self.scene as! InGameScene).setLevel(MapLevel(level: destinationLevel!))
//        }
//    }
//    
//    func displayPopup(state: Bool) {
//        if (state) {
//            addChild(PopUp(image: thumbnailImg, size: CGSizeMake(8, 8), parent:self))
//        }
//        else {
//            removeAllChildren()
//        }
//
//    }
//}


class ItemBag:MapObject, Interactive {
    let autotrigger:Bool = false
    var thumbnailImg: String {
        return item.img
    }
    private var bagNode:SKSpriteNode
    var item:Item
    var popup:PopUp?
    init (withItem: Item, loc:CGPoint) {
        item = withItem
        if let weapon = item as? Weapon {
            weapon.setTextureDict()
        }
        let maxStat = item.getMaxStat()
        var texture:SKTexture
        if (maxStat < 30) {
            texture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("Sack0")
        }
        else if (maxStat < 60) {
            texture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("Sack1")
        }
        else {
            texture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("Sack2")
        }
        bagNode = SKSpriteNode(texture: texture)
        bagNode.setScale(0.5)
        bagNode.zPosition = 0
        super.init(loc: loc)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.Interactive
        self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody?.pinned = true

        self.addChild(bagNode)
        popup = PopUp(image: thumbnailImg, size: CGSize(width: 8, height: 8), parent:self)
        popup!.isHidden = true
        self.addChild(popup!)
        self.run(SKAction.wait(forDuration: 20, withRange: 2), completion: {[unowned self] in
            self.removeAllChildren()
            self.removeFromParent()
        })
        self.zPosition = MapLevel.LayerDef.Entity - 0.0001 * (self.position.y - bagNode.frame.height/2)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        trigger()
    }
    
    func trigger() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "groundBagTapped"), object: self)
    }
    
    override func updateZPosition() {
        self.zPosition = MapLevel.LayerDef.Entity - 0.0001 * (self.position.y - bagNode.frame.height/2)
    }
    
    func displayPopup(_ state:Bool) {
        if (state) {
            self.popup?.isHidden = false
        }
        else {
            self.popup?.isHidden = true
        }
    }
    
    func setItemTo(_ _item:Item?) {
        if (_item == nil) {
            removeFromParent()
        }
        else {
            item = _item!
        }
    }
}

class InfoDisplay:MapObject, Activate {
    private var infoToDisplay:[String] = []
    private let triggerDistance:CGFloat = 900

    init (fromBase64:String, loc:CGPoint) {
        //num strings| string1| string2...
        let optArr = fromBase64.splitBase64IntoArray("|")
        for i in 0..<Int(optArr[0])! {
            infoToDisplay.append(optArr[i+1])
        }
        super.init(loc: loc)
        physicsBody = SKPhysicsBody(circleOfRadius: triggerDistance)
        physicsBody!.pinned = true
        physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Activate
        physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.ThisPlayer
        physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currInfo = 0
    var timer:Timer?
    
    func postNextInfo() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "postInfoToDisplay"), object: infoToDisplay[currInfo])
        currInfo += 1
        if (currInfo == infoToDisplay.count) {
            timer?.invalidate()
        }
    }
    
    func activate() {
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(postNextInfo), userInfo: nil, repeats: true)
    }
    
    func deactivate() {
        
    }
}

class Trap:MapObject, Activate {
    private let triggerDistance:CGFloat
    let damage:CGFloat
    private let node:SKSpriteNode
    private let statusInflicted:StatusCondition?
    
    init(fromBase64:String, loc:CGPoint) {
        //texture name, damage, trigger distance, side effect rawvalue
        let optArr = fromBase64.splitBase64IntoArray("|")
        node = SKSpriteNode(imageNamed: optArr[0])
        node.texture?.filteringMode = .nearest
        node.isHidden = true
        damage = CGFloat(optArr[1])
        triggerDistance = CGFloat(optArr[2])
        statusInflicted = StatusCondition(rawValue: Double(optArr[3])!)
        super.init(loc: loc)
        self.addChild(node)
        physicsBody = SKPhysicsBody(circleOfRadius: triggerDistance)
        physicsBody!.pinned = true
        physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Activate
        physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.ThisPlayer
        physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func activate() {
        node.isHidden = false
    }
    func deactivate() {
        
    }
}

class UsableItemResponder:MapObject {
    private let eventKey:String
    
    init(loc:CGPoint, eventKey:String) {
        self.eventKey = eventKey
        super.init(loc: loc)
        NotificationCenter.default.addObserver(self, selector: #selector(eventTriggered), name: "UsableItemUsed" as NSNotification.Name, object: nil)
    }
    
    @objc final private func eventTriggered(_ notification:Notification) {
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

//class Gate:UsableItemResponder {
//    private let node:SKSpriteNode
//    init (fromBase64:String, loc:CGPoint) {
//        // texture name, event key
//        let optArr = fromBase64.splitBase64IntoArray("|")
//        node = SKSpriteNode(imageNamed: optArr[0])
//        super.init(loc: loc, eventKey: optArr[1])
//        self.addChild(node)
//        
//        physicsBody = SKPhysicsBody(rectangleOfSize: node.texture!.size())
//        physicsBody!.pinned = true
//        physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.MapBoundary
//        physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.None
//        physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.ThisPlayer
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func triggerAction() {
//        physicsBody = nil
//        node.removeFromParent()
//    }
//}

