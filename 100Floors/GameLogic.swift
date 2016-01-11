//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//

import SpriteKit
var thisCharacter = GameLogic.getThisCharacter()

class GameLogic {
    static func setup() {
        
    }
    static func getThisCharacter() -> ThisCharacter {
        // Get data from server
        // construct character
        let out = ThisCharacter(_class: Wizard, _ID: "test")
        out.setScreenLoc(CGPoint(x: screenSize.width / 2, y: screenSize.height / 2))
        return out
    }
}