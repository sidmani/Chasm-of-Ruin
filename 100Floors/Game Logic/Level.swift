
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
        let stringArr = s.components(separatedBy: ",")
        self.init(x: stringArr[0], y: stringArr[1])
    }
    
    init(x:String, y:String) {
        self.init(x: CGFloat(NumberFormatter().number(from: x)!), y: CGFloat(NumberFormatter().number(from: y)!))
    }
}

extension CGFloat {
    init(_ s:String) {
        self.init(NumberFormatter().number(from: s)!)
    }
}

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
    let mapSizeOnScreen: CGSize
    
    let objects = SKNode()

    private let map:SKATiledMap
    let definition:LevelHandler.LevelDefinition
    
    var spawnPoints:[String:CGPoint] = [:]
    var startLoc:CGPoint {
        return spawnPoints["StartLoc"]!
    }
    private var waves:[String] = []
    var currWaveIndex:Int = -1
    private var currWave:Wave?
    private var preloadedWave:Wave?

    var numWaves:Int {
        return waves.count
    }
    init(level: LevelHandler.LevelDefinition) {
        definition = level
        map = SKATiledMap(mapName: level.fileName)
        
        let mapSizeOnScreen = CGSize(width: Int(screenSize.width/CGFloat(map.tileWidth)), height: Int(screenSize.height/CGFloat(map.tileHeight)))
        let mapSize = CGSize(width: CGFloat(map.mapWidth*map.tileWidth), height: CGFloat(map.mapHeight*map.tileHeight))
       
        
        let numWaves = Int(map.mapProperties["NumWaves"] as! String)!
        self.mapSize = mapSize
        self.mapSizeOnScreen = mapSizeOnScreen
        super.init()
        
        SKTextureAtlas.preloadTextureAtlases([SKTextureAtlas(named: "WarpB")], withCompletionHandler: {})

        for layer in map.objectLayers {
            for obj in layer.objects {
                if (obj.type == "SpawnPoint") {
                    spawnPoints[obj.name] = CGPoint(x: obj.x, y: obj.y)
                }
                else if (obj.properties?["Data"] != nil) {
                    let loc = CGPoint(x: CGFloat(obj.x), y: CGFloat(obj.y))
                    objects.addChild(MapObject.initHandler(obj.type, fromBase64: obj.properties!["Data"] as! String, loc: loc))
                }
            }
        }
        
        for i in 0..<map.spriteLayers.count {
            if let isAbovePlayer = (map.spriteLayers[i].properties["AbovePlayer"] as? String), isAbovePlayer == "true" {
                map.spriteLayers[i].zPosition = LayerDef.MapAbovePlayer + 0.001 * CGFloat(i)
            }
            else if let animationLayer = (map.spriteLayers[i].properties["AnimationLayer"] as? String), animationLayer == "true" {
                SKAction.repeatForever(SKAction.sequence([SKAction.run() { [unowned self] in self.map.spriteLayers[i].isHidden = !self.map.spriteLayers[i].isHidden }, SKAction.wait(forDuration: 0.5)]))
            }
            else {
                map.spriteLayers[i].zPosition = LayerDef.MapTop + 0.001 * CGFloat(i)
            }
        }
        
        for i in 1...numWaves {
             waves.append(map.mapProperties["Wave\(i)"] as! String)
        }
        preloadedWave = Wave(fromBase64: waves[0], spawnPoints: spawnPoints)
        
        self.addChild(map)
        self.addChild(objects)
    }
    
    func nextWave() {
        currWaveIndex += 1
        currWave = preloadedWave!
        for enemy in currWave!.enemies {
            (self.scene as? InGameScene)?.addObject(enemy)
        }
        if (currWaveIndex < waves.count-1) {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [unowned self] in
                self.preloadedWave = Wave(fromBase64: self.waves[self.currWaveIndex+1], spawnPoints: self.spawnPoints)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func indexForPoint(_ p:CGPoint) -> CGPoint {
        return map.index(p)
    }
    
    func cull(_ x:Int, y:Int, width:Int, height:Int) {
        map.cullAround(x, y: y, width: width, height: height)
    }
    
    func update(_ deltaT: Double) {
        for object in objects.children {
            (object as? Updatable)?.update(deltaT)
        }
    }
    
    func waveIsOver() -> Bool {
        if (currWaveIndex >= 0 && currWaveIndex < waves.count) {
            return currWave!.waveIsOver()
        }
        return false
    }
    
    func speedModForIndex(_ point:CGPoint) -> CGFloat {
        let sprite = map.spriteFor(0, x: Int(point.x), y: Int(point.y))
        return sprite.speedMod
    }
}

class Wave {
   // private var enemiesLeft:Int
    var enemies:[Enemy] = []
    init(enemies:[Enemy]) {
        self.enemies = enemies
    //    enemiesLeft = enemies.count
    }
    
    init(fromBase64:String, spawnPoints:[String:CGPoint]) {
        //enemy:A|enemy:spawnPointName...
        let enemyArr = fromBase64.splitBase64IntoArray("|")
     //   enemiesLeft = enemyArr.count
        for pair in enemyArr {
            let pairArr = pair.components(separatedBy: ":")
            let loc = spawnPoints[pairArr[1]]!
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
                        newTexture.filteringMode = .nearest
                        textArr.append(newTexture)
                    }
                    enemyTextureDict[animation.attributes["name"]!] = textArr
                    if (beginTexture == "") {
                        beginTexture = animation.attributes["name"]!
                    }
                }
            }
            // initalize drops
            var drops:[MapObject] = []
            if let enemyDrops = thisEnemy["drop"].all {
                for drop in enemyDrops {
                    if (randomBetweenNumbers(0, secondNum: 1) <= CGFloat(drop.attributes["chance"]!)) {
                        drops.append(MapObject.initHandler(drop.attributes["type"]!, fromBase64: drop.stringValue, loc: CGPoint.zero))
                    }
                }
            }
            
            enemies.append(Enemy(name: pairArr[0], textureDict: enemyTextureDict, beginTexture: beginTexture, drops: drops, stats: stats, atPosition: loc, wave: self))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func waveIsOver() -> Bool {
        return (enemies.count == 0)
    }
    
    func enemyDied(_ enemy:Enemy) {
        //enemiesLeft -= 1
        enemies = enemies.filter() { $0 !== enemy }
        //print("Enemies left: \(enemies.count)")
    }
}
