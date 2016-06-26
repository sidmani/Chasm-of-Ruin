//
//  Transition.swift
//  100Floors
//
//  Created by Sid Mani on 6/14/16.
//
//

import Foundation
import UIKit

class Transition {
    private let destinationState:String
    private unowned let parent:Enemy
    
    init(enemy:Enemy, dest:String) {
        parent = enemy
        destinationState = dest
    }
    
    func evaluate() -> String { //override this
        return ""
    }
}

class HPLessThan:Transition {
    private let hpLevel:CGFloat
    init(parent:Enemy, dest:String, hpLevel:CGFloat) {
        self.hpLevel = hpLevel
        super.init(enemy: parent, dest: dest)
    }
    override func evaluate() -> String {
        if (parent.getStats().health < hpLevel*parent.getStats().maxHealth) {
            return destinationState
        }
        return ""
    }
}

class HPMoreThan:Transition {
    private let hpLevel:CGFloat
    init(parent:Enemy, dest:String, hpLevel:CGFloat) {
        self.hpLevel = hpLevel
        super.init(enemy: parent, dest: dest)
    }
    override func evaluate() -> String {
        if (parent.getStats().health > hpLevel*parent.getStats().maxHealth) {
            return destinationState
        }
        return ""
    }
}

class PlayerFartherThan:Transition {
    private let distance:CGFloat
    init(parent:Enemy, dest:String, distance:CGFloat) {
        self.distance = distance
        super.init(enemy: parent, dest: dest)
    }
    override func evaluate() -> String {
        if (parent.distanceToCharacter() > distance) {
            return destinationState
        }
        return ""
    }
}

class PlayerCloserThan:Transition {
    private let distance:CGFloat
    init(parent:Enemy, dest:String, distance:CGFloat) {
        self.distance = distance
        super.init(enemy: parent, dest: dest)
    }
    override func evaluate() -> String {
        if (parent.distanceToCharacter() < distance) {
            return destinationState
        }
        return ""
    }
}


