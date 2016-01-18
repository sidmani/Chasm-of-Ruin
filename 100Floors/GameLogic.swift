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
        // Get data from server
        // construct character
        let out = ThisCharacter(_class: Wizard, _ID: "test")
        out.screenLoc = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        return out
    }
    static func calculateMapPosition() -> CGPoint {
        let mapX = screenSize.width/2 - thisCharacter.absoluteLoc!.x
        let mapY = screenSize.height/2 - thisCharacter.absoluteLoc!.y
        return CGPoint(x: mapX, y: mapY)
    }
    static func calculatePlayerPosition() -> CGPoint {
        
        let point = currentMap!.convertPoint(currentMap!.position, fromNode: thisCharacter.node!)
        print("\(point.x) , \(point.y)")
        return point
    }
    static func getPlayerPosition() -> CGPoint? { //get from server, do some comparison with device
        return nil
    }
}
