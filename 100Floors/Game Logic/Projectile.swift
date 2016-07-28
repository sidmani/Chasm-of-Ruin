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
    private let spd:CGFloat
    private var distanceTraveled:CGFloat = 0
    private var reflects:Bool
    var statusCondition:(condition:StatusCondition,probability:CGFloat)?

    init (fromTexture:SKTexture, fromPoint:CGPoint, withVelocity:CGVector, withAngle:CGFloat, isFriendly:Bool, withRange:CGFloat, withAtk: CGFloat, reflects:Bool = false, statusInflicted:(StatusCondition, CGFloat)? = nil) {
        let size = fromTexture.size()
        fromTexture.filteringMode = .Nearest
        self.range = withRange
        self.attack = withAtk
        self.spd = abs(hypot(withVelocity.dx, withVelocity.dy))
        self.reflects = reflects
        self.statusCondition = statusInflicted
        super.init(texture: fromTexture, color: UIColor.clearColor(), size: size)
        
        self.zRotation = withAngle - CGFloat(M_PI_4)
        self.physicsBody = SKPhysicsBody(circleOfRadius: 2)
        self.physicsBody?.friction = 0
        self.physicsBody?.velocity = withVelocity
        self.position = fromPoint
        self.setScale(0.5)
        if (isFriendly) {
            self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.FriendlyProjectile
        }
        else {
            self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.EnemyProjectile
        }

        if (reflects) {
            self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.MapBoundary
            self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
            self.physicsBody?.restitution = 1.0
        }
        else {
            self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.MapBoundary
            self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.None
            self.physicsBody?.restitution = 0
        }
        self.zPosition = MapLevel.LayerDef.Projectiles
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var hasChangedOrientation = false
    func struckMapBoundary() {
        //do some kind of animation
        if (reflects) {
            hasChangedOrientation = false
            self.hidden = true
        }
        else {
            removeFromParent()
        }
    }
    
    func update(deltaT:Double) {
        distanceTraveled += CGFloat(deltaT/1000) * spd
       // self.zPosition = MapLevel.LayerDef.Projectiles - 0.0001 * (self.position.y - self.frame.height/2)
        self.zPosition = MapLevel.LayerDef.Entity - 0.0001 * (self.position.y)
        if (reflects && !hasChangedOrientation) {
            self.zRotation = atan2(self.physicsBody!.velocity.dy, self.physicsBody!.velocity.dx) - CGFloat(M_PI_4)
            hasChangedOrientation = true
            hidden = false
        }
        if (distanceTraveled > range) {
            removeFromParent()
        }
    }
    
}
