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
    init(loc:CGPoint, withID:String) {
        enemyID = withID
        super.init(loc: loc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func update() {
        
    }
}

class Portal:MapObject {
    var destinationID:String
    init(loc:CGPoint, _destinationID:String) {
        destinationID = _destinationID
        super.init(loc: loc)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 20) //TODO: standardize interaction radius
        self.physicsBody!.categoryBitMask = mapObjectMask
    }
    //convenience init(withID:String) {
        
    //}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}