//
//  Level.swift
//  100Floors
//
//  Created by Sid Mani on 1/29/16.
//
//

class Level:SKNode, Updatable { //level is just a map with attributes etc
    private var map:SKATiledMap
    var startLoc:CGPoint
    var objects = SKNode()
    var desc:String = ""
    var mapWidthOnScreen:Int
    var mapHeightOnScreen:Int
    var tileEdge:CGFloat
    var collisionBodies = SKNode()
    init(_map:String, _name:String, _startLoc:CGPoint) {
        map = SKATiledMap(mapName: _map)
        startLoc = _startLoc
        mapWidthOnScreen = Int(screenSize.width/CGFloat(map.tileWidth))
        mapHeightOnScreen = Int(screenSize.height/CGFloat(map.tileHeight))
        tileEdge = CGFloat(map.tileWidth)
        super.init()
        name = _name
        self.addChild(map)
        self.addChild(objects)
        self.zPosition = 0 //TODO: map layers
        self.physicsBody = SKPhysicsBody()
        self.physicsBody?.pinned = true
        objects.physicsBody = SKPhysicsBody()
        objects.physicsBody?.pinned = true
        objects.zPosition = 1
        for l in 0..<map.spriteLayers.count {
            for x in 0..<map.mapWidth {
                for y in 0..<map.mapHeight {
                    let sprite:SKASprite = map.spriteOnLayer(l, indexX: x, indexY: y)
                    if (sprite.properties != nil) {
                        if (sprite.properties["CollisionRects"]!.boolValue! == true) {
                            print("collision rects")
                        var bodies:[SKPhysicsBody] = []
                        if (sprite.properties["NorthImpassable"]!.boolValue! == true) {
                            print("north blocked")
                            bodies.append(SKPhysicsBody(rectangleOfSize: CGSize(width: sprite.size.width, height: 0.1), center: CGPointMake(0, sprite.size.height/2)))
                        }
                        if (sprite.properties["WestImpassable"]?.stringValue == "true") {
                            
                        }
                        if (sprite.properties["EastImpassable"]?.stringValue == "true") {
                            
                        }
                        if (sprite.properties["SouthImpassable"]?.stringValue == "true") {
                            
                        }
                        let newCollisionSprite = SKSpriteNode(color: UIColor.redColor(), size: sprite.size)
                        newCollisionSprite.zPosition = CGFloat(l)
                        newCollisionSprite.position = sprite.position
                        newCollisionSprite.physicsBody = SKPhysicsBody(bodies: bodies)
                        newCollisionSprite.physicsBody?.dynamic = false
                        newCollisionSprite.physicsBody?.pinned = true
                        newCollisionSprite.physicsBody?.categoryBitMask = PhysicsCategory.MapBoundary
                        newCollisionSprite.physicsBody?.collisionBitMask = PhysicsCategory.None
                        newCollisionSprite.physicsBody?.contactTestBitMask = PhysicsCategory.None
                        collisionBodies.addChild(newCollisionSprite)
                        }
                    }
                }
            }
        }
        self.addChild(collisionBodies)

    }
    convenience init (withID:String) {
        ///Load level from XML
        var thisLevel:AEXMLElement
        if let levels = levelXML!.root["level"].allWithAttributes(["index":withID]) {
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
            switch (obj["type"].stringValue) { //handle different types of map objects
            case "Portal":
                newObj = Portal(fromXMLObject: obj, withTileEdge: CGFloat(map.tileWidth))
                objects.addChild(newObj)
            default:
                print("unsupported map object type")
            }
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func indexForPoint(p:CGPoint) -> CGPoint {
        return map.indexForPoint(p)
    }
    
    func validateMovement(toLoc:CGPoint) -> Bool {
        return false
    }
    
    func cull(x:Int, y:Int, width:Int, height:Int) {
        map.cullAroundIndexX(x, indexY: y, columnWidth: width, rowHeight: height)
    }
    
    func update(deltaT: Double) {
        for object in objects.children {
            if let obj = object as? Updatable {
                obj.update(deltaT)
            }
        }
    }
}