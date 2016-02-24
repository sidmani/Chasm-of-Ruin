//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//

import SpriteKit
struct UIElements {
    static var LeftJoystick:JoystickControl?
    static var RightJoystick:JoystickControl?
    static var HPBar:ReallyBigDisplayBar?
    static var HungerBar:DisplayBar?
    static var InteractButton:UIButton?
    static var InventoryButton:UIButton?
    static var MenuButton:UIButton?
}
var thisCharacter = GameLogic.getThisCharacter()
var itemXML: AEXMLDocument?
var levelXML: AEXMLDocument?
var saveXML: AEXMLDocument?
class GameLogic {
    
    private static var gameScene: InGameScene?
    private static var currentInteractiveObject: Interactive?
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
        
        //TODO: load save state xml
        setLevel(Level(_id: "0"))
        
    }
    
    static func doubleTapTrigger(sender:JoystickControl) {
        if (sender == UIElements.LeftJoystick!) {
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
        //updateEnemies(newVelocity, )
        //updateUIElements()

    }
    
    private static func updateUIElements() {
        
    }
    private static func updateMapObjects(mapObjectArray: [SKNode]) {
        for node in mapObjectArray {
            if let mapObject = node as? Updatable {
                mapObject.update()
            }
        }
    }
    private static func updateProjectiles(newVelocity: CGVector, projectileArray: [SKNode]) {
        for node in projectileArray {
            if let projectile = node as? Projectile {
                projectile.update(newVelocity)
            }
        }
        
    }
    private static func updateEnemies(newVelocity: CGVector, enemyArray: [SKNode]) {
        for node in enemyArray {
            if let enemy = node as? Enemy {
                //enemy.update(newVelocity)
            }
        }
    }
    
    /////////////////////////
    static func setScene(newScene:InGameScene) { //called once
        gameScene = newScene
    }

    /////////////////////////
    static func addProjectile(p:Projectile) {
        gameScene!.addProjectile(p)
    }
    static func setLevel(l:Level) {
        gameScene!.setLevel(l)
        currentInteractiveObject = nil
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
    static func withinInteractDistance(ofObject: Interactive) {
        currentInteractiveObject = ofObject
        if (ofObject.autotrigger) {
            ofObject.trigger()
        }
        else {
            UIElements.InteractButton!.setTitle("Enter", forState: UIControlState.Normal) //TODO: use icons
        }
    }
    static func exitedInteractDistance() {
        currentInteractiveObject = nil
        UIElements.InteractButton!.setTitle("Interact", forState: UIControlState.Normal)

    }
    ////Utility////
    static func getThisCharacter() -> ThisCharacter { //TODO: delete this
        // construct character
        let out = ThisCharacter()
        out.equipItem(Item(withID: "wep1"))
        return out
    }
    
}
