//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile:SKSpriteNode{    
    private var distanceTraveled:CGFloat {
    
            return hypot(self.position.x - startLoc.x, self.position.y - startLoc.y)
    
    }
    var friendly: Bool
    private var relVelocity: CGVector
    private var range: CGFloat
    private var startLoc: CGPoint
    
    init (withID:String, fromPoint:CGPoint, withVelocity:CGVector, isFriendly:Bool) {
        var thisProjectile:AEXMLElement
        if let projectiles = itemXML!.root["projectiles"]["projectile"].allWithAttributes(["id":withID]) {
            if (projectiles.count != 1) {
                fatalError("Projectile ID error")
            }
            else {
                thisProjectile = projectiles[0]
            }
        }
        else {
            fatalError("Projectile Not Found")
        }
        let texture = SKTextureAtlas(named: "Projectiles").textureNamed(thisProjectile["img"].value!)
        let size = texture.size()
        relVelocity = withVelocity
        range = CGFloat(thisProjectile["range"].doubleValue)
        startLoc = fromPoint
        friendly = isFriendly
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5.0) //TODO: create from texture
        self.physicsBody!.friction = 0
        self.physicsBody!.velocity = withVelocity
        self.physicsBody!.affectedByGravity = false
        
        if (isFriendly) {
        self.physicsBody!.categoryBitMask = friendlyProjectileMask
        }
        else {
        self.physicsBody!.categoryBitMask = enemyProjectileMask
        }
        
        self.physicsBody!.contactTestBitMask = 0x0 << 0
        self.physicsBody!.collisionBitMask = 0x0 << 0
        self.position = startLoc
        self.zPosition = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///update functions
    private func updateVelocity(newVelocity:CGVector) {
        self.physicsBody!.velocity = self.relVelocity + newVelocity
    }
    
    func update(newVelocity:CGVector) {
        if (distanceTraveled > range) {
            self.removeFromParent()
        }
        else {
        updateVelocity(newVelocity)
        }
    }
  
}
