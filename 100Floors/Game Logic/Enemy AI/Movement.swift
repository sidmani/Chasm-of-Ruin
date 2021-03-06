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
        super.init(idType:.movement, updateRate: 100)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        let dist = parent.distanceToCharacter()
        return dist < triggerDistance && dist > distanceToMaintain
    }
    
    override func executeBehavior(_ timeSinceUpdate:Double) {
        
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
    private var nextLoc:CGPoint = CGPoint.zero
    private var stateTime:Double = 0
    
    private enum States { case waiting, moving }
    private var currState = States.moving
    
    private let triggerOutsideOf:CGFloat

    init(triggerOutsideOfDistance:CGFloat, priority:Int) {
        self.triggerOutsideOf = triggerOutsideOfDistance
        super.init(idType: .movement, updateRate: 100)
        self.priority = priority
    }
    
    override func setParent(_ to: Enemy) {
        super.setParent(to)
        self.nextLoc = parent.position
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() > triggerOutsideOf
    }
    
    override func executeBehavior(_ timeSinceUpdate:Double) {
        if (currState == .moving) {
            stateTime -= timeSinceUpdate
            if (stateTime <= 0) {
                currState = .waiting
                stateTime = Double(randomBetweenNumbers(200, secondNum: 2000))
                parent.setVelocity(CGVector.zero)
            }
        }
        else {
            stateTime -= timeSinceUpdate
            if (stateTime <= 0) {
                currState = .moving
                stateTime = Double(randomBetweenNumbers(200, secondNum: 2000))
                let randAngle = randomBetweenNumbers(0, secondNum: 6.28)
                parent.setVelocity(CGVector(dx: cos(randAngle), dy: sin(randAngle)))
            }
        }
    }
}

class SmoothWander:Behavior {
    
}

class Circle:Behavior {
    private let triggerInsideOf:CGFloat
    private var direction:CGFloat = 1
    init(triggerInsideOfDistance:CGFloat, priority:Int) {
        self.triggerInsideOf = triggerInsideOfDistance
        super.init(idType: .movement, updateRate: 100)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        direction = -direction
        return parent.distanceToCharacter() < triggerInsideOf
    }
    
    override func executeBehavior(_ timeSinceUpdate: Double) {
        let v = parent.normalVectorToCharacter()
        parent.setVelocity(CGVector(dx: direction * v.dy, dy: -direction * v.dx))
    }
    
    
}

class Flee:Behavior {
    private let finalDist:CGFloat
    
    init(finalDist:CGFloat, priority:Int) {
        self.finalDist = finalDist
        super.init(idType: .movement, updateRate: 200)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() < finalDist
    }
    
    override func executeBehavior(_ timeSinceUpdate: Double) {
        let vect = -1 * parent.normalVectorToCharacter()
        parent.setVelocity(vect)
    }
}

class FleeFromPoint:Behavior {
    private let finalDist:CGFloat
    var point:CGPoint
    init(finalDist:CGFloat, point:CGPoint, priority:Int) {
        self.finalDist = finalDist
        self.point = point
        super.init(idType: .movement, updateRate: 200)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return hypot(parent.position.x - point.x, parent.position.y - point.y) < finalDist
    }
    
    override func executeBehavior(_ timeSinceUpdate: Double) {
        let vect = (-1/hypot(parent.position.x - point.x, parent.position.y - point.y)) * CGVector(dx: parent.position.x - point.x, dy: parent.position.y - point.y)
        parent.setVelocity(vect)
    }
}

class WanderReallyFast:Behavior {
    private var nextLoc:CGPoint = CGPoint.zero
    private var stateTime:Double = 0
    
    private enum States { case waiting, moving }
    private var currState = States.moving
    
    private let triggerOutsideOf:CGFloat
    private let speedMultiplier:CGFloat
    
    init(triggerOutsideOfDistance:CGFloat, speedMultiplier:CGFloat, priority:Int) {
        self.triggerOutsideOf = triggerOutsideOfDistance
        self.speedMultiplier = speedMultiplier
        super.init(idType: .movement, updateRate: 30)
        self.priority = priority
    }
    
    override func setParent(_ to: Enemy) {
        super.setParent(to)
        self.nextLoc = parent.position
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() > triggerOutsideOf
    }
    
    override func executeBehavior(_ timeSinceUpdate:Double) {
        if (currState == .moving) {
            stateTime -= timeSinceUpdate
            if (stateTime <= 0) {
                currState = .waiting
                stateTime = Double(randomBetweenNumbers(750, secondNum: 1500))
                parent.setVelocity(CGVector.zero)
            }
        }
        else {
            stateTime -= timeSinceUpdate
            if (stateTime <= 0) {
                currState = .moving
                stateTime = 60
                let randAngle = randomBetweenNumbers(0, secondNum: 6.28)
                parent.setVelocity(CGVector(dx: speedMultiplier*cos(randAngle), dy: speedMultiplier*sin(randAngle)))
            }
        }
    }
}

//class ReturnToSpawn:Behavior {
//    init(updateRate:Double, priority:Int) {
//        super.init(idType: .Movement, updateRate: updateRate)
//        self.priority = priority
//    }
//    
//    override func getConditional() -> Bool {
//        return true
//    }
//    
//    override func executeBehavior(timeSinceUpdate: Double) {
//        if let spawnLoc = (parent.parentSpawner as? Spawner)?.position {
//            var v = CGVectorMake(spawnLoc.x-parent.position.x, spawnLoc.y-parent.position.y)
//            v.normalize()
//            parent.setVelocity(v)
//        }
//    }
//}


class MoveToTouch:Behavior {
    private let distanceToMaintain:CGFloat
    
    init(distanceToMaintain:CGFloat, priority:Int) {
        self.distanceToMaintain = distanceToMaintain
        super.init(idType:.movement, updateRate: 100)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        if let point = (parent.scene as? MenuScene)?.touchLocation {
            let dist = hypot(point.x - parent.position.x, point.y - parent.position.y)
            return dist > distanceToMaintain
        }
        return false
    }
    
    override func executeBehavior(_ timeSinceUpdate:Double) {
        if let dest = (parent.scene as? MenuScene)?.touchLocation {
            let v = CGVector(dx: dest.x - parent.position.x, dy: dest.y - parent.position.y)
            let dist = hypot(v.dx, v.dy)
            if (dist > distanceToMaintain) {
                parent.setVelocity(1/dist * v)
                
            }
            else if (dist < distanceToMaintain) {
                parent.setVelocity(CGVector.zero)
            }
        }
    }
}





