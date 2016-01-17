//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import SpriteKit

class InGameScene: SKScene {
     var tileMap = SKATiledMap(mapName: "Map1")
    override func didMoveToView(view: SKView) {
        tileMap.position = CGPoint(x: 0, y: 0)
        tileMap.autoFollowNode = thisCharacter.node
        addChild(tileMap)
        addChild(thisCharacter.node!)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        tileMap.cullAroundIndexX(0, indexY: 0, columnWidth: 40, rowHeight: 20)
        thisCharacter.node!.physicsBody!.velocity = CGVector(dx: left_joystick_dx, dy: (-1)*left_joystick_dy)
    }
}
