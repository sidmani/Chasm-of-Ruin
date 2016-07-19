
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
    init(_ s:String) {
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

//class BaseLevel:SKNode {
//
//
//    
//    
//    init(startLoc:CGPoint, name:String, tileEdge:CGFloat, mapSize:CGSize,mapSizeOnScreen:CGSize) {
//        self.startLoc = startLoc
//        self.mapSize = mapSize
//        self.tileEdge = tileEdge
//  //      self.levelName = name
//        self.mapSizeOnScreen = mapSizeOnScreen
//        super.init()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func indexForPoint(p:CGPoint) -> CGPoint {
//        fatalError("must be overriden")
//    }
//    
//    func cull(x:Int, y:Int, width:Int, height:Int) {
//        fatalError("must be overriden")
//    }
//    func speedModForIndex(p:CGPoint) -> CGFloat {
//        return 1
//    }
//
//}

class MapLevel:SKNode, Updatable {
    struct LayerDef {
        static let Effects:CGFloat = 100
        static let PopUps:CGFloat = 20
        static let Lighting:CGFloat = 8
        static let MapAbovePlayer:CGFloat = 6
        static let Projectiles:CGFloat = 3.9
        static let Entity:CGFloat = 4.5 //range 4-4.5
        static let MapObjects:CGFloat = 4.5
        static let MapTop:CGFloat = 3
    }
    let mapSize:CGSize
    let tileEdge:CGFloat
    //   let levelName:String
    let mapSizeOnScreen: CGSize
    
    let startLoc:CGPoint
    let objects = SKNode()

    private let map:SKATiledMap
    let definition:LevelHandler.LevelDefinition
    private var waves:[Wave] = []
    var currWave:Int = -1
    init(level: LevelHandler.LevelDefinition) {
        definition = level
        map = SKATiledMap(mapName: level.fileName)
        
        let startLocPoint = CGPoint(map.mapProperties["StartLoc"] as! String)
        let mapSizeOnScreen = CGSize(width: Int(screenSize.width/CGFloat(map.tileWidth)), height: Int(screenSize.height/CGFloat(map.tileHeight)))
        let mapSize = CGSizeMake(CGFloat(map.mapWidth*map.tileWidth), CGFloat(map.mapHeight*map.tileHeight))
        let numWaves = Int(map.mapProperties["NumWaves"] as! String)!
        for i in 1...numWaves {
            waves.append(Wave(fromBase64: map.mapProperties["Wave\(i)"] as! String))
        }
        
       // super.init(startLoc: startLocPoint, name: (map.mapProperties["Name"] as! String), tileEdge: CGFloat(map.tileWidth), mapSize:mapSize, mapSizeOnScreen: mapSizeOnScreen)
        self.startLoc = startLocPoint
        self.tileEdge = CGFloat(map.tileWidth)
        self.mapSize = mapSize
        self.mapSizeOnScreen = mapSizeOnScreen
        super.init()
        
        for layer in map.objectLayers {
            for obj in layer.objects {
                if (obj.properties?["Data"] != nil) {
                    let loc = CGPointMake(CGFloat(obj.x), CGFloat(obj.y))
                    objects.addChild(MapObject.initHandler(obj.type, fromBase64: obj.properties!["Data"] as! String, loc: loc))
                }
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
    
    func nextWave() {
        currWave += 1
        if (currWave == waves.count) {
            NSNotificationCenter.defaultCenter().postNotificationName("levelEndedVictory", object: nil)
            return
        }
        for enemy in waves[currWave].enemies {
            (self.scene as? InGameScene)?.addObject(enemy)
        }
//        if (currWave == 0) {
//            //self.addChild(waves[currWave])
//            for enemy in waves[currWave].enemies {
//                (self.scene as? InGameScene)?.addObject(enemy)
//            }
//        }
//        else if (currWave == waves.count-1) {
//         //   waves[currWave].removeFromParent()
//            NSNotificationCenter.defaultCenter().postNotificationName("levelEndedVictory", object: nil)
//            //end level
//        }
//        else {
//           // waves[currWave-1].removeFromParent()
//        //    self.addChild(waves[currWave]))
//            for enemy in waves[currWave].enemies {
//                (self.scene as? InGameScene)?.addObject(enemy)
//            }
//            currWave += 1
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func indexForPoint(p:CGPoint) -> CGPoint {
        return map.index(p)
    }
    
    func cull(x:Int, y:Int, width:Int, height:Int) {
        map.cullAround(x, y: y, width: width, height: height)
    }
    
    func update(deltaT: Double) {
        for object in objects.children {
            (object as? Updatable)?.update(deltaT)
        }
    }
    
    func waveIsOver() -> Bool {
        print("wave: \(currWave)")
        return waves[currWave].waveIsOver()
    }
    
    func speedModForIndex(point:CGPoint) -> CGFloat {
        let sprite = map.spriteFor(0, x: Int(point.x), y: Int(point.y))
        return sprite.speedMod
    }
}

class Wave {
    private var enemiesLeft:Int
  //  private var test = 3
    var enemies:[Enemy] = []
    init(enemies:[Enemy]) {
        enemiesLeft = enemies.count
        self.enemies = enemies
      //  super.init()
//        for enemy in enemies {
//            self.addChild(enemy)
//        }
    }
    
    init(fromBase64:String) {
        //enemy:5,9|enemy:loc...
        let enemyArr = fromBase64.splitBase64IntoArray("|")
        enemiesLeft = enemyArr.count
       // super.init()
        for pair in enemyArr {
            let pairArr = pair.componentsSeparatedByString(":")
            let loc = CGPoint(pairArr[1])
            let thisEnemy = enemyXML.root["enemy"].allWithAttributes(["id":pairArr[0]])!.first!
            let stats = Stats.statsFrom(thisEnemy["stats"].stringValue)
            // initialize textures/animations
            var enemyTextureDict:[String:[SKTexture]] = [:]
            var beginTexture = ""
            if let animations = thisEnemy["animation"].all {
                for animation in animations {
                    var textArr:[SKTexture] = []
                    let frames = Int(animation.attributes["frames"]!)!
                    for i in 0..<frames {
                        let newTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed("\(animation.stringValue)\(i)")
                        newTexture.filteringMode = .Nearest
                        textArr.append(newTexture)
                    }
                    enemyTextureDict[animation.attributes["name"]!] = textArr
                    if (beginTexture == "") {
                        beginTexture = animation.attributes["name"]!
                    }
                }
            }
            // initalize drops
            var drops:[(object:MapObject, chance:CGFloat)] = []
            if let enemyDrops = thisEnemy["drop"].all {
                for drop in enemyDrops {
                    drops.append((object: MapObject.initHandler(drop.attributes["type"]!, fromBase64: drop.stringValue, loc: CGPointZero), chance: CGFloat(drop.attributes["chance"]!)))
                }
            }
            
           // (self.scene as? InGameScene)?.addObject(Enemy(name: pairArr[0], textureDict: enemyTextureDict, beginTexture: beginTexture, drops: drops, stats: stats, atPosition: loc, wave: self))
            enemies.append(Enemy(name: pairArr[0], textureDict: enemyTextureDict, beginTexture: beginTexture, drops: drops, stats: stats, atPosition: loc, wave: self))
        }
        SKTextureAtlas.preloadTextureAtlases([SKTextureAtlas(named: "WarpB")], withCompletionHandler: {})

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func waveIsOver() -> Bool {
        print(enemiesLeft)
        return (enemiesLeft == 0)
    }
    
    func enemyDied() {
        enemiesLeft -= 1
     //   test -= 1
    }
}
