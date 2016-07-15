
//
//  Level.swift
//  100Floors
//
//  Created by Sid Mani on 1/29/16.
//
//
import SpriteKit
import UIKit
extension CGPoint {
    init(s:String) {
        let stringArr = s.componentsSeparatedByString(",")
        self.init(x: stringArr[0], y: stringArr[1])
    }
    
    init(x:String, y:String) {
        self.init(x: CGFloat(NSNumberFormatter().numberFromString(x)!), y: CGFloat(NSNumberFormatter().numberFromString(y)!))
    }
}

extension CGFloat {
    init(_ s:String) {
        self.init(NSNumberFormatter().numberFromString(s)!)
    }
}

class BaseLevel:SKNode {

    struct LayerDef {
        static let Effects:CGFloat = 100
        static let PopUps:CGFloat = 20
        static let Lighting:CGFloat = 8
        static let MapAbovePlayer:CGFloat = 6
        static let Projectiles:CGFloat = 4.5
        static let Entity:CGFloat = 4.5 //range 4-4.5
        static let MapObjects:CGFloat = 4.5
        static let MapTop:CGFloat = 3
    }
    
    let mapSize:CGSize
    let tileEdge:CGFloat
    let levelName:String
    let mapSizeOnScreen: CGSize
    
    let startLoc:CGPoint
    let objects = SKNode()
    
    
    init(startLoc:CGPoint, name:String, tileEdge:CGFloat, mapSize:CGSize,mapSizeOnScreen:CGSize) {
        self.startLoc = startLoc
        self.mapSize = mapSize
        self.tileEdge = tileEdge
        self.levelName = name
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
    func speedModForIndex(p:CGPoint) -> CGFloat {
        return 1
    }

}

class MapLevel:BaseLevel, Updatable {
    private let map:SKATiledMap
    let definition:LevelHandler.LevelDefinition
    
    init(level: LevelHandler.LevelDefinition) {
        definition = level
        map = SKATiledMap(mapName: level.fileName)
        
        let startLocPoint = CGPoint(s: map.mapProperties["StartLoc"] as! String)
        let mapSizeOnScreen = CGSize(width: Int(screenSize.width/CGFloat(map.tileWidth)), height: Int(screenSize.height/CGFloat(map.tileHeight)))
        let mapSize = CGSizeMake(CGFloat(map.mapWidth*map.tileWidth), CGFloat(map.mapHeight*map.tileHeight))
        super.init(startLoc: startLocPoint, name: (map.mapProperties["Name"] as! String), tileEdge: CGFloat(map.tileWidth), mapSize:mapSize, mapSizeOnScreen: mapSizeOnScreen)
        
        for layer in map.objectLayers {
            for obj in layer.objects {
                let loc = CGPointMake(CGFloat(obj.x), CGFloat(obj.y))
                objects.addChild(MapObject.initHandler(obj.type, fromBase64: obj.properties!["Data"] as! String, loc: loc))
            }
        }
        for i in 0..<map.spriteLayers.count {
            if let isAbovePlayer = (map.spriteLayers[i].properties["AbovePlayer"] as? String) where isAbovePlayer == "true" {
                map.spriteLayers[i].zPosition = LayerDef.MapAbovePlayer + 0.001 * CGFloat(i)
            }
            else if let animationLayer = (map.spriteLayers[i].properties["AnimationLayer"] as? String) where animationLayer == "true" {
                SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock() { [unowned self] in self.map.spriteLayers[i].hidden = !self.map.spriteLayers[i].hidden }, SKAction.waitForDuration(0.5)]))
            }
            else {
                map.spriteLayers[i].zPosition = LayerDef.MapTop + 0.001 * CGFloat(i)
            }
        }
        self.addChild(map)
        self.addChild(objects)

    }
    
    
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
            (object as? Updatable)?.update(deltaT)
        }
    }
    
    override func speedModForIndex(point:CGPoint) -> CGFloat {
        let sprite = map.spriteFor(0, x: Int(point.x), y: Int(point.y))
        return sprite.speedMod
    }
}