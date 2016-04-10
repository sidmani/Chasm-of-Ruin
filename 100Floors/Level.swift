//
//  Level.swift
//  100Floors
//
//  Created by Sid Mani on 1/29/16.
//
//
class BaseLevel:SKNode {
    static let hubID = "hub"

    struct LayerDef {
        static let PopUps:CGFloat = 20
        static let Lighting:CGFloat = 8
        static let Effects:CGFloat = 7
        static let MapAbovePlayer:CGFloat = 6
        static let Projectiles:CGFloat = 5
        static let Entity:CGFloat = 4
        static let MapObjects:CGFloat = 3.5
        static let MapTop:CGFloat = 3
    }
    let startLoc:CGPoint
    let tileEdge:CGFloat
    let levelName:String
    let desc:String
    let mapSizeOnScreen: CGSize
    let objects = SKNode()

    init(_startLoc:CGPoint, _name:String, description: String, _tileEdge:CGFloat, mapSizeOnScreen:CGSize) {
        startLoc = _startLoc
        tileEdge = _tileEdge
        desc = description
        levelName = _name
        self.mapSizeOnScreen = mapSizeOnScreen
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func indexForPoint(p:CGPoint) -> CGPoint {
        fatalError("must be overriden")
    }
    func cull(x:Int, y:Int, width:Int, height:Int) {
        fatalError("must be overriden")
    }  
}

class MapLevel:BaseLevel, Updatable {
    private var map:SKATiledMap
    var collisionBodies = SKNode()
    
    init(_map:String, _name:String, _startLoc:CGPoint) {
        map = SKATiledMap(mapName: _map)
        let mapSize = CGSize(width: Int(screenSize.width/CGFloat(map.tileWidth)), height: Int(screenSize.height/CGFloat(map.tileHeight)))
        super.init(_startLoc: _startLoc, _name: _name, description:"", _tileEdge: CGFloat(map.tileWidth), mapSizeOnScreen: mapSize)
        
        self.addChild(map)
        self.addChild(objects)
        if (map.spriteLayers.count > 1) {
            for i in 0..<map.spriteLayers.count-1 {
                (map.spriteLayers[i] as! SKNode).zPosition = LayerDef.MapTop - CGFloat(map.spriteLayers.count) + CGFloat(i)
            }
            (map.spriteLayers[map.spriteLayers.count-1] as! SKNode).zPosition = LayerDef.MapAbovePlayer
        }
        else {
            map.zPosition = LayerDef.MapTop
        }

        for l in 0..<map.spriteLayers.count { //should be able to delete this if Tiled collisions are fixed
            for x in 0..<map.mapWidth {
                for y in 0..<map.mapHeight {
                    let _sprite:SKASprite? = map.spriteOnLayer(l, indexX: x, indexY: y)
                    if (_sprite != nil && _sprite!.properties != nil) {
                        let sprite:SKASprite = _sprite!
                            var bodies:[SKPhysicsBody] = []
                            if (sprite.properties["NorthImpassable"] != nil && sprite.properties["NorthImpassable"]!.boolValue! == true) {

                                bodies.append(SKPhysicsBody(rectangleOfSize: CGSize(width: sprite.size.width, height: 0.1), center: CGPointMake(0, sprite.size.height/2)))
                            }
                            if (sprite.properties["WestImpassable"] != nil && sprite.properties["WestImpassable"]!.boolValue! == true) {
                                bodies.append(SKPhysicsBody(rectangleOfSize: CGSize(width: 0.1, height: sprite.size.height), center: CGPointMake(-sprite.size.width/2, 0)))

                            }
                            if (sprite.properties["EastImpassable"] != nil && sprite.properties["EastImpassable"]!.boolValue! == true) {
                                bodies.append(SKPhysicsBody(rectangleOfSize: CGSize(width: 0.1, height: sprite.size.height), center: CGPointMake(sprite.size.width/2, 0)))

                            }
                            if (sprite.properties["SouthImpassable"] != nil && sprite.properties["SouthImpassable"]!.boolValue! == true) {
                                bodies.append(SKPhysicsBody(rectangleOfSize: CGSize(width: sprite.size.width, height: 0.1), center: CGPointMake(0, -sprite.size.height/2)))

                            }
                            
                            let newCollisionSprite = SKSpriteNode(color: UIColor.clearColor(), size: sprite.size)
                            newCollisionSprite.zPosition = CGFloat(l)
                            newCollisionSprite.position = sprite.position
                            newCollisionSprite.physicsBody = SKPhysicsBody(bodies: bodies)
                            newCollisionSprite.physicsBody?.dynamic = false
                            newCollisionSprite.physicsBody?.restitution = 0
                            newCollisionSprite.physicsBody?.pinned = true
                            newCollisionSprite.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.MapBoundary
                            newCollisionSprite.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.None
                            newCollisionSprite.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.None
                            collisionBodies.addChild(newCollisionSprite)
                    }
                }
            }
        }
        self.addChild(collisionBodies)

    }
    
    convenience init (withID:String) {
        ///Load level from XML
        var thisLevel:AEXMLElement
        if let levels = levelXML.root["level"].allWithAttributes(["index":withID]) {
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
            case "ItemBag":
                newObj = ItemBag(fromElement: obj, withTileEdge: CGFloat(map.tileWidth))
                objects.addChild(newObj)
            default:
                print("unsupported map object type")
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func indexForPoint(p:CGPoint) -> CGPoint {
        return map.indexForPoint(p)
    }
    
    override func cull(x:Int, y:Int, width:Int, height:Int) {
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