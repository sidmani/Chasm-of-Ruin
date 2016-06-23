//
//  Attack.swift
//  100Floors
//
//  Created by Sid Mani on 6/21/16.
//
//

import Foundation
import UIKit
/////////////////////////////////
/////////////////////////////////
/////////////ATTACK//////////////
/////////////////////////////////
/////////////////////////////////

class MainAttack:Behavior {
    private let maxError:CGFloat
    private let triggerDistance:CGFloat
    init(parent:Enemy, error:CGFloat, triggerDistance:CGFloat, rateOfFire:Double, priority:Int) {
        maxError = error
        self.triggerDistance = triggerDistance
        super.init(parent: parent, idType: .Attack, updateRate: rateOfFire)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() < triggerDistance
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        let err = randomBetweenNumbers(-maxError, secondNum: maxError)
        parent.fireProjectileAngle(parent.angleToCharacter() + err)
    }
}

class SpawnEnemy:Behavior {

}

class Selfdestruct:Behavior {
    
}

class FireXProjectilesAtAngle:Behavior {
    
}

