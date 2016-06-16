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
    
    init(loc:CGPoint, withEnemyID:String, rate:Double, threshold:CGFloat) {
        rateOfSpawning = rate
        super.init(loc: loc, withEnemyID:withEnemyID, threshold:threshold)
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
    init(loc:CGPoint, withEnemyID:String, rate:Double, threshold:CGFloat, maxNumEnemies:Int) {
        maxNumOfEnemies = maxNumEnemies
        rateOfSpawning = rate
        super.init(loc: loc, withEnemyID:withEnemyID, threshold:threshold)
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

    private let destinationID:String
    
    init(loc:CGPoint, _destinationID:String, _autotrigger:Bool, thumbnail:String) {
        destinationID = _destinationID
        autotrigger = _autotrigger
        thumbnailImg = thumbnail
        
        super.init(loc: loc)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20) //TODO: standardize interaction radius
        self.physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Interactive
        self.physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody!.pinned = true
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






