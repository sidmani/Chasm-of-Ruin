//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile:SKSpriteNode{
    var image: SKSpriteNode
    var x:Int
    var y:Int
    var friendly:Bool
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    init(_image:String, _x:Int, _y:Int, _friendly:Bool){
        image = SKSpriteNode(imageNamed: _image)
        x = _x
        y = _y
        friendly = _friendly
        super.init(texture:nil, color: UIColor.darkGrayColor(), size: image.size)
        self.addChild(image)

        
    }
    func shoot(angle_rads:Float) //override this for complex projectiles
    {
        let action = SKAction.moveByX(CGFloat(200)*CGFloat(cos(angle_rads)), y: CGFloat(200)*CGFloat(sin(angle_rads)), duration: NSTimeInterval(50))
        self.runAction(action)
    }
}

class enemyProjectile:Projectile {

}