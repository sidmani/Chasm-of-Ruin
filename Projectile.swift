//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile:SKSpriteNode{
    var ID:String?
    var distanceTraveled:CGFloat {
        get{
            return hypot(self.position.x - absoluteLoc!.x, self.position.y - absoluteLoc!.y)
        }
    }
    var relVelocity: CGVector?
    var range: CGFloat?
    var absoluteLoc:CGPoint?
        {
        didSet{
            self.position = absoluteLoc!
        }
    }
    init (definition:ProjectileDefinition) {
        let texture = SKTextureAtlas(named: "Projectiles").textureNamed(definition.imgMain)
        let size = texture.size()
        super.init(texture: texture, color: UIColor.clearColor(), size: size)
        //node = SKSpriteNode(texture: SKTextureAtlas(named: "Projectiles").textureNamed(definition.imgMain)) //TODO: create atlases & possibly optimize textures
        self.physicsBody = SKPhysicsBody(circleOfRadius: 5.0) //TODO: create from texture
        self.physicsBody!.friction = 0
        self.physicsBody!.affectedByGravity = false
        range = definition.range
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func launch(fromPoint:CGPoint, withVelocity:CGVector) { //override this for complex projectiles
        absoluteLoc = fromPoint
        relVelocity = withVelocity
        self.physicsBody!.velocity = withVelocity
  //      nonMapNodes.addChild(self)
        
        //TODO: rotate sprite to correct position
    }
    func destroy() {
        
    }
}

class enemyProjectile:Projectile {

}