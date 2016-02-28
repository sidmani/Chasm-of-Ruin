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
    func update() {
        
    }
    func enable() {
        
    }
    func disable() {
        
    }
}

class Portal:MapObject, Interactive {
    var destinationID:String
    var autotrigger:Bool
    //var destinationLoc:CGPoint // if different than the map's defined start loc.
    //var enabledTexture:String
    //var disabledTexture:String
    init(loc:CGPoint, _destinationID:String, _autotrigger:Bool) {
        destinationID = _destinationID
        autotrigger = _autotrigger
      //  enabledTexture = _enabledTexture
      //  disabledTexture = _disabledTexture
        super.init(loc: loc)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20) //TODO: standardize interaction radius
        self.physicsBody?.categoryBitMask = PhysicsCategory.Interactive
        self.physicsBody?.contactTestBitMask = PhysicsCategory.None
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.physicsBody?.pinned = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func trigger() {
        GameLogic.usePortal(self)
    }
    func enable() {
        
    }
    func disable() {
        
    }
}