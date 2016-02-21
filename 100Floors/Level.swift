//
//  Level.swift
//  100Floors
//
//  Created by Sid Mani on 1/29/16.
//
//

class Level:SKNode { //level is just a map with attributes etc
    private var map:SKATiledMap
    var startLoc:CGPoint
    var objects = SKNode()
    
    init(_map:String, _name:String, _startLoc:CGPoint) {
        map = SKATiledMap(mapName: _map)
        startLoc = _startLoc
        super.init()
        name = _name
        self.addChild(map)
        self.addChild(objects)
        self.zPosition = 0
        self.physicsBody = SKPhysicsBody()
        self.physicsBody!.pinned = true
        objects.physicsBody = SKPhysicsBody()
        objects.physicsBody!.pinned = true
        objects.zPosition = 1

    }
    convenience init (_id:String) {
        ///Load level from XML
        var thisLevel:AEXMLElement
        if let levels = levelXML!.root["level"].allWithAttributes(["index":_id]) {
            if (levels.count != 1) {
                fatalError("Level ID error")
            }
            else {
                thisLevel = levels[0]
            }
        }
        else {
            fatalError("Level Not Found")
        }
        ////////
        let location = CGPointMake(CGFloat(thisLevel["spawn-loc"]["x"].doubleValue), CGFloat(thisLevel["spawn-loc"]["y"].doubleValue))
        self.init(_map:thisLevel["map"].stringValue, _name:thisLevel["name"].stringValue, _startLoc:location) //init map
        //add all map objects
        for obj in thisLevel["map-objects"].children {
            var newObj:MapObject
            switch (obj["type"].stringValue) {
            case "Portal":
                let loc = CGPointMake(CGFloat(obj["loc"]["x"].doubleValue), CGFloat(obj["loc"]["y"].doubleValue))
                let destID = obj["dest-id"].stringValue
                newObj = Portal(loc: tileEdge*loc, _destinationID: destID)
            default:
                fatalError("unsupported map object type")
            }
            objects.addChild(newObj)
        }
        ////////
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func indexForPoint(p:CGPoint) -> CGPoint {
        return map.indexForPoint(p)
    }
    func cull(x:Int, y:Int, width:Int, height:Int) {
        map.cullAroundIndexX(x, indexY: y, columnWidth: width, rowHeight: height)
    }
    func updateMapObjects() {
        
    }
}

class Dungeon { //this is procedurally generated
    
}