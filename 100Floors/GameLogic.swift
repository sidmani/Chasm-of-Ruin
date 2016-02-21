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
var saveXML: AEXMLDocument?
class GameLogic {
    static var LeftJoystick:JoystickControl?
    static var RightJoystick:JoystickControl?
    static var HPBar:ReallyBigDisplayBar?
    static var HungerBar:DisplayBar?
    static var InteractButton:UIButton?
    static var InventoryButton:UIButton?
    static var MenuButton:UIButton?
    private static var gameScene: InGameScene?

    static func setup() {
        //setup items/projectiles xml
        var xmlPath = NSBundle.mainBundle().pathForResource("Items", ofType: "xml")
        var data = NSData(contentsOfFile: xmlPath!)!
        
        do {
            itemXML = try AEXMLDocument(xmlData: data)
        }
        catch {
            print("\(error)")
        }
      
        //setup level xml
            xmlPath = NSBundle.mainBundle().pathForResource("Levels", ofType: "xml")!
            data = NSData(contentsOfFile: xmlPath!)!
        do {
            levelXML = try AEXMLDocument(xmlData: data)
        }
        catch {
            print("\(error)")
        }
        
        //load save state xml
        setLevel(Level(_id: "0"))
        
    }
    
    static func doubleTapTrigger(sender:JoystickControl) {
        if (sender == LeftJoystick!) {
            //rage attack
        }
        else {
            //skill attack
        }
    }
    
    ///////UPDATE////////
    static func update() {
        thisCharacter.update()
        let newVelocity = ~thisCharacter.velocity
        gameScene!.nonCharNodes.physicsBody!.velocity = newVelocity
        updateProjectiles(newVelocity, projectileArray: gameScene!.projectiles.children)
        //updateEnemies(LeftJoystick!.valueChanged)
        //updateUIElements()
        //update velocity of everything else

    }
    
    private static func updateUIElements() {
        
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
    static func addMapObject() {
        
    }
    static func setScene(newScene:InGameScene) {
        gameScene = newScene
    }
    static func setLevel(l:Level) {
        gameScene!.setLevel(l)
    }
    
    static func setCharPosition(atPoint:CGPoint) {
        gameScene!.setCharPosition(atPoint)
    }
    static func getPositionOnMap(ofNode:SKNode) -> CGPoint {
        return gameScene!.getPositionOnMap(ofNode)
    }
    static func usePortal(p:Portal) {
        setLevel(Level(_id: p.destinationID))
    }
    static func withinInteractDistance(ofMapObject: MapObject) {
        //switch button from "use set item" to "interact"
        //
    }
    ////Utility////
    static func getThisCharacter() -> ThisCharacter { //TODO: delete this
        // construct character
        let out = ThisCharacter()
        out.equipItem(Item(withID: "wep1"))
        return out
    }
    
}
