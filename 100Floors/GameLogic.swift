//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//

import SpriteKit

var thisCharacter = GameLogic.getThisCharacter()
var itemXML: AEXMLDocument?
var levelXML: AEXMLDocument?
class GameLogic {
    static var gameScene: InGameScene?
    ////internal methods (can be accessed from any class)////   
    static var currLevel:Level?
    static func setup() {
        //setup items/projectiles xml
        guard var
            xmlPath = NSBundle.mainBundle().pathForResource("Items", ofType: "xml"),
            data = NSData(contentsOfFile: xmlPath)
            else { print("error")
                return }
        
        do {
            itemXML = try AEXMLDocument(xmlData: data)
        }
        catch {
            print("\(error)")
        }
      
        //setup level xml
            xmlPath = NSBundle.mainBundle().pathForResource("Levels", ofType: "xml")!
            data = NSData(contentsOfFile: xmlPath)!
        do {
            levelXML = try AEXMLDocument(xmlData: data)
        }
        catch {
            print("\(error)")
        }
        
        //load save state xml
        setLevel(Level(_id: "0"))
        
    }
    
    ///////UPDATE////////
    static func update() {
        thisCharacter.update()
        let newVelocity = ~thisCharacter.velocity
        gameScene!.nonCharNodes.physicsBody!.velocity = newVelocity
        updateProjectiles(newVelocity, projectileArray: gameScene!.projectiles.children)
        //updateEnemies(LeftJoystick!.valueChanged)
        //update velocity of everything else

    }
    
    private static func updateProjectiles(newVelocity: CGVector, projectileArray: [SKNode]) {
        for node in projectileArray {
            if let projectile = node as? Projectile {
                projectile.update(newVelocity)
            }
        }
        
    }
    private static func updateEnemies(enemyArray: [SKNode]) {
        for node in enemyArray {
            if let enemy = node as? Enemy {
                //enemy.update(velocityChanged)
            }
        }
    }
    
    /////////////////////////
    /////////////////////////
    static func addProjectile(p:Projectile) {
        gameScene!.addProjectile(p)
    }
    static func setScene(newScene:InGameScene) {
        gameScene = newScene
    }
    static func setLevel(l:Level) {
        thisCharacter.absoluteLoc = tileEdge * l.startLoc
        gameScene!.setLevel(l)
    }
    
    
    ////Utility////
    static func getThisCharacter() -> ThisCharacter { //TODO: delete this
        // construct character
        let out = ThisCharacter(_ID: "test", _absoluteLoc: CGPointMake(0,0))
        out.equipItem(Item(withID: "wep1"))
        return out
    }
    
    static func calculateMapPosition(characterLoc:CGPoint) -> CGPoint { //TODO: use convertPoint
        let mapX = screenSize.width/2 - characterLoc.x
        let mapY = screenSize.height/2 - characterLoc.y
        return CGPoint(x: mapX, y: mapY)
    }
    
    static func calculateRelativePosition(node:SKNode) -> CGPoint {
        return gameScene!.currentMap!.convertPoint(gameScene!.currentMap!.position, fromNode: node)
    }
    
    static func getPlayerPosition() -> CGPoint? {
        return nil
    }
    
}
