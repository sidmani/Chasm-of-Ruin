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
    private let parent:Enemy
    
    init(enemy:Enemy, dest:String) {
        parent = enemy
        destinationState = dest
    }
    
    func evaluate() -> String { //override this
        return ""
    }
}

class HPLessThan:Transition {
    private var hpLevel:CGFloat
    init(parent:Enemy, dest:String, hpLevel:CGFloat) {
        self.hpLevel = hpLevel
        super.init(enemy: parent, dest: dest)
    }
    override func evaluate() -> String {
        return ""
    }
}
