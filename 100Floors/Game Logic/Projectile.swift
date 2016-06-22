//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile:SKSpriteNode, Updatable{
    let attack: CGFloat
    
    private let range: CGFloat
    private let _speed:CGFloat
    private var distanceTraveled:CGFloat = 0
    var statusCondition:(condition:StatusCondition,probability:CGFloat)?

    init (fromTexture:SKTexture, fromPoint:CGPoint, withVelocity:CGVector, isFriendly:Bool, withRange:CGFloat, withAtk: CGFloat, reflects:Bool, statusInflicted:(StatusCondition, CGFloat)?) {
        let size = fromTexture.size()
        range = withRange
        attack = withAtk
        _speed = abs(hypot(withVelocity.dx, withVelocity.dy))
        
        self.statusCondition = statusInflicted
        super.init(texture: fromTexture, color: UIColor.clearColor(), size: size)
        self.zRotation = atan2(withVelocity.dy, withVelocity.dx) - CGFloat(M_PI_4)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5.0) 
        self.physicsBody?.friction = 0
        self.physicsBody?.velocity = withVelocity
        self.position = fromPoint

        if (isFriendly) {
            self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.FriendlyProjectile
        }
        else {
            self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.EnemyProjectile
        }
        
        if (reflects) {
            self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.None
            self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
            self.physicsBody?.restitution = 1.0
        }
        else {
            self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.MapBoundary
            self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.None
            self.physicsBody?.restitution = 0
        }
        self.zPosition = BaseLevel.LayerDef.Projectiles
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func struckMapBoundary() {
        //do some kind of animation
        removeFromParent()
    }
    
    func update(deltaT:Double) {
        distanceTraveled += CGFloat(deltaT/1000) * _speed
        if (distanceTraveled > range) {
            removeFromParent()
        }
    }
    
}
