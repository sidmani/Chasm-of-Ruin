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
        case movement, attack, animation, nonexclusive
    }
    
    var idType:BehaviorIDType
    private var timeSinceUpdate:Double = 0
    let updateRate:Double
    
    var priority:Int = 0
    
    weak var parent:Enemy!
    
    
    init(idType:BehaviorIDType, updateRate:Double) {
        self.idType = idType
        self.updateRate = updateRate
    }
    
    func setParent(_ to:Enemy) {
        parent = to
    }
    
    final func update(_ deltaT: Double) {
        if (timeSinceUpdate >= updateRate) {
            executeBehavior(timeSinceUpdate)
            timeSinceUpdate = 0
        }
        else {
            timeSinceUpdate += deltaT
        }
    }
    
    func getConditional() -> Bool {
        return false
    }
    
    func executeBehavior(_ timeSinceUpdate:Double) {
        
    }
}

