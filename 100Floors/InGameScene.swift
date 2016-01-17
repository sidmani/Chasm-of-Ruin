//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import SpriteKit

class InGameScene: SKScene {
     var tileMap = SKATiledMap(mapName: "SampleMapKenny")
    override func didMoveToView(view: SKView) {
        tileMap.position = CGPoint(x: 0, y: 0)
        addChild(tileMap)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        
    }
}
