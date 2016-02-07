//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//

import SpriteKit

var thisCharacter = GameLogic.getThisCharacter()
var currentMap:SKATiledMap?
var gameScene: InGameScene!

class GameLogic {
    ////internal methods (can be accessed from any class)////
    static func runGame() {
        //for each level in the game, load level
        //wait for level to be completed
        //go to next level
    }
    static func setScene(newScene:InGameScene) {
        gameScene = newScene
    }
    static func update() {
        thisCharacter.update()
        let newVelocity = ~thisCharacter.velocity!
        gameScene.nonCharNodes.physicsBody!.velocity = newVelocity
        updateProjectiles(LeftJoystick!.valueChanged, newVelocity: newVelocity, projectileArray: gameScene.projectiles.children)
        //updateEnemies(LeftJoystick!.valueChanged)
        //update velocity of everything else
        LeftJoystick!.valueChanged = false

    }
    static func addProjectile(p:Projectile) {
        
    }
    /////private methods//////
    private static func updateNonCharNodes(velocityChanged:Bool) {
        
    }
    
    private static func updateProjectiles(velocityChanged:Bool, newVelocity: CGVector, projectileArray: [SKNode]) {
        for node in projectileArray {
            if let projectile = node as? Projectile {
            projectile.update(velocityChanged, newVelocity: newVelocity)
            }
        }

    }
    private static func updateEnemies(velocityChanged:Bool, enemyArray: [SKNode]) {
        for node in enemyArray {
            if let enemy = node as? Enemy {
                //enemy.update(velocityChanged)
            }
        }
    }
    
    
    ////Utility
    static func getThisCharacter() -> ThisCharacter {
        // construct character
        let out = ThisCharacter(_class: Wizard, _ID: "test", _absoluteLoc: CGPointMake(0,0))
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
        return currentMap!.convertPoint(currentMap!.position, fromNode: node)
    }
    
    static func getPlayerPosition() -> CGPoint? {
        return nil
    }
    
}
