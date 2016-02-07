//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile:SKSpriteNode{
    //var ID:Int
    
    private var distanceTraveled:CGFloat {
        get{
            return hypot(self.position.x - startLoc.x, self.position.y - startLoc.y)
        }
    }
    private var friendly: Bool
    private var relVelocity: CGVector
    private var range: CGFloat
    private var startLoc: CGPoint
        {
        didSet{
            self.position = startLoc
        }
    }
    
    init (definition:ProjectileDefinition, fromPoint:CGPoint, withVelocity:CGVector, isFriendly:Bool) {
        let texture = SKTextureAtlas(named: "Projectiles").textureNamed(definition.imgMain)
        let size = texture.size()
        relVelocity = withVelocity
        range = definition.range
        startLoc = fromPoint
        friendly = isFriendly
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5.0) //TODO: create from texture
        self.physicsBody!.friction = 0
        self.physicsBody!.velocity = withVelocity
        self.physicsBody!.affectedByGravity = false
        
        if (friendly) {
        self.physicsBody!.categoryBitMask = friendlyProjectileMask
        }
        else {
        self.physicsBody!.categoryBitMask = enemyProjectileMask
        }
        
        self.physicsBody!.contactTestBitMask = 0x0 << 0
        self.physicsBody!.collisionBitMask = 0x0 << 0
        self.position = startLoc
        self.zPosition = 4 //TODO: standardize layering
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///update functions
    private func rangeCheck() -> Bool {
        if (self.distanceTraveled > self.range) {
            self.removeFromParent()
            return true
        }
        else {
        return false
        }
    }
    func update(velocityChanged:Bool, newVelocity:CGVector) {
        if (!rangeCheck() && velocityChanged) {
        updateVelocity(newVelocity)
        }
    }
    private func updateVelocity(newVelocity:CGVector) {
        self.physicsBody!.velocity = self.relVelocity + newVelocity
    }
}
