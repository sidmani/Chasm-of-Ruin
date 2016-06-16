//
//  Level.swift
//  100Floors
//
//  Created by Sid Mani on 1/29/16.
//
//
import SpriteKit
import UIKit
let levelDict:[Int:(String,String,String,String)] = [
    0:("Tutorial", "Tutorial","Description", "thumbnail")
]

class BaseLevel:SKNode { //TODO: probably merge these two classes together

    struct LayerDef {
        static let Effects:CGFloat = 100
        static let PopUps:CGFloat = 20
        static let Lighting:CGFloat = 8
        static let MapAbovePlayer:CGFloat = 6
        static let Projectiles:CGFloat = 5
        static let Entity:CGFloat = 4
        static let MapObjects:CGFloat = 3.5
        static let MapTop:CGFloat = 3
    }
    
    enum TerrainType:CGFloat {
        case Road = 1, Grass = 0.8, Dirt = 0.7
    }
    
    let tileEdge:CGFloat
    let levelName:String
    let desc:String
    let mapSizeOnScreen: CGSize
    
    let startLoc:CGPoint
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
    private let map:SKATiledMap
    
    init(_map:String) {
        map = SKATiledMap(mapName: _map)
        let startLocPoint = MapLevel.stringToPoint(map.mapProperties["StartLoc"] as! String)
        let mapSize = CGSize(width: Int(screenSize.width/CGFloat(map.tileWidth)), height: Int(screenSize.height/CGFloat(map.tileHeight)))
        
        super.init(_startLoc: startLocPoint, _name: (map.mapProperties["Name"] as! String), description:"", _tileEdge: CGFloat(map.tileWidth), mapSizeOnScreen: mapSize)
        
        for layer in map.objectLayers {
            for obj in layer.objects {
                    switch (obj.type) {
                        case "Portal":
                            let loc = CGPointMake(CGFloat(obj.x), CGFloat(obj.y))
                            let destID = obj.properties!["Destination"] as! String
                            let auto = (obj.properties!["Autotrigger"] as! String) == "true"
                            let thumbnail = obj.properties!["Thumbnail"] as! String
                            objects.addChild(Portal(loc: loc, _destinationID: destID, _autotrigger: auto, thumbnail: thumbnail))
                        case "ItemBag":
                            let loc = CGPointMake(CGFloat(obj.x), CGFloat(obj.y))
                            let itemID = obj.properties!["ItemID"] as! String
                            objects.addChild(ItemBag(withItem: Item.initHandlerID(itemID), loc: loc))
                        case "ConstantRateSpawner":
                            let loc = CGPointMake(CGFloat(obj.x), CGFloat(obj.y))
                            let enemyID = obj.properties!["EnemyID"] as! String
                            let rate = Double(obj.properties!["Rate"] as! String)!
                            let threshold = CGFloat(NSNumberFormatter().numberFromString(obj.properties!["Threshold"] as! String)!)
                            objects.addChild(ConstantRateSpawner(loc: loc, withEnemyID: enemyID, rate: rate, threshold: threshold))
                        case "FixedNumSpawner":
                            let loc = CGPointMake(CGFloat(obj.x), CGFloat(obj.y))
                            let enemyID = obj.properties!["EnemyID"] as! String
                            let maxNumEnemies = Int(obj.properties!["MaxNumEnemies"] as! String)!
                            let rate = Double(obj.properties!["Rate"] as! String)!
                            let threshold = CGFloat(NSNumberFormatter().numberFromString(obj.properties!["Threshold"] as! String)!)
                            objects.addChild(FixedNumSpawner(loc: loc, withEnemyID: enemyID, rate:rate, threshold:threshold, maxNumEnemies: maxNumEnemies))
                        case "OneTimeSpawner":
                            let loc = CGPointMake(CGFloat(obj.x), CGFloat(obj.y))
                            let enemyID = obj.properties!["EnemyID"] as! String
                            let threshold = CGFloat(NSNumberFormatter().numberFromString(obj.properties!["Threshold"] as! String)!)
                            objects.addChild(OneTimeSpawner(loc:loc, withEnemyID:enemyID, threshold:threshold))
                        default:
                            fatalError()
                
                    }
            }
        }
        for i in 0..<map.spriteLayers.count {
            if let isAbovePlayer = (map.spriteLayers[i].properties["AbovePlayer"] as? String) where isAbovePlayer == "true" {
                map.spriteLayers[i].zPosition = LayerDef.MapAbovePlayer + 0.001 * CGFloat(i)
            }
            else {
                map.spriteLayers[i].zPosition = LayerDef.MapTop + 0.001 * CGFloat(i)
            }
        }
        self.addChild(map)
        self.addChild(objects)

    }
    
    private static func stringToPoint(s:String) -> CGPoint {
        let stringArr = s.componentsSeparatedByString(",")
        return CGPointFromString(stringArr[0], y: stringArr[1])
    }
    
    private static func CGPointFromString(x:String, y:String) -> CGPoint {
        return CGPointMake(CGFloat(NSNumberFormatter().numberFromString(x)!), CGFloat(NSNumberFormatter().numberFromString(y)!))
    }
   /* convenience init (withID:String) {
        ///Load level from XML
        let thisLevel = levelXML.root["level"].allWithAttributes(["index":withID])!.first!
        ////////
        self.init(_map:thisLevel["map"].stringValue) //init map
      }*/
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func indexForPoint(p:CGPoint) -> CGPoint {
        return map.index(p)
    }
    
    override func cull(x:Int, y:Int, width:Int, height:Int) {
        map.cullAround(x, y: y, width: width, height: height)
    }
    
    func update(deltaT: Double) {
        for object in objects.children {
            if let obj = object as? Updatable {
                obj.update(deltaT)
            }
        }
    }
    
}