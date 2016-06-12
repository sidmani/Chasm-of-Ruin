//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//
import Swift
import SpriteKit
import UIKit
import Foundation

enum GameStates {
    case InGame, Paused, MainMenu, InventoryMenu, InGameMenu, LoadingScreen, CutScene, LevelSelect
}
protocol Updatable {
    func update(deltaT:Double)
}

protocol Interactive {
    var thumbnailImg:String { get }
    var autotrigger:Bool { get }
    func trigger()
    func displayPopup(state:Bool)
}

let screenSize = UIScreen.mainScreen().bounds
let screenCenter = CGPoint(x: Int(screenSize.width/2), y: Int(screenSize.height/2))

struct UIElements {
    static var LeftJoystick:JoystickControl!
    static var RightJoystick:JoystickControl!
    static var HPBar:VerticalProgressView!
    static var InventoryButton:UIButton!
    static var MenuButton:UIButton!
    
    static func setVisible(toState:Bool) {
        let _toState = !toState
        UIElements.LeftJoystick.hidden = _toState
        UIElements.RightJoystick.hidden = _toState
        UIElements.HPBar.hidden = _toState
        UIElements.InventoryButton.hidden = _toState
        UIElements.MenuButton.hidden = _toState
    }
}




let itemXML: AEXMLDocument! = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Items", ofType: "xml")
    let data = NSData(contentsOfFile: xmlPath!)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()
let levelXML: AEXMLDocument! = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Levels", ofType: "xml")!
    let data = NSData(contentsOfFile: xmlPath)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()

let enemyXML: AEXMLDocument! = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Enemies", ofType: "xml")!
    let data = NSData(contentsOfFile: xmlPath)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()

let behaviorXML: AEXMLDocument! = {() -> AEXMLDocument? in
    let xmlPath = NSBundle.mainBundle().pathForResource("Behaviors", ofType: "xml")!
    let data = NSData(contentsOfFile: xmlPath)!
    do {
        return try AEXMLDocument(xmlData: data)
    }
    catch {
        return nil
    }
    
}()

var thisCharacter:ThisCharacter!

class GameLogic {
    private static var currentState:GameStates = .MainMenu
    private static var gameScene: InGameScene!
    private static var currentSave:SaveData?
    
    private static var currentInteractiveObjects: [Interactive] = []
    

    
    static func setupGame(scene: InGameScene, level:String) {
        gameScene = scene
        currentState = .InGame
      //  assert(gameViewController != nil)
        currentSave = NSKeyedUnarchiver.unarchiveObjectWithFile(SaveData.SaveURL.path!) as? SaveData  //load save
        if (currentSave != nil) {
            thisCharacter = ThisCharacter(fromSaveData: currentSave!)
        }
        else {
            thisCharacter = ThisCharacter()
        }
        scene.paused = true
        setLevel(MapLevel(withID: level), introScreen: true)
    }

    
    static func saveGame() -> Bool{
        //if (currentSave != nil) {
            return NSKeyedArchiver.archiveRootObject(SaveData(fromCharacter: thisCharacter), toFile: SaveData.SaveURL.path!)
        //}
        //return false
    }
    
    static func resetEverything() {
        gameScene = nil
        currentSave = nil
        currentInteractiveObjects = []
        
        thisCharacter = nil
        
        //probably unnecessary, but just in case.
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
            gameScene.paused = false
        case .InGame:
            UIElements.setVisible(true)
            gameScene.paused = false
        case .CutScene:
            UIElements.setVisible(false)
            gameScene.paused = false
        case .InventoryMenu:
            UIElements.setVisible(false)
            gameScene.paused = true
        case .InGameMenu:
            UIElements.setVisible(false)
            gameScene.paused = true
        case .MainMenu:
            gameScene = nil
            break
        default:
            break
        }
    }
 

    /////////////////////////
    static func addObject(p:SKNode) {
        gameScene.addObject(p)
    }
    
    static func setLevel(l:BaseLevel, introScreen:Bool) {
        if (currentState == .InGame) {
            setGameState(.LoadingScreen)
            gameScene.setLevel(l)
            setGameState(.InGame)
        }
    }
    ///////
    static func characterDeath() {
       // gameScene.paused = true
        //display death screen
    }
    ///////
    static func timerCallback() {
      //  gameScene?.paused = false
    }
    ///////
    static func usePortal(p:Portal) {
        currentInteractiveObjects = []
        setLevel(MapLevel(withID: p.destinationID), introScreen: p.showIntroScreen)
      //  gameScene?.paused = true
        if (p.showCountdown) {
           // let timer = CountdownTimer(time: 3, endText: "Go!")
            let node = SKLabelNode(text: "test")
            node.zPosition = 20
            node.fontSize = 40
            node.position = screenCenter
            gameScene.camera?.addChild(node)
         //   timer.startTimer()
        }
    }
    
    ////called by didBeginContact() and didEndContact() in gameScene
    static func enteredDistanceOf(object:Interactive) {
        if (object.autotrigger) { object.trigger() }
        object.displayPopup(true)
        currentInteractiveObjects.append(object)
    }
    
    static func exitedDistanceOf(object:Interactive) {
        if let index = currentInteractiveObjects.indexOf({($0 as! MapObject) == (object as! MapObject)}) {
            object.displayPopup(false)
            currentInteractiveObjects.removeAtIndex(index)
        }
    }
    /////////////
    /////////////
    static func nearestGroundBag() -> ItemBag? {
        for i in 0..<currentInteractiveObjects.count {
            if let bag = currentInteractiveObjects[currentInteractiveObjects.count-i-1] as? ItemBag {
                return bag
            }
        }
        return nil
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
