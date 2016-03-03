//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//

import SpriteKit
enum GameStates {
    case InGame, Paused, MainMenu, InventoryMenu, InGameMenu, LoadingScreen, CutScene
}
struct UIElements {
    static var LeftJoystick:JoystickControl?
    static var RightJoystick:JoystickControl?
    static var HPBar:ReallyBigDisplayBar?
    static var HungerBar:DisplayBar?
    static var InteractButton:UIButton?
    static var InventoryButton:UIButton?
    static var MenuButton:UIButton?
    static func setVisible(var toState:Bool) {
        toState = !toState
        UIElements.LeftJoystick?.hidden = toState
        UIElements.RightJoystick?.hidden = toState
        UIElements.HPBar?.hidden = toState
        UIElements.HungerBar?.hidden = toState
        UIElements.InteractButton?.hidden = toState
        UIElements.InventoryButton?.hidden = toState
        UIElements.MenuButton?.hidden = toState
    }
}
let thisCharacter = ThisCharacter()
let itemXML: AEXMLDocument? = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Items", ofType: "xml")
    let data = NSData(contentsOfFile: xmlPath!)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()
let levelXML: AEXMLDocument? = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Levels", ofType: "xml")!
    let data = NSData(contentsOfFile: xmlPath)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()

//let saveXML: AEXMLDocument?
class GameLogic {
    private static var currentState:GameStates = .MainMenu
    private static var gameScene: InGameScene?
    private static var currentInteractiveObject: Interactive?
    static func loadSaveState() { //use this instead of setup?
        
    }
    static func setup(withScene: InGameScene) {
        gameScene = withScene
        //TODO: load save state xml
        setLevel(Level(_id: "0")) //this shouldn't be here
        thisCharacter.getInventory().equipItem(Item(withID: "wep1"))
        thisCharacter.getInventory().setItem(0, toItem: Item(withID: "wep2"))
        thisCharacter.getInventory().setItem(1, toItem: Item(withID: "wep3"))

    }
    /////////////
    static func getCurrentState() -> GameStates {
        return currentState
    }
    static func setGameState(toState: GameStates) {
        currentState = toState
        switch(currentState) {
        case .LoadingScreen:
            UIElements.setVisible(false)
            gameScene?.paused = true
        case .InGame:
            UIElements.setVisible(true)
            gameScene?.paused = false
        case .CutScene:
            UIElements.setVisible(false)
            gameScene?.paused = false
        case .InventoryMenu:
            UIElements.setVisible(false)
            gameScene?.paused = true
        case .InGameMenu:
            UIElements.setVisible(false)
            gameScene?.paused = true
        case .MainMenu:
            UIElements.setVisible(false)
            gameScene?.paused = true
        default:
            break;
        }
    }
    /////////////
    //UI Triggers
    static func doubleTapTrigger(sender:JoystickControl) {
        if (currentState == .InGame) {
            if (sender == UIElements.LeftJoystick!) {
            //rage attack
            }
            else {
            //skill attack
            }
        }
    }
    static func interactButtonPressed() {
        if (currentState == .InGame) {
        currentInteractiveObject?.trigger()
        }
    }
    /////////////////////
    ///////UPDATE////////
    static func update() {
        thisCharacter.update()
        let newVelocity = ~thisCharacter.velocity
        gameScene!.nonCharNodes.physicsBody?.velocity = newVelocity
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
    static func addProjectile(p:Projectile) {
        if (currentState == .InGame) {
            gameScene?.addProjectile(p)
        }
    }
    static func setLevel(l:Level) {
        if (currentState == .InGame) {
            gameScene?.setLevel(l)
        }
    }
    ///character position (link to gameScene)
    static func setCharPosition(atPoint:CGPoint) {
        if (currentState == .InGame) {
            gameScene?.setCharPosition(atPoint)
        }
    }
    static func getPositionOnMap(ofNode:SKNode) -> CGPoint {
        if (gameScene != nil) {
            return gameScene!.getPositionOnMap(ofNode)
        }
        else {
            return CGPointZero
        }
    }
    
    ///////
    static func usePortal(p:Portal) {
        setLevel(Level(_id: p.destinationID))
        exitedInteractDistance()
    }
    
    ////called by didBeginContact() and didEndContact() in gameScene
    static func withinInteractDistance(ofObject: Interactive) {
        currentInteractiveObject = ofObject
        if (ofObject.autotrigger) {
            ofObject.trigger()
        }
        else {
            UIElements.InteractButton?.setTitle("Enter", forState: UIControlState.Normal) //TODO: use icons
        }
    }
    static func exitedInteractDistance() {
        currentInteractiveObject = nil
        UIElements.InteractButton?.setTitle("Interact", forState: UIControlState.Normal)
    }
}
