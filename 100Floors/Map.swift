//
//  Map.swift
//  100Floors
//
//  Created by Sid Mani on 1/16/16.
//
//
import SpriteKit

class Map:SKATiledMap {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init!(mapName: String!) {
        super.init(mapName: mapName)
    }
    
    
    
    
}

class TileMap:SKNode {
    
    var allNodes = [[SKSpriteNode]]()
    var leftEdgeIndex:Int = 0 {
        willSet {
            //if (newValue != leftEdgeIndex) {
                //leftEdgeIndexChanged = true
                leftEdgeIndexOld = leftEdgeIndex
            //}
        }
    }
    var bottomEdgeIndex:Int = 0 {
        willSet {
            //if (newValue != bottomEdgeIndex) {
                //bottomEdgeIndexChanged = true
                bottomEdgeIndexOld = bottomEdgeIndex
            //}
        }
    }
    
    var rightEdgeIndex:Int {
        get {
            return leftEdgeIndex + Int(screenSize.width/tileWidth)
        }
    }
    var topEdgeIndex:Int {
        get {
            return bottomEdgeIndex + Int(screenSize.height/tileWidth)
        }
    }
   
    // var bottomEdgeIndexChanged = true
    // var leftEdgeIndexChanged = true
    var bottomEdgeIndexOld:Int = 0
    var leftEdgeIndexOld:Int = 0
    
    var tileWidth:CGFloat = 16
    
    override init() {
        let texture:SKTexture = SKTextureAtlas(named: "Map").textureNamed("Floor155")
        texture.filteringMode = SKTextureFilteringMode.Nearest
        super.init()
        for y in 1...50 {
            var newRow = [SKSpriteNode]()
            for x in 1...50 {
                let node = SKSpriteNode(texture: texture)
                newRow.append(node)
                node.setScale(2)
                node.position = CGPoint(x: x*32, y: y*32)
               // self.addChild(node)
            }
            allNodes.append(newRow)
        }
    }
    
    func update() {
        let absLoc = self.convertPoint(CGPointMake(0, 0), toNode: gameScene) + CGPointMake(tileWidth, tileWidth)
        leftEdgeIndex = Int(ceil(absLoc.x / tileWidth)*(-1))
        bottomEdgeIndex = Int(ceil(absLoc.y / tileWidth)*(-1))
        //topEdgeIndex = bottomEdgeIndex + Int(screenSize.height/tileWidth)
        //rightEdgeIndex = leftEdgeIndex + Int(screenSize.width/tileWidth)
        //print("left edge = \(leftEdgeIndex) | bottom edge = \(bottomEdgeIndex)")
        /////
        if (bottomEdgeIndexOld > bottomEdgeIndex && bottomEdgeIndex > 0) {
            for i in bottomEdgeIndex...bottomEdgeIndexOld {
                for node in allNodes[i] {
                    if (node.parent != nil) {
                    node.removeFromParent()
                    }
                }
            }
        }
        else if (bottomEdgeIndex > bottomEdgeIndexOld && bottomEdgeIndex > 0) {
            for i in bottomEdgeIndexOld...bottomEdgeIndex {
                for node in allNodes[i] {
                    if (node.parent == nil) {
                        self.addChild(node)
                    }
                }
            }
        }
    }
    func isOnScreen(node:SKNode) -> Bool {
        var point = node.convertPoint(node.position, toNode: thisCharacter)
        return (point > CGPointMake(0, 0) && point < CGPointMake(screenSize.height, screenSize.width))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func abs(point:CGPoint) -> CGPoint {
    return CGPointMake(abs(point.x), abs(point.y))
}

func /(right:CGPoint, left: CGFloat) -> CGPoint{
    return CGPointMake(floor(right.x / left), floor(right.y / left))
}