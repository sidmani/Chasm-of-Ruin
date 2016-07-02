//
//  Behavior.swift
//  Chasm of Ruin
//
//  Created by Sid Mani on 3/19/16.
//
//

import Foundation
import UIKit


class Behavior: Updatable {
    enum BehaviorIDType {
        case Movement, Attack, Animation, Nonexclusive
    }
    
    var idType:BehaviorIDType
    private var timeSinceUpdate:Double = 0
    private let updateRate:Double
    
    var priority:Int = 0
    
    unowned var parent:Enemy
    
    
    init(parent:Enemy, idType:BehaviorIDType, updateRate:Double) {
        self.parent = parent
        self.idType = idType
        self.updateRate = updateRate
    }
    
    final func update(deltaT: Double) {
        if (timeSinceUpdate >= updateRate) {
            executeBehavior(timeSinceUpdate)
            timeSinceUpdate = 0
        }
        else {
            timeSinceUpdate += deltaT
        }
    }
    
   // func updatePriority() {
        
  //  }
    
    
    func getConditional() -> Bool {
        return false
    }
    
    internal func executeBehavior(timeSinceUpdate:Double) {
        
    }
}

