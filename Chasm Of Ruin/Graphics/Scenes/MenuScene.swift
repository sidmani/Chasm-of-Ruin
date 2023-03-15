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
    override func didMove(to view: SKView) {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if let touchedNode = self.atPoint(touch.location(in: self)) as? DisplayEnemy {
                touchedNode.runEffect("ExplodeA") { [unowned touchedNode] in
                    touchedNode.die()
                }
            }
            else {
                touchLocation = touch.location(in: self)
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchLocation = touch.location(in: self)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaT = (currentTime-oldTime)*1000
        oldTime = currentTime
        for child in children {
            (child as? Updatable)?.update(deltaT)
        }
    }
}
