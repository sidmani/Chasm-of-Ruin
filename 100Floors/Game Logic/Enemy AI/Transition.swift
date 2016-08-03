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
    private weak var parent:Enemy!
    
    init(dest:String) {
        destinationState = dest
    }
    
    func setParent(_ to:Enemy) {
        parent = to
    }
    
    func evaluate() -> String { //override this
        return ""
    }
}

class HPLessThan:Transition {
    private let hpLevel:CGFloat
    init(dest:String, hpLevel:CGFloat) {
        self.hpLevel = hpLevel
        super.init(dest: dest)
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
    init(dest:String, hpLevel:CGFloat) {
        self.hpLevel = hpLevel
        super.init(dest: dest)
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
    init(dest:String, distance:CGFloat) {
        self.distance = distance
        super.init(dest: dest)
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
    init(dest:String, distance:CGFloat) {
        self.distance = distance
        super.init(dest: dest)
    }
    override func evaluate() -> String {
        if (parent.distanceToCharacter() < distance) {
            return destinationState
        }
        return ""
    }
}


