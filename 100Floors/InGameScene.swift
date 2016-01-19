//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import SpriteKit
var nonSelfNodes:SKNode?
class InGameScene: SKScene {
    
    var otherPlayers = SKNode()
    var enemies = SKNode()
    var selfNodes = SKNode()
    
    
    override func didMoveToView(view: SKView) {
        nonSelfNodes = SKNode()
        currentMap = Map(mapName: "Map1") //load map
        nonSelfNodes!.addChild(currentMap!)
        nonSelfNodes!.addChild(otherPlayers)
        nonSelfNodes!.addChild(enemies)
        nonSelfNodes!.physicsBody = SKPhysicsBody()
        nonSelfNodes!.physicsBody!.affectedByGravity = false
        nonSelfNodes!.physicsBody!.friction = 0
        //////////////////////////////////////////
        thisCharacter.absoluteLoc = CGPoint(x: 0, y: 0)
        selfNodes.addChild(thisCharacter.node!)
        //////////////////////////////////////////
        addChild(nonSelfNodes!)
        addChild(selfNodes)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    func setMap(newMap:Map)
    {
        
    }
    override func update(currentTime: CFTimeInterval) {
        //cull unnecessary tiles
        let mapLoc = currentMap!.indexForPoint(nonSelfNodes!.position)
        let newLoc = mapCenterLoc-mapLoc
        currentMap!.cullAroundIndexX(Int(newLoc.x), indexY: Int(newLoc.y), columnWidth: mapTilesWidth+4, rowHeight: mapTilesHeight+3)
        //////////////
        nonSelfNodes!.physicsBody!.velocity = ~thisCharacter.velocity!
        //////////////
        if (RightJoystick!.currentPoint != CGPoint(x: 0, y: 0))
        {
            thisCharacter.fireProjectile()
        }
    }
}
