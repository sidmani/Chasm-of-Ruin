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
    static func setVisible(toState:Bool) {
        let _toState = !toState
        UIElements.LeftJoystick?.hidden = _toState
        UIElements.RightJoystick?.hidden = _toState
        UIElements.HPBar?.hidden = _toState
        UIElements.HungerBar?.hidden = _toState
        UIElements.InteractButton?.hidden = _toState
        UIElements.InventoryButton?.hidden = _toState
        UIElements.MenuButton?.hidden = _toState
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

let enemyXML: AEXMLDocument? = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Enemies", ofType: "xml")!
    let data = NSData(contentsOfFile: xmlPath)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()

let behaviorXML: AEXMLDocument? = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Behaviors", ofType: "xml")!
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
        setLevel(Level(withID: "0")) //this shouldn't be here
        thisCharacter.inventory.setItem(thisCharacter.inventory.weaponIndex, toItem: Item(withID: "wep1"))
        thisCharacter.inventory.setItem(0, toItem: Item(withID: "wep2"))
        thisCharacter.inventory.setItem(1, toItem: Item(withID: "wep3"))
        gameScene!.nonCharNodes.addChild(Enemy(withID: "0", atPosition: CGPointMake(30,30)))
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
    static func update(deltaT:Double) {
        thisCharacter.update(deltaT)
        updateNonCharNodes(deltaT)
        //updateUIElements()

    }
    private static func updateNonCharNodes(deltaT:Double) {
        for node in gameScene!.nonCharNodes.children {
            if let nodeToUpdate = node as? Updatable {
                nodeToUpdate.update(deltaT)
            }
        }
    }
    private static func updateUIElements() {
        
    }
    /////////////////////////
    static func addObject(p:SKNode) {
        if (currentState == .InGame) {
            gameScene?.addObject(p)
        }
    }
    static func setLevel(l:Level) {
        if (currentState == .InGame) {
            gameScene?.setLevel(l)
        }
    }
    ///////
    static func usePortal(p:Portal) {
        setLevel(Level(withID: p.destinationID))
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
