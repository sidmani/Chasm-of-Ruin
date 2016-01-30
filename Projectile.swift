//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile:SKSpriteNode{
    //var ID:String?
    
    var distanceTraveled:CGFloat {
        get{
            return hypot(self.position.x - absoluteLoc.x, self.position.y - absoluteLoc.y)
        }
    }
    
    var relVelocity: CGVector
    var range: CGFloat = 50
    var absoluteLoc:CGPoint
        {
        didSet{
            self.position = absoluteLoc
        }
    }
    
    init (definition:ProjectileDefinition, fromPoint:CGPoint, withVelocity:CGVector) {
        let texture = SKTextureAtlas(named: "Projectiles").textureNamed(definition.imgMain)
        let size = texture.size()
        relVelocity = withVelocity
        range = definition.range
        absoluteLoc = fromPoint

        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5.0) //TODO: create from texture
        self.physicsBody!.friction = 0
        self.physicsBody!.velocity = withVelocity
        self.physicsBody!.affectedByGravity = false
        self.physicsBody!.categoryBitMask = friendlyProjectileMask
        self.physicsBody!.contactTestBitMask = 0x0 << 0
        self.physicsBody!.collisionBitMask = 0x0 << 0
        self.position = absoluteLoc
        self.zPosition = 4
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func destroy() { //call when range is exceeded
        
    }
}

class enemyProjectile:Projectile {

}