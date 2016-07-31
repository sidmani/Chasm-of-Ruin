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
//Projectile-based attacks


class FireProjectile:Behavior {
    private let maxError:CGFloat
    private let projectileTexture:SKTexture
    private let projectileSpeed:CGFloat
    private let projectileReflects:Bool
    private let range:CGFloat
    private let statusInflicted: (StatusCondition, CGFloat)?
    
    init(error:CGFloat, rateOfFire:Double, projectileTexture:String, projectileSpeed:CGFloat, projectileReflects:Bool = false, range:CGFloat, priority:Int = 5, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        maxError = error
        self.projectileTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed(projectileTexture)
        self.projectileSpeed = projectileSpeed
        self.projectileReflects = projectileReflects
        self.statusInflicted = statusInflicted
        self.range = range
        super.init(idType: .Nonexclusive, updateRate: rateOfFire)
        self.priority = priority
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() < range
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        let angle = parent.angleToCharacter() + randomBetweenNumbers(-maxError, secondNum: maxError)
        let velocity = projectileSpeed * CGVectorMake(cos(angle), sin(angle))
        parent.fireProjectile(projectileTexture, range: range, reflects: projectileReflects, withVelocity: velocity, status: statusInflicted)
    }
}

class FireNProjectilesAtEqualIntervals:FireProjectile {
    private var angles:[CGFloat] = []
    init(numProjectiles:Int, projectileTexture:String, rateOfFire:Double, projectileSpeed:CGFloat, range:CGFloat, priority:Int = 5, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        let angleBetween = CGFloat(2*M_PI) / CGFloat(numProjectiles)
        for i in 0..<numProjectiles {
            let currAngle = CGFloat(i)*angleBetween+randomBetweenNumbers(0, secondNum: 0.5)
            angles.append(currAngle)
        }
        
        super.init(error: 0, rateOfFire: rateOfFire, projectileTexture: projectileTexture, projectileSpeed: projectileSpeed, range: range, statusInflicted: statusInflicted)
        self.priority = priority
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        for currAngle in angles {
            let angle = currAngle + randomBetweenNumbers(-0.5, secondNum: 0.5)
            parent.fireProjectile(projectileTexture, range: range, withVelocity: projectileSpeed*CGVectorMake(cos(angle), sin(angle)), status: statusInflicted)
        }
    }
}

class FireProjectilesAtAngularRange:FireProjectile {
    private let direction:Direction
    private let numProjectiles:Int
    private var angles:[CGFloat] = []
    enum Direction {
        case TowardPlayer, Random
    }
    init(numProjectiles:Int, angularRange:CGFloat, direction:Direction, projectileTexture:String, rateOfFire:Double, projectileSpeed:CGFloat, range:CGFloat, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        
        if (numProjectiles % 2 == 0) {
            for i in 0..<numProjectiles/2 {
                angles.append(CGFloat(i+1)*CGFloat(M_PI_4/4))
                angles.append(-1 * CGFloat(i+1)*CGFloat(M_PI_4/4))
            }
        }
        else if (numProjectiles == 1){
            angles.append(0)
        }
        else {
            angles.append(0)
            for i in 0..<numProjectiles/2 {
                angles.append(CGFloat(i+1)*CGFloat(M_PI_4/2))
                angles.append(-1 * CGFloat(i+1)*CGFloat(M_PI_4/2))
            }
        }
        self.numProjectiles = numProjectiles
        self.direction = direction
        super.init(error: 0, rateOfFire: rateOfFire, projectileTexture: projectileTexture, projectileSpeed: projectileSpeed, range: range, statusInflicted: statusInflicted)
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        let centerAngle:CGFloat
        if (direction == .Random) {
            centerAngle = randomBetweenNumbers(0, secondNum: 6.28)
        }
        else {
            centerAngle = parent.angleToCharacter()
        }
        for angle in angles {
            //let diff = interprojectileAngle*CGFloat(i)
            //parent.fireProjectile(projectileTexture, range: range, withVelocity: projectileSpeed*CGVectorMake(cos(centerAngle-diff), sin(centerAngle-diff)))
            //parent.fireProjectile(projectileTexture, range: range, withVelocity: projectileSpeed*CGVectorMake(cos(centerAngle+diff), sin(centerAngle+diff)))
            parent.fireProjectile(projectileTexture, range: range, withVelocity: projectileSpeed*CGVectorMake(cos(angle+centerAngle), sin(angle+centerAngle)))
        }
    }

}

class FireProjectilesInSpiral:FireProjectile {
    private let offsetStep:CGFloat
    
    private var angles:[CGFloat] = []
    private var currentOffset:CGFloat = 0
    
    init(numStreams:Int, offsetStep:CGFloat, projectileTexture:String, rateOfFire:Double, projectileSpeed:CGFloat, range:CGFloat, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        self.offsetStep = offsetStep
        super.init(error: 0, rateOfFire: rateOfFire, projectileTexture: projectileTexture, projectileSpeed: projectileSpeed, range: range, statusInflicted: statusInflicted)
        
        let interProjectileAngle = 6.28/CGFloat(numStreams)
        for i in 0..<numStreams {
            angles.append(interProjectileAngle*CGFloat(i))
        }
    }
    
    override func getConditional() -> Bool {
        return parent.distanceToCharacter() < range
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        for i in 0..<angles.count {
            parent.fireProjectile(projectileTexture, range: range, withVelocity: projectileSpeed*CGVectorMake(cos(angles[i]), sin(angles[i])))
            angles[i] += offsetStep
        }
    }

}





class SpawnEnemy:Behavior {

}

class Selfdestruct:Behavior {
    
}




