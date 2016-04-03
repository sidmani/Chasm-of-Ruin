//
//  MapObject.swift
//  100Floors
//
//  Created by Sid Mani on 2/13/16.
//
//

class MapObject:SKNode {
    init(loc:CGPoint) {
        super.init()
        self.position = loc
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class Spawner:MapObject, Updatable {
    var enemyID:String
    init(loc:CGPoint, withEnemyID:String) {
        enemyID = withEnemyID
        super.init(loc: loc)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func update(deltaT:Double) {
        
    }
    func setEnabled(toVal:Bool) {
        
    }
}

class Portal:MapObject, Interactive {
    
    static let hubID = "Hub"
    
    let interactText = "Go!"
    var thumbnailImg:String
    var autotrigger:Bool

    var destinationID:String
 //   var enabled = true
    var showLoadScreen:Bool
    var showCountdown:Bool
    
    //var destinationLoc:CGPoint // if different than the map's defined start loc.

    init(loc:CGPoint, _destinationID:String, _autotrigger:Bool, loadScreen:Bool, countdown:Bool, thumbnail:String) {
        destinationID = _destinationID
        autotrigger = _autotrigger
        showLoadScreen = loadScreen
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
        let loadscreen = fromXMLObject["load-screen"].boolValue
        let thumbnail = fromXMLObject["thumbnail-img"].stringValue
        self.init(loc: withTileEdge*loc, _destinationID: destID, _autotrigger: autotrigger, loadScreen: loadscreen, countdown: countdown, thumbnail: thumbnail)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trigger() {
        GameLogic.usePortal(self)
    }
    func displayPopup(state: Bool) {
        
    }
}
class ItemBag:MapObject, Interactive {
    var autotrigger:Bool = false
    let interactText: String = "Pick Up"
    var thumbnailImg: String {
        return item.img
    }
    var item:Item
    init (withItem: Item, loc:CGPoint) {
        item = withItem
        super.init(loc: loc)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20) //TODO: standardize interaction radius
        self.physicsBody!.categoryBitMask = InGameScene.PhysicsCategory.Interactive
        self.physicsBody!.contactTestBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody!.collisionBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody!.pinned = true
    }
    convenience init (fromElement:AEXMLElement, withTileEdge:CGFloat) {
        let loc = CGPointMake(CGFloat(fromElement["loc"]["x"].doubleValue), CGFloat(fromElement["loc"]["y"].doubleValue))
        self.init(withItem: Item.initHandler(fromElement["itemID"].stringValue)!, loc:withTileEdge*loc)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trigger() {
        GameLogic.openInventory()
    }
        
    func displayPopup(state:Bool) {
        if (state) {
            addChild(PopUp(buttonText: interactText, image: thumbnailImg, size: CGSizeMake(16, 16), parent:self))
        }
        else {
            for child in children {
                if child is PopUp {
                    child.removeFromParent()
                    return
                }
            }
        }
    }
    
    func setItem(toItem:Item?) {
        if (toItem == nil) {
            removeFromParent()
            GameLogic.exitedDistanceOf(self)
        }
        else {
            item = toItem!
        }
    }
}






