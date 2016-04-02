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
protocol Updatable {
    func update(deltaT:Double)
}

protocol Interactive {
    var thumbnailImg:String { get }
    var interactText:String { get }
    var autotrigger:Bool { get }
    func trigger()
    func displayPopup(state:Bool)
}

let screenSize = UIScreen.mainScreen().bounds
let screenCenter = CGPoint(x: Int(screenSize.width/2), y: Int(screenSize.height/2))
struct UIElements {
    static var LeftJoystick:JoystickControl?
    static var RightJoystick:JoystickControl?
    static var HPBar:ReallyBigDisplayBar?
 //   static var InteractButton:UIButton?
    static var InventoryButton:UIButton?
    static var MenuButton:UIButton?
    static func setVisible(toState:Bool) {
        let _toState = !toState
        UIElements.LeftJoystick?.hidden = _toState
        UIElements.RightJoystick?.hidden = _toState
        UIElements.HPBar?.hidden = _toState
 //       UIElements.InteractButton?.hidden = _toState
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

class GameLogic {
    private static var currentState:GameStates = .MainMenu
    private static var gameScene: InGameScene?
    private static var currentViewController:InGameViewController?
    
    static var currentInteractiveObject: Interactive?
    
    static func setupGame(scene: InGameScene) {
        gameScene = scene
        currentState = .InGame
        //load save
        //set level to Hub
        setLevel(MapLevel(withID: "0"), loadScreen: false)
        thisCharacter.inventory.setItem(thisCharacter.inventory.weaponIndex, toItem: Weapon(withID: "wep1"))
        thisCharacter.inventory.setItem(0, toItem: Weapon(withID: "wep2"))
        thisCharacter.inventory.setItem(1, toItem: Weapon(withID: "wep3"))
        gameScene!.nonCharNodes.addChild(Enemy(withID: "0", atPosition: CGPointMake(30,30)))
    }
    
    static func setViewController(to:InGameViewController) {
        currentViewController = to
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
            //UIElements.setVisible(false)
            //gameScene?.paused = true
            gameScene = nil
            break
        default:
            break
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
        gameScene?.addObject(p)
    }
    
    static func setLevel(l:BaseLevel, loadScreen:Bool) {
        if (currentState == .InGame) {
            gameScene?.setLevel(l)
        }
    }
    ///////
    static func timerCallback() {
      //  gameScene?.paused = false
    }
    ///////
    static func usePortal(p:Portal) {
        exitedDistanceOf(currentInteractiveObject)
        setLevel(MapLevel(withID: p.destinationID), loadScreen: p.showLoadScreen)
      //  gameScene?.paused = true
        if (p.showCountdown) {
           // let timer = CountdownTimer(time: 3, endText: "Go!")
            let node = SKLabelNode(text: "test")
            node.zPosition = 20
            node.fontSize = 40
            node.position = screenCenter
            gameScene?.camera?.addChild(node)
         //   timer.startTimer()
        }
    }
    
    ////called by didBeginContact() and didEndContact() in gameScene
    static func enteredDistanceOf(object:Interactive) {
        currentInteractiveObject?.displayPopup(false)
        object.displayPopup(true)
        currentInteractiveObject = object
    }
    
    static func exitedDistanceOf(object:Interactive?) {
        if (currentInteractiveObject != nil && (currentInteractiveObject! as? MapObject) == (object as? MapObject)) {
            currentInteractiveObject?.displayPopup(false)
            currentInteractiveObject = nil
        }
    }
    
    static func openInventory() {
        currentViewController?.inventoryButtonPressed(nil)
        currentViewController?.performSegueWithIdentifier("InGameToInventory", sender: nil)
    }
}

//////////////////
//Global functions
//////////////////
func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left*right.x, y: left*right.y)
}
func *(left: CGFloat, right: CGVector) -> CGVector {
    return CGVector(dx: left*right.dx, dy: left*right.dy)
}
func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}
// test overloads
func print(point:CGPoint)
{
    print("(\(point.x),\(point.y))")
}
