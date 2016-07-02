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
    
    init(parent:Enemy, error:CGFloat, rateOfFire:Double, projectileTexture:String, projectileSpeed:CGFloat, projectileReflects:Bool = false, range:CGFloat, priority:Int = 5, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        maxError = error
        self.projectileTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed(projectileTexture)
        self.projectileSpeed = projectileSpeed
        self.projectileReflects = projectileReflects
        self.statusInflicted = statusInflicted
        self.range = range
        super.init(parent: parent, idType: .Nonexclusive, updateRate: rateOfFire)
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
    private var vectors:[CGVector] = []
  //  private let projectileTexture:SKTexture
  //  private let projectileSpeed:CGFloat
  //  private let statusInflicted:(StatusCondition, CGFloat)?
 //   private let range:CGFloat
    
    init(parent:Enemy, numProjectiles:Int, projectileTexture:String, rateOfFire:Double, projectileSpeed:CGFloat, range:CGFloat, priority:Int = 5, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        let angleBetween = CGFloat(2*M_PI) / CGFloat(numProjectiles)
        for i in 0..<numProjectiles {
            let currAngle = CGFloat(i)*angleBetween
            vectors.append(CGVectorMake(cos(currAngle), sin(currAngle)))
        }
        
      //  self.projectileSpeed = projectileSpeed
      //  self.projectileTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed(projectileTexture)
      //  self.statusInflicted = statusInflicted
      //  self.range = range
      //  super.init(parent: parent, idType: .Nonexclusive, updateRate: rateOfFire)
        super.init(parent: parent, error: 0, rateOfFire: rateOfFire, projectileTexture: projectileTexture, projectileSpeed: projectileSpeed, range: range, statusInflicted: statusInflicted)
      //  self.priority = priority
    }
    
   // override func getConditional() -> Bool {
   //     return parent.distanceToCharacter() < range
   // }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        for vector in vectors {
            parent.fireProjectile(projectileTexture, range: range, withVelocity: projectileSpeed*vector, status: statusInflicted)
        }
    }
}

class FireProjectilesAtAngularRange:FireProjectile {
    private let direction:Direction
    private let interprojectileAngle:CGFloat
    private let numProjectiles:Int
    
    enum Direction {
        case TowardPlayer, Random
    }
    init(parent:Enemy, numProjectiles:Int, angularRange:CGFloat, direction:Direction, projectileTexture:String, rateOfFire:Double, projectileSpeed:CGFloat, range:CGFloat, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        
        self.interprojectileAngle = angularRange / CGFloat(numProjectiles)
        self.numProjectiles = numProjectiles
        self.direction = direction
        super.init(parent: parent, error: 0, rateOfFire: rateOfFire, projectileTexture: projectileTexture, projectileSpeed: projectileSpeed, range: range, statusInflicted: statusInflicted)
    }
    
    override func executeBehavior(timeSinceUpdate: Double) {
        let centerAngle:CGFloat
        if (direction == .Random) {
            centerAngle = randomBetweenNumbers(0, secondNum: 6.28)
        }
        else {
            centerAngle = parent.angleToCharacter()
        }
        for i in 0..<numProjectiles/2 {
            let diff = interprojectileAngle*CGFloat(i)
            parent.fireProjectile(projectileTexture, range: range, withVelocity: projectileSpeed*CGVectorMake(cos(centerAngle-diff), sin(centerAngle-diff)))
            parent.fireProjectile(projectileTexture, range: range, withVelocity: projectileSpeed*CGVectorMake(cos(centerAngle+diff), sin(centerAngle+diff)))
        }
    }

}

class FireProjectilesInSpiral:FireProjectile {
  //  private let projectileTexture:SKTexture
 //   private let projectileSpeed:CGFloat
 //   private let statusInflicted:(StatusCondition, CGFloat)?
 //   private let range:CGFloat
    private let offsetStep:CGFloat
    
    private var angles:[CGFloat] = []
    private var currentOffset:CGFloat = 0
    
    init(parent:Enemy, numStreams:Int, offsetStep:CGFloat, projectileTexture:String, rateOfFire:Double, projectileSpeed:CGFloat, range:CGFloat, statusInflicted:(StatusCondition, CGFloat)? = nil) {
   //     self.projectileTexture = defaultLevelHandler.getCurrentLevelAtlas().textureNamed(projectileTexture)
  //      self.projectileSpeed = projectileSpeed
  //      self.statusInflicted = statusInflicted
  //      self.range = range
        self.offsetStep = offsetStep
        super.init(parent: parent, error: 0, rateOfFire: rateOfFire, projectileTexture: projectileTexture, projectileSpeed: projectileSpeed, range: range, statusInflicted: statusInflicted)
   //     super.init(parent: parent, idType: .Nonexclusive, updateRate: rateOfFire)
        
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




