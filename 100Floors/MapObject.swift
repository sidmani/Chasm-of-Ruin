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

class MapObject:SKNode {
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

    init(loc: CGPoint, withEnemyID:String) {
        enemyID = withEnemyID
        super.init(loc: loc)
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
    private let distanceThreshold:CGFloat
    private var elapsedTime:Double = 0
    init(loc:CGPoint, withEnemyID:String, rate:Double, threshold:CGFloat) {
        rateOfSpawning = rate
        distanceThreshold = threshold
        super.init(loc: loc, withEnemyID:withEnemyID)
        physicsBody = SKPhysicsBody(circleOfRadius: threshold)
        physicsBody!.pinned = true
        physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Spawner
        physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.ThisPlayer
        physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
    }
  
    convenience init(fromElement:AEXMLElement, withTileEdge:CGFloat) {
        let loc = CGPointMake(CGFloat(fromElement["loc"]["x"].doubleValue), CGFloat(fromElement["loc"]["y"].doubleValue))
        let rate = fromElement["rate"].doubleValue
        let dist = CGFloat(fromElement["distance-threshold"].doubleValue)
        let enemyID = fromElement["enemy-id"].stringValue
        self.init(loc: withTileEdge*loc, withEnemyID: enemyID, rate:rate, threshold:dist)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaT:Double) {
        if (elapsedTime > rateOfSpawning && playerIsWithinRadius) {
            elapsedTime = 0
            let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
            (self.scene as! InGameScene).addObject(newEnemy)
           // GameLogic.addObject(newEnemy)
        }
        else {
            elapsedTime += deltaT
        }
    }
    
    func setEnabled(toVal:Bool) {
        
    }
    
}

class FixedNumSpawner:Spawner {
    private let maxNumOfEnemies:Int
    private var currNumOfEnemies:Int = 0

    init(loc:CGPoint, withEnemyID:String, maxNumEnemies:Int) {
        maxNumOfEnemies = maxNumEnemies
        super.init(loc: loc, withEnemyID:withEnemyID)
    }
    
    override func update(deltaT: Double) {
        if (currNumOfEnemies < maxNumOfEnemies) {
            let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
            (self.scene as! InGameScene).addObject(newEnemy)
          //  GameLogic.addObject(newEnemy)
            currNumOfEnemies += 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func childDied() {
        currNumOfEnemies -= 1
    }
    
}

class OneTimeSpawner:Spawner {
    private let distanceThreshold:CGFloat
    
    init(loc:CGPoint, withEnemyID:String, threshold:CGFloat) {
        distanceThreshold = threshold
        super.init(loc: loc, withEnemyID:withEnemyID)
        physicsBody = SKPhysicsBody(circleOfRadius: threshold)
        physicsBody!.pinned = true
        physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Spawner
        physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.ThisPlayer
        physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaT: Double) {
        if (playerIsWithinRadius) {
            let newEnemy = Enemy(withID: enemyID, atPosition: self.position, spawnedFrom: self)
            (self.scene as! InGameScene).addObject(newEnemy)
            //   GameLogic.addObject(newEnemy)
            self.removeFromParent()
        }
    }
}

class Portal:MapObject, Interactive {
    
    let thumbnailImg:String
    let autotrigger:Bool

    private let destinationID:String
    let showIntroScreen:Bool
    let showCountdown:Bool
    
    init(loc:CGPoint, _destinationID:String, _autotrigger:Bool, introScreen:Bool, countdown:Bool, thumbnail:String) {
        destinationID = _destinationID
        autotrigger = _autotrigger
        showIntroScreen = introScreen
        showCountdown = countdown
        thumbnailImg = thumbnail
        
        super.init(loc: loc)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20) //TODO: standardize interaction radius
        self.physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Interactive
        self.physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody!.pinned = true
    }
    
    convenience init(fromXMLObject:AEXMLElement, withTileEdge:CGFloat) {
        let loc = CGPointMake(CGFloat(fromXMLObject["loc"]["x"].doubleValue), CGFloat(fromXMLObject["loc"]["y"].doubleValue))
        let destID = fromXMLObject["dest-id"].stringValue
        let autotrigger = fromXMLObject["autotrigger"].boolValue
        let countdown = fromXMLObject["countdown"].boolValue
        let introScreen = fromXMLObject["load-screen"].boolValue
        let thumbnail = fromXMLObject["thumbnail-img"].stringValue
        self.init(loc: withTileEdge*loc, _destinationID: destID, _autotrigger: autotrigger, introScreen: introScreen, countdown: countdown, thumbnail: thumbnail)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trigger() {
        (self.scene as! InGameScene).setLevel(MapLevel(withID: destinationID))
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
    }
    convenience init (fromElement:AEXMLElement, withTileEdge:CGFloat) {
        let loc = CGPointMake(CGFloat(fromElement["loc"]["x"].doubleValue), CGFloat(fromElement["loc"]["y"].doubleValue))
        self.init(withItem: Item.initHandlerID(fromElement["itemID"].stringValue)!, loc:withTileEdge*loc)
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
         //   GameLogic.exitedDistanceOf(self)
        }
        else {
            
            item = _item!
        }
    }
}






