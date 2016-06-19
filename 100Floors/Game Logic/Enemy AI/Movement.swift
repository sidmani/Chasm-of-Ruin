//
//  Movement.swift
//  100Floors
//
//  Created by Sid Mani on 6/16/16.
//
//

import Foundation
import UIKit

/////////////////////////////////
/////////////////////////////////
////////////MOVEMENT/////////////
/////////////////////////////////
/////////////////////////////////


class MaintainDistance:Behavior {
    private let distanceToMaintain:CGFloat
    private let triggerDistance:CGFloat
    
    init(parent:Enemy, distanceToMaintain:CGFloat, triggerDistance:CGFloat, updateRate:Double, priority:Int) {
        self.distanceToMaintain = distanceToMaintain
        self.triggerDistance = triggerDistance
        super.init(parent:parent, idType:.Movement, updateRate: updateRate)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        let dist = parent.distanceToCharacter()
        return dist < triggerDistance && dist > distanceToMaintain
    }
    
    override func executeBehavior(timeSinceUpdate:Double) {
        
        let v = parent.normalVectorToCharacter()
        let dist = parent.distanceToCharacter()
        if (dist > distanceToMaintain) {
            //parent.physicsBody!.velocity = parent.stats.speed * v
            parent.physicsBody!.velocity = -25 * v
            
        }
        else if (dist < distanceToMaintain) {
            //e.physicsBody!.velocity = -parent.stats.speed * v
            parent.physicsBody!.velocity = 25 * v
            
        }
    }
    
}

class Wander:Behavior {
    private var nextLoc:CGPoint
    private var stateTime:Double = 0
    
    private enum States { case Waiting, Moving }
    private var currState = States.Moving
    
    private var triggerOutsideOf:CGFloat

    init(parent:Enemy, triggerOutsideOfDistance:CGFloat, updateRate:Double, priority:Int) {
        self.triggerOutsideOf = triggerOutsideOfDistance
        self.nextLoc = parent.position
        super.init(parent: parent, idType: .Movement, updateRate: updateRate)
        self.priority = priority
    }
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() > triggerOutsideOf
    }
    override func executeBehavior(timeSinceUpdate:Double) {
        if (currState == .Moving) {
            stateTime -= timeSinceUpdate
            if (stateTime <= 0) {
                currState = .Waiting
                stateTime = Double(randomBetweenNumbers(200, secondNum: 2000))
                parent.physicsBody!.velocity = CGVector.zero
            }
        }
        else {
            stateTime -= timeSinceUpdate
            if (stateTime <= 0) {
                currState = .Moving
                stateTime = Double(randomBetweenNumbers(200, secondNum: 2000))
                //let speed = parent.stats.speed
                let speed:CGFloat = 25
                let randAngle = randomBetweenNumbers(0, secondNum: 6.28)
                parent.physicsBody!.velocity = CGVectorMake(speed*cos(randAngle), speed*sin(randAngle))
            }
        }
    }
}
