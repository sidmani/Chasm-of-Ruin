//
//  InGameScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import SpriteKit

class InGameScene: SKScene {
    override func didMoveToView(view: SKView) {
        var character = SKSpriteNode(imageNamed: hundredFloors.getImageName())
        
        self.addChild(character)
        character.position = CGPoint(x: 100, y: 100)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        
    }
}
