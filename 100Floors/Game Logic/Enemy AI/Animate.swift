//
//  Animate.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 6/22/16.
//
//

import Foundation
import UIKit

class RunSimultaneously:Behavior {
    let behaviorsToRun:[Behavior]
    let useConditionalOfIndex:Int
    init(behaviorsToRun:[Behavior], useConditionalOfIndex:Int, idType:BehaviorIDType = .nonexclusive, priority:Int = 5) {
        self.behaviorsToRun = behaviorsToRun
        self.useConditionalOfIndex = useConditionalOfIndex
        var updateRate:Double = 10000
        for behavior in behaviorsToRun {
            if (behavior.updateRate < updateRate && behavior.idType != .animation) {
                updateRate = behavior.updateRate
            }
        }
        super.init(idType: idType, updateRate: updateRate)
        self.priority = priority
    }
    
    override func setParent(_ to: Enemy) {
        super.setParent(to)
        for behavior in behaviorsToRun {
            behavior.setParent(to)
        }
    }
    
    override func getConditional() -> Bool {
        return behaviorsToRun[useConditionalOfIndex].getConditional()
    }
    
    override func executeBehavior(_ timeSinceUpdate: Double) {
        for behavior in behaviorsToRun {
            behavior.executeBehavior(timeSinceUpdate)
        }
    }
    
}

class RunAnimationSequence:Behavior {
    private let animationName:String
    private let frameDuration:Double
    
    init(animationName:String, frameDuration:Double = 0.125, priority:Int = 5) {
        self.animationName = animationName
        self.frameDuration = frameDuration
        super.init(idType: .animation, updateRate: 200)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return parent.condition?.conditionType != .stuck
    }
    
    override func executeBehavior(_ timeSinceUpdate: Double) {
        if (!parent.isCurrentlyAnimating()) {
            parent.setCurrentTextures(animationName)
            parent.runAnimation(frameDuration)
        }
    }
}


