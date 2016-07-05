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

}

class RunSequentially:Behavior {
    
}

class SetTextureTo:Behavior {
    
}

class RunAnimationSequence:Behavior {
    private let animationName:String
    private let frameDuration:Double
    
    init(animationName:String, frameDuration:Double = 0.125, priority:Int = 5) {
        self.animationName = animationName
        self.frameDuration = frameDuration
        super.init(idType: .Animation, updateRate: 200)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return parent.condition?.conditionType != .Stuck
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        if (!parent.isCurrentlyAnimating()) {
            parent.setCurrentTextures(animationName)
            parent.runAnimation(frameDuration)
        }
    }
}


