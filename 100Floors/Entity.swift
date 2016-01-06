//
//  Entity.swift
//  100Floors
//
//  Created by Sid Mani on 1/5/16.
//
//

import SpriteKit

class Entity:SKSpriteNode {
    var base_img_fd:SKSpriteNode
    var base_img_rt:SKSpriteNode
    var base_img_lt:SKSpriteNode
    var base_img_bk:SKSpriteNode
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(_base_img_fd:SKSpriteNode, _base_img_bk:SKSpriteNode, _base_img_rt:SKSpriteNode, _base_img_lt:SKSpriteNode)
    {
        base_img_bk = _base_img_bk
        base_img_fd = _base_img_fd
        base_img_lt = _base_img_lt
        base_img_rt = _base_img_rt
    }
    
}

class ThisCharacter: Entity {
    var ID:String
    init(_ID:String)
    {
        ID = _ID
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class OtherCharacter:Entity {
    
}

class Enemy:Entity {
    
}