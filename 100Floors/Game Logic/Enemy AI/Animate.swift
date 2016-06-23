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
    
    init(parent:Enemy, animationName:String, frameDuration:Double, updateRate:Double, priority:Int) {
        self.animationName = animationName
        self.frameDuration = frameDuration
        super.init(parent: parent, idType: .Animation, updateRate: updateRate)
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


