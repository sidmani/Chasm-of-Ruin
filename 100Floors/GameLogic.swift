//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//

import SpriteKit

var thisCharacter = GameLogic.getThisCharacter()
var currentMap:Map?

class GameLogic {
    static func setup() {
        
    }
    static func getThisCharacter() -> ThisCharacter {
        // construct character
        let out = ThisCharacter(_class: Wizard, _ID: "test")
        out.screenLoc = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        out.equipped.weapon = Weapon(definition: Sword)
        return out
    }
    
    static func calculateMapPosition(characterLoc:CGPoint) -> CGPoint { //TODO: fix this (use convertPoint)
        let mapX = screenSize.width/2 - characterLoc.x
        let mapY = screenSize.height/2 - characterLoc.y
        return CGPoint(x: mapX, y: mapY)
    }
    
    static func calculateRelativePosition(node:SKNode) -> CGPoint {
        let point = currentMap!.convertPoint(currentMap!.position, fromNode: node)
        return point
    }
    
    static func getPlayerPosition() -> CGPoint? { 
        return nil
    }
    
}
