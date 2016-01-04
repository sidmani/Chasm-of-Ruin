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
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    init(_image:String, _x:Int, _y:Int){
        image = SKSpriteNode(imageNamed: _image)
        x = _x
        y = _y
        super.init(texture:nil, color: UIColor.darkGrayColor(), size: image.size)
        
    }
    func shoot(angle_rads:Float)
    {
        
    }
}
class enemyProjectile:Projectile {

}