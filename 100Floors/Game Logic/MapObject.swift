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
        default:
            fatalError()
        }
    }
    
    init(loc:CGPoint) {
        super.init()
        self.position = loc
        self.zPosition = BaseLevel.LayerDef.MapObjects
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Spawner:MapObject, Updatable {
    private let enemyID:String
    private var playerIsWithinRadius:Bool = false

    init(loc: CGPoint, withEnemyID:String, threshold:CGFloat) {
        enemyID = withEnemyID
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
        let str = fromBase64.base64Decoded()
        let optArr = str.componentsSeparatedByString(",")
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
            let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
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
        let str = fromBase64.base64Decoded()
        let optArr = str.componentsSeparatedByString(",")
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
            let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
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
        let str = fromBase64.base64Decoded()
        let optArr = str.componentsSeparatedByString(",")
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
            let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
            (self.scene as! InGameScene).addObject(newEnemy)
            self.removeFromParent()
        }
    }
}

class Portal:MapObject, Interactive {
    
    let thumbnailImg:String
    let autotrigger:Bool

    private let destinationIndex:Int
    private let endsLevel:Bool
    init(loc:CGPoint, destinationIndex:Int, autotrigger:Bool, thumbnailImg:String, endsLevel:Bool) {
        self.destinationIndex = destinationIndex
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
        let str = fromBase64.base64Decoded()
        let optArr = str.componentsSeparatedByString(",")
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
            (self.scene as! InGameScene).endLevel()
        }
        else {
            (self.scene as! InGameScene).setLevel(MapLevel(index:destinationIndex))
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
    
}


