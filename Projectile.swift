//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile:SKSpriteNode, Updatable{
    var friendly: Bool
    var attack:CGFloat
   
    private var range: CGFloat
    private var startLoc: CGPoint
    private var _speed:CGFloat
    private var distanceTraveled:CGFloat = 0
    private var reflects:Bool
    
    init (withID:String, fromPoint:CGPoint, withVelocity:CGVector, isFriendly:Bool, withRange:CGFloat, withAtk: CGFloat, reflects:Bool) {
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
        range = withRange
        startLoc = fromPoint
        friendly = isFriendly
        attack = withAtk
        self.reflects = reflects
        _speed = abs(hypot(withVelocity.dx, withVelocity.dy))
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5.0) //TODO: create from texture
        self.physicsBody?.friction = 0
        self.physicsBody?.velocity = withVelocity
        
        if (isFriendly) {
        self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.FriendlyProjectile
        }
        else {
        self.physicsBody?.categoryBitMask = InGameScene.PhysicsCategory.EnemyProjectile
        }
        
        if (self.reflects) {
        self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.MapBoundary
        self.physicsBody?.restitution = 1.0
        }
        else {
        self.physicsBody?.contactTestBitMask = InGameScene.PhysicsCategory.MapBoundary
        self.physicsBody?.collisionBitMask = InGameScene.PhysicsCategory.None
        self.physicsBody?.restitution = 0
        }
        self.position = startLoc
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
