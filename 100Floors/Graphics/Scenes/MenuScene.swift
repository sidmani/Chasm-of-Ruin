//
//  MenuScene.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//
// This can probably be used for animations in the menu
import SpriteKit

class MenuScene: SKScene {
    private var oldTime:Double = 0
    override func didMoveToView(view: SKView) {
        //add random display enemies
        //add map
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
    }
   
    override func update(currentTime: CFTimeInterval) {
        let deltaT = (currentTime-oldTime)*1000
        oldTime = currentTime

        for child in children {
            (child as? Updatable)?.update(deltaT)
        }
    }
}
