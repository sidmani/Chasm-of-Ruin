//
//  Behavior.swift
//  100Floors
//
//  Created by Sid Mani on 3/19/16.
//
//

import Foundation
import UIKit


class Behavior: Updatable {
    enum BehaviorIDType {
        case Movement, Attack
    }
    
    var idType:BehaviorIDType
    private var timeSinceUpdate:Double = 0
    private let updateRate:Double
    
    var priority:Int = 0
    
    var parent:Enemy
    
    
    init(parent:Enemy, idType:BehaviorIDType, updateRate:Double) {
        self.parent = parent
        self.idType = idType
        self.updateRate = updateRate
    }
    
    func update(deltaT: Double) {
        if (timeSinceUpdate >= updateRate) {
            executeBehavior()
            timeSinceUpdate = 0
        }
        else {
            timeSinceUpdate += deltaT
        }
    }
    
    func updatePriority() {
        
    }
    
    
    func getConditional() -> Bool {
        return false
    }
    
    func executeBehavior() {
        
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
    override func executeBehavior() {
        
        let v = parent.normalVectorToCharacter()
        let dist = parent.distanceToCharacter()
        if (dist > distanceToMaintain) {
            //e.physicsBody!.velocity = e.currStats.speed * v
            parent.physicsBody!.velocity = -25 * v
            
        }
        else if (dist < distanceToMaintain) {
            //e.physicsBody!.velocity = -e.currStats.speed * v
            parent.physicsBody!.velocity = 25 * v
            
        }
    }
    
}
