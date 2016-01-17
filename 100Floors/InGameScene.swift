//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import SpriteKit

class InGameScene: SKScene {
    
    var tileMap = SKATiledMap(mapName: "Map1") //load map
    var otherPlayers:SKNode = SKNode()
    var enemies:SKNode = SKNode()
    var nonSelfNodes = SKNode()
    var selfNodes = SKNode()
    
    
    override func didMoveToView(view: SKView) {
        nonSelfNodes.addChild(tileMap)
        nonSelfNodes.addChild(otherPlayers)
        nonSelfNodes.addChild(enemies)
        nonSelfNodes.position = CGPoint(x: 0, y: 0)
        nonSelfNodes.physicsBody = SKPhysicsBody()
        nonSelfNodes.physicsBody!.affectedByGravity = false
        nonSelfNodes.physicsBody!.friction = 0
        //////////////////////////////////////////
        selfNodes.addChild(thisCharacter.node!)
        addChild(nonSelfNodes)
        addChild(selfNodes)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        let mapLoc = tileMap.indexForPoint(nonSelfNodes.position)
        let newLoc = mapCenterLoc-mapLoc
        tileMap.cullAroundIndexX(Int(newLoc.x), indexY: Int(newLoc.y), columnWidth: mapTileWidth+2, rowHeight: mapTilesHeight+3)
        nonSelfNodes.physicsBody!.velocity = CGVector(dx: -5*LeftJoystick!.dx, dy: 5*LeftJoystick!.dy)
    }
}
