//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//

import SpriteKit

class Entity { 
    var absoluteLoc:CGPoint = CGPoint(x: 0, y: 0)
    var screenLoc:CGPoint = CGPoint(x: 0, y: 0)
    var velocity:CGFloat = 0
    var moveAngle:CGFloat = 0
    var ID:String
    
    init(_ID:String)
    {
        ID = _ID
    }
    
}

class ThisCharacter: Entity {
    var thisNode:SKSpriteNode
    var thisCharClass:charClass
    //TODO: stats
    var health:Int = 0
    var magic:Int = 0
    override var moveAngle:CGFloat {
        get {
            return left_joystick_angle
        }
        set {
        }
    }
//  var currentProjectile:Projectile //set based on item, dynamic assigment
    init(_class:charClass, _ID:String) {
        thisCharClass = _class
        thisNode = SKSpriteNode(imageNamed: thisCharClass.img_base)
        super.init(_ID: _ID)
        
    }
    func setScreenLoc(newLoc:CGPoint)
    {
        screenLoc = newLoc
        thisNode.position = newLoc
    }
    func setImageOrientation() {
        // change image direction
    }

}





class OtherCharacter:Entity {
    var thisCharClass:charClass
    init(_class:charClass, _ID:String) {
        thisCharClass = _class
        super.init(_ID: _ID)
    }
}





class Enemy:Entity {
    
}
