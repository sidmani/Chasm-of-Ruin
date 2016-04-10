//
//  GameLogic.swift
//  100Floors
//
//  Created by Sid Mani on 1/9/16.
//
//
import Swift
import SpriteKit

enum GameStates {
    case InGame, Paused, MainMenu, InventoryMenu, InGameMenu, LoadingScreen, CutScene
}
protocol Updatable {
    func update(deltaT:Double)
}

protocol Interactive {
    var thumbnailImg:String { get }
 //   var interactText:String { get }
    var autotrigger:Bool { get }
    func trigger()
    func displayPopup(state:Bool)
}

let screenSize = UIScreen.mainScreen().bounds
let screenCenter = CGPoint(x: Int(screenSize.width/2), y: Int(screenSize.height/2))
struct UIElements {
    static var LeftJoystick:JoystickControl!
    static var RightJoystick:JoystickControl!
    static var HPBar:ReallyBigDisplayBar!
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



var thisCharacter:ThisCharacter!

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

class GameLogic {
    private static var currentState:GameStates = .MainMenu
    private static var gameScene: InGameScene!
    private static var gameViewController:InGameViewController?
    private static var currentSave:SaveData?
    
    static var currentInteractiveObjects: [Interactive] = []
    
    static func setupGame(scene: InGameScene) {
        gameScene = scene
        currentState = .InGame
        assert(gameViewController != nil)
        currentSave = NSKeyedUnarchiver.unarchiveObjectWithFile(SaveData.SaveURL.path!) as? SaveData  //load save
        if (currentSave != nil) {
            thisCharacter = ThisCharacter(fromSaveData: currentSave!)
        }
        else {
            thisCharacter = ThisCharacter()
            currentSave = SaveData(fromCharacter: thisCharacter)
        }
        setLevel(MapLevel(withID: BaseLevel.hubID), introScreen: false) //set level to hub
    }
    static func saveGame() -> Bool{
        if (currentSave != nil) {
            let out = NSKeyedArchiver.archiveRootObject(currentSave!, toFile: SaveData.SaveURL.path!)
            print(out)
            return out
        }
        print(false)
        return false
    }
    
    static func setViewController(to:InGameViewController) {
        gameViewController = to
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
            gameScene.paused = true
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
            gameViewController = nil
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
        for node in gameScene.nonCharNodes.children {
            if let nodeToUpdate = node as? Updatable {
                nodeToUpdate.update(deltaT)
            }
        }
    }
    private static func updateUIElements() {
        
    }
    /////////////////////////
    static func addObject(p:SKNode) {
        gameScene.addObject(p)
    }
    
    static func setLevel(l:BaseLevel, introScreen:Bool) {
        if (currentState == .InGame) {
            gameScene.setLevel(l, introScreen: introScreen)
        }
    }
    ///////
    static func characterDeath() {
       // gameScene.paused = true
        //display death screen
        //set level to hub
       // setLevel(MapLevel(withID: BaseLevel.hubID), introScreen: false)
        
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
    static func openInventory(withBag:ItemBag?) {
        gameViewController?.loadInventoryView(thisCharacter.inventory, dropLoc: thisCharacter.position, groundBag: withBag)
    }
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
