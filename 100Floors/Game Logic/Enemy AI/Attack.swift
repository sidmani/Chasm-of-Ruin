//
//  Attack.swift
//  100Floors
//
//  Created by Sid Mani on 6/21/16.
//
//

import Foundation
import UIKit
import SpriteKit
/////////////////////////////////
/////////////////////////////////
/////////////ATTACK//////////////
/////////////////////////////////
/////////////////////////////////

class MainAttack:Behavior {
    private let maxError:CGFloat
    private let triggerDistance:CGFloat
    private let projectileTexture:SKTexture
    private let projectileSpeed:CGFloat
    private let projectileReflects:Bool
    private let range:CGFloat
    private let statusInflicted: (StatusCondition, CGFloat)?
    
    init(parent:Enemy, error:CGFloat, triggerDistance:CGFloat, rateOfFire:Double, projectileTexture:SKTexture, projectileSpeed:CGFloat, projectileReflects:Bool = false, range:CGFloat, priority:Int, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        maxError = error
        self.triggerDistance = triggerDistance
        self.projectileTexture = projectileTexture
        self.projectileSpeed = projectileSpeed
        self.projectileReflects = projectileReflects
        self.statusInflicted = statusInflicted
        self.range = range
        super.init(parent: parent, idType: .Attack, updateRate: rateOfFire)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() < triggerDistance
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        let angle = parent.angleToCharacter() + randomBetweenNumbers(-maxError, secondNum: maxError)
        let velocity = projectileSpeed * CGVectorMake(cos(angle), sin(angle))
        parent.fireProjectile(projectileTexture, range: range, reflects: projectileReflects, withVelocity: velocity, status: statusInflicted)
    }
}

class SpawnEnemy:Behavior {

}

class Selfdestruct:Behavior {
    
}

class FireXProjectilesAtAngle:Behavior {
    
}

