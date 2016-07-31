//
//  MenuScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//
// This can probably be used for animations in the menu
import SpriteKit
import AVFoundation


class MenuScene: SKScene {
    private var oldTime:Double = 0
    var touchLocation:CGPoint?
    override func didMoveToView(view: SKView) {
        //add random display enemies
        //add map
        self.physicsWorld.gravity = CGVector.zero
        let map = SKATiledMap(mapName: "Menu")
        map.setScale(screenSize.width/160)
        map.spriteLayers[2].zPosition = 10
        map.spriteLayers[3].zPosition = 11
        self.addChild(map)
        self.addChild(DisplaySpawner(enemyImageName: "BrainD", numFrames: 12, maxNumEnemies: 1))
        self.addChild(DisplaySpawner(enemyImageName: "BugA", numFrames: 15, maxNumEnemies: 2))
        self.addChild(DisplaySpawner(enemyImageName: "SlimeSquareA", numFrames: 5, maxNumEnemies: 2))
        self.addChild(DisplaySpawner(enemyImageName: "SlimeSquareB", numFrames: 5, maxNumEnemies: 2))
        self.addChild(DisplaySpawner(enemyImageName: "ButterflyA", numFrames: 10, maxNumEnemies: 2))
        self.addChild(DisplaySpawner(enemyImageName: "ButterflyB", numFrames: 10, maxNumEnemies: 2))
        SKTextureAtlas.preloadTextureAtlases([SKTextureAtlas(named:"ExplodeA")], withCompletionHandler: {})
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if let touchedNode = self.nodeAtPoint(touch.locationInNode(self)) as? DisplayEnemy {
                touchedNode.runEffect("ExplodeA") { [unowned touchedNode] in
                    touchedNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.25)) { [unowned touchedNode] in
                        touchedNode.die()
                    }
                }
            }
            else {
                touchLocation = touch.locationInNode(self)
            }
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            touchLocation = touch.locationInNode(self)
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = nil
    }
    
    override func update(currentTime: CFTimeInterval) {
        let deltaT = (currentTime-oldTime)*1000
        oldTime = currentTime
        for child in children {
            (child as? Updatable)?.update(deltaT)
        }
    }
}
