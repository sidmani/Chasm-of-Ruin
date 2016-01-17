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
    var otherPlayers = SKNode()
    var enemies = SKNode()
    var nonSelfNodes = SKNode()
    var selfNodes = SKNode()
    
    
    override func didMoveToView(view: SKView) {
        nonSelfNodes.addChild(tileMap)
        nonSelfNodes.addChild(otherPlayers)
        nonSelfNodes.addChild(enemies)
        nonSelfNodes.position = GameLogic.calculateMapPosition()
        nonSelfNodes.physicsBody = SKPhysicsBody()
        nonSelfNodes.physicsBody!.affectedByGravity = false
        nonSelfNodes.physicsBody!.friction = 0
        //////////////////////////////////////////
        selfNodes.addChild(thisCharacter.node!)
       // selfNodes.position = thisCharacter.posData!.screenLoc
        addChild(nonSelfNodes)
        addChild(selfNodes)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        //cull unnecessary tiles
        let mapLoc = tileMap.indexForPoint(nonSelfNodes.position)
        let newLoc = mapCenterLoc-mapLoc
        tileMap.cullAroundIndexX(Int(newLoc.x), indexY: Int(newLoc.y), columnWidth: mapTileWidth+4, rowHeight: mapTilesHeight+3)
        //////////////
        
        nonSelfNodes.physicsBody!.velocity = ~thisCharacter.velocity!
    }
}
