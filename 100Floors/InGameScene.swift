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

        addChild(tileMap)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        tileMap.cullAroundIndexX(0, indexY: 0, columnWidth: 40, rowHeight: 20)
    }
}
