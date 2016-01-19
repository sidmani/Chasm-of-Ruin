//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile {
    var node: SKSpriteNode?
    var ID:String?
    var velocity: CGVector?
        {
            didSet{
                node!.physicsBody!.velocity = velocity!
            }
    }
    var range: CGFloat?
    var absoluteLoc:CGPoint?
    init (definition:ProjectileDefinition) {
        node = SKSpriteNode(texture: SKTextureAtlas(named: "Projectiles").textureNamed(definition.imgMain)) //TODO: create atlases & possibly optimize textures
        node!.physicsBody = SKPhysicsBody(circleOfRadius: 5.0) //TODO: create from texture
        range = definition.range
    }
    func launch(fromPoint:CGPoint, withVelocity:CGVector) { //override this for complex projectiles
        absoluteLoc = fromPoint
        velocity = withVelocity
        //TODO: rotate sprite to correct position
    }
    func destroy() {
        
    }
}

class enemyProjectile:Projectile {

}