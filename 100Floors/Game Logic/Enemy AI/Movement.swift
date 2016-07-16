//
//  Movement.swift
//  100Floors
//
//  Created by Sid Mani on 6/16/16.
//
//

import Foundation
import UIKit

extension CGVector {
    mutating func normalize() {
        let len = hypot(self.dx, self.dy)
        if (len == 0) {
            self = CGVector.zero
        }
        self.dx = self.dx/len
        self.dy = self.dy/len
    }
}

/////////////////////////////////
/////////////////////////////////
////////////MOVEMENT/////////////
/////////////////////////////////
/////////////////////////////////


class MaintainDistance:Behavior {
    private let distanceToMaintain:CGFloat
    private let triggerDistance:CGFloat
    
    init(distanceToMaintain:CGFloat, triggerDistance:CGFloat, priority:Int) {
        self.distanceToMaintain = distanceToMaintain
        self.triggerDistance = triggerDistance
        super.init(idType:.Movement, updateRate: 100)
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
            parent.setVelocity(v)
            
        }
        else if (dist < distanceToMaintain) {
            parent.setVelocity(CGVector.zero)
        }
    }
    
}

class Wander:Behavior {
    private var nextLoc:CGPoint = CGPointZero
    private var stateTime:Double = 0
    
    private enum States { case Waiting, Moving }
    private var currState = States.Moving
    
    private let triggerOutsideOf:CGFloat
    private let flipsTexture:Bool
    private let startingFlip:CGFloat
    init(triggerOutsideOfDistance:CGFloat, priority:Int, flipsTexture:Bool = false, startingFlip:CGFloat = 1) {
        self.triggerOutsideOf = triggerOutsideOfDistance
        self.flipsTexture = flipsTexture
        self.startingFlip = startingFlip
        super.init(idType: .Movement, updateRate: 100)
        self.priority = priority
    }
    
    override func setParent(to: Enemy) {
        super.setParent(to)
        self.nextLoc = parent.position
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
                parent.setVelocity(CGVector.zero)
            }
        }
        else {
            stateTime -= timeSinceUpdate
            if (stateTime <= 0) {
                currState = .Moving
                stateTime = Double(randomBetweenNumbers(200, secondNum: 2000))
                let randAngle = randomBetweenNumbers(0, secondNum: 6.28)
                if (randAngle < 1.57 || randAngle > 4.71) {
                    parent.xScale = abs(parent.xScale) * -startingFlip
                }
                else {
                    parent.xScale = abs(parent.xScale) * startingFlip
                }
                parent.setVelocity(CGVectorMake(cos(randAngle), sin(randAngle)))
            }
        }
    }
}

class SmoothWander:Behavior {
    
}

class Circle:Behavior {
    private let triggerInsideOf:CGFloat
    
    init(triggerInsideOfDistance:CGFloat, priority:Int) {
        self.triggerInsideOf = triggerInsideOfDistance
        super.init(idType: .Movement, updateRate: 100)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() < triggerInsideOf
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        let v = parent.normalVectorToCharacter()
        parent.setVelocity(CGVectorMake(-v.dy, v.dx))
    }
    
    
}

class Flee:Behavior {
    private let finalDist:CGFloat
    
    init(finalDist:CGFloat, priority:Int) {
        self.finalDist = finalDist
        super.init(idType: .Movement, updateRate: 200)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() < finalDist
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        parent.setVelocity(-1 * parent.normalVectorToCharacter())
    }
}

class ReturnToSpawn:Behavior {
    init(updateRate:Double, priority:Int) {
        super.init(idType: .Movement, updateRate: updateRate)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return true
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        if let spawnLoc = (parent.parentSpawner as? Spawner)?.position {
            var v = CGVectorMake(spawnLoc.x-parent.position.x, spawnLoc.y-parent.position.y)
            v.normalize()
            parent.setVelocity(v)
        }
    }
}








