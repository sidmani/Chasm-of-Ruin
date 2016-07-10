//
//  InGameViewController.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import UIKit
import SpriteKit

struct UIElements {
    static var LeftJoystick:JoystickControl!
    static var RightJoystick:JoystickControl!
    static var HPBar:VerticalProgressView!
    static var EXPBar:UIProgressView!
  //  static var InventoryButton:UIButton!
   // static var MenuButton:UIButton!
    static var SkillButton:ProgressRectButton!

  /*  static func setVisible(toState:Bool) {
        let _toState = !toState
        LeftJoystick.hidden = _toState
        RightJoystick.hidden = _toState
        HPBar.hidden = _toState
        EXPBar.hidden = _toState
        InventoryButton.hidden = _toState
        MenuButton.hidden = _toState
        SkillButton.hidden = _toState
    }*/
}

var enemyXML: AEXMLDocument! = nil
var itemXML: AEXMLDocument! = nil

class InGameViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var LeftJoystickControl: JoystickControl!
    @IBOutlet weak var RightJoystickControl: JoystickControl!
    
    @IBOutlet weak var HPDisplayBar: VerticalProgressView!
    
    @IBOutlet weak var EXPBar: UIProgressView!
    
    @IBOutlet weak var MenuButton: UIButton!
 //   @IBOutlet weak var InventoryButton: UIButton!
    @IBOutlet weak var SkillButton: ProgressRectButton!
    
    @IBOutlet weak var InfoDisplay: TextDisplay!
    
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!
    
    private var gameScene:InGameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup UI components
        UIElements.LeftJoystick = LeftJoystickControl
        UIElements.RightJoystick = RightJoystickControl
        UIElements.HPBar = HPDisplayBar
        UIElements.SkillButton = SkillButton
        UIElements.EXPBar = EXPBar
        
        InfoDisplay.hidden = true
        setCurrencyLabels()
        
        EXPBar.trackTintColor = ColorScheme.strokeColor
        EXPBar.progressTintColor = ColorScheme.EXPColor

        
        MenuButton.tintColor = ColorScheme.strokeColor
       
        //////////
        //////////
        /////NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(groundBagTapped), name: "groundBagTapped", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setInfoDisplayText), name: "postInfoToDisplay", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(levelEndedDefeat), name: "levelEndedDefeat", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(levelEndedVictory), name: "levelEndedVictory", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade", object: nil)
        /////////////////////////
        self.view.backgroundColor = UIColor.clearColor()
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.ignoresSiblingOrder = true
        SkillButton.addTarget(thisCharacter, action: #selector(thisCharacter.useSkill), forControlEvents: .TouchUpInside)
        gameScene = InGameScene(size:skView.bounds.size)
        skView.presentScene(gameScene)

    }
    
    func loadLevel(level:LevelHandler.LevelDefinition) {
        gameScene.setLevel(MapLevel(level:level))
        UIElements.HPBar.setProgress(1, animated: true)
    }
    
    func levelEndedDefeat() {
        self.view.subviews.forEach({(view) in view.hidden = true})
        blurView()
        gameScene.paused = true
        let dvc = storyboard!.instantiateViewControllerWithIdentifier("DefeatViewController") as! DefeatViewController
        presentViewController(dvc, animated: true, completion: nil)
        defaultLevelHandler.levelCompletedDefeat()
    }
    
    func levelEndedVictory() {
        self.view.subviews.forEach({(view) in view.hidden = true})
        blurView()
        gameScene.paused = true
        let vvc = storyboard!.instantiateViewControllerWithIdentifier("VictoryViewController") as! VictoryViewController
        presentViewController(vvc, animated: true, completion: nil)
        defaultLevelHandler.levelCompleted()
    }
    
    
    func groundBagTapped(notification: NSNotification) {
        loadInventoryView(thisCharacter.inventory, dropLoc: thisCharacter.position, groundBag:notification.object as? ItemBag)
    }
    
    func setInfoDisplayText(notification:NSNotification) {
        let text = notification.object as! String
        InfoDisplay.setText(text, letterDelay: 1.5/Double(text.characters.count), hideAfter: 1)
    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        self.view.subviews.forEach({(view) in view.hidden = true})
        blurView()
        gameScene.paused = true
    }
 
    @IBAction func inventoryButtonPressed(sender: UIButton?) {
        loadInventoryView(thisCharacter.inventory, dropLoc: thisCharacter.position, groundBag:gameScene.currentGroundBag)
    }
    
    func loadInventoryView(inv:Inventory, dropLoc:CGPoint, groundBag:ItemBag?) {
        self.view.subviews.forEach({(view) in view.hidden = true})
        blurView()
        gameScene.paused = true
        let inventoryController = storyboard?.instantiateViewControllerWithIdentifier("inventoryView") as! InventoryViewController
        inventoryController.inventory = inv
        inventoryController.groundBag = groundBag
        inventoryController.dropLoc = dropLoc
        inventoryController.modalTransitionStyle = .CoverVertical
        presentViewController(inventoryController, animated: true, completion: nil)
    }
    
    @IBAction func exitMenu(segue: UIStoryboardSegue) {
        self.view.subviews.forEach({(view) in view.hidden = false})
        self.InfoDisplay.hidden = true
        gameScene.paused = false
        LeftJoystickControl.resetControl()
        RightJoystickControl.resetControl()
        if (gameScene.currentGroundBag?.parent == nil) {
            gameScene.currentGroundBag = nil
        }
        if let bag = (segue.sourceViewController as? InventoryViewController)?.groundBag {
            gameScene.addObject(bag)
        }
        UIView.animateWithDuration(0.5, animations: {
                self.blur?.effect = nil
            },
            completion: {(finished:Bool) in
                self.blur?.removeFromSuperview()
        })
    }
    
    @IBAction func defeatSelectedRevive(segue:UIStoryboardSegue) { 
        thisCharacter.respawn()
        exitMenu(segue)
    }
    
    @IBAction func defeatSelectedRespawn(segue:UIStoryboardSegue) {
        thisCharacter.confirmDeath()
        gameScene.reloadLevel()
        exitMenu(segue)
    }
    
    @IBAction func victorySelectedRespawn(segue:UIStoryboardSegue) {
        gameScene.reloadLevel()
        exitMenu(segue)
    }
    
    private var blur:UIVisualEffectView?
    
    private func blurView() {
        blur = UIVisualEffectView(frame: self.view.bounds)
         blur!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blur!)
        UIView.animateWithDuration(0.5) {
            self.blur!.effect = UIBlurEffect(style: .Light)
        }
    }
   
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
            return .Landscape
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}