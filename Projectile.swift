//
//  Projectile.swift
//  100Floors
//
//  Created by Sid Mani on 1/3/16.
//
//

import SpriteKit
class Projectile{
    var image: SKSpriteNode
    var ID:String
    var velocity: Float
    var angle: Float
    var range: Float
    var absoluteX:Int = 0
    var absoluteY:Int = 0
    
    var screenY:Int = 0 //fix these with dynamic assignment
    var screenX:Int = 0 //replace with CGPoint
    
    init(_image:String, _ID:String, _velocity:Float, _angle:Float, _range:Float){ //maybe pass shoot function as param
        image = SKSpriteNode(imageNamed: _image)
        ID = _ID
        velocity = _velocity
        angle = _angle
        range = _range
    }
    func create() { //override this for complex projectiles
    
        
    }
    func destroy() {
        
    }
}

class enemyProjectile:Projectile {

}