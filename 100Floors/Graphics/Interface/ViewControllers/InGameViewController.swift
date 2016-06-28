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
    static var InventoryButton:UIButton!
    static var MenuButton:UIButton!
    static var SkillButton:UIButton!
    
    static func setVisible(toState:Bool) {
        let _toState = !toState
        LeftJoystick.hidden = _toState
        RightJoystick.hidden = _toState
        HPBar.hidden = _toState
        InventoryButton.hidden = _toState
        MenuButton.hidden = _toState
        SkillButton.hidden = _toState
    }
}

var enemyXML: AEXMLDocument! = nil
var itemXML: AEXMLDocument! = nil

class InGameViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var LeftJoystickControl: JoystickControl!
    @IBOutlet weak var RightJoystickControl: JoystickControl!
    
    @IBOutlet weak var HPDisplayBar: VerticalProgressView!
    
    @IBOutlet weak var MenuButton: UIButton!
    @IBOutlet weak var InventoryButton: UIButton!
    @IBOutlet weak var SkillButton: RectButton!
    
    @IBOutlet weak var InfoDisplay: TextDisplay!
    
    private var gameScene:InGameScene!
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup UI components
        UIElements.LeftJoystick = LeftJoystickControl
        UIElements.RightJoystick = RightJoystickControl
        UIElements.HPBar = HPDisplayBar
        UIElements.MenuButton = MenuButton
        UIElements.InventoryButton = InventoryButton
        UIElements.SkillButton = SkillButton
        
        InfoDisplay.hidden = true
        
        MenuButton.tintColor = ColorScheme.strokeColor
       
        //////////
      
        //////////
        /////NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(groundBagTapped), name: "groundBagTapped", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setInfoDisplayText), name: "postInfoToDisplay", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(levelEndedDefeat), name: "levelEndedDefeat", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(levelEndedVictory), name: "levelEndedVictory", object: nil)
        
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
        blurView()
        UIElements.setVisible(false)
        gameScene.paused = true
        let dvc = storyboard!.instantiateViewControllerWithIdentifier("DefeatViewController") as! DefeatViewController
        presentViewController(dvc, animated: true, completion: nil)
    }
    
    func levelEndedVictory() {
        blurView()
        UIElements.setVisible(false)
        gameScene.paused = true
        //mark level as completed
        //save stats
    }
    
    
    func groundBagTapped(notification: NSNotification) {
        loadInventoryView(thisCharacter.inventory, dropLoc: thisCharacter.position, groundBag:notification.object as? ItemBag)
    }
    
    func setInfoDisplayText(notification:NSNotification) {
        let text = notification.object as! String
        InfoDisplay.setText(text, letterDelay: 1.5/Double(text.characters.count), hideAfter: 1)
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        blurView()
        UIElements.setVisible(false)
        gameScene.paused = true
    }
 
    @IBAction func inventoryButtonPressed(sender: UIButton?) {
        loadInventoryView(thisCharacter.inventory, dropLoc: thisCharacter.position, groundBag:gameScene.currentGroundBag)
    }
    
    func loadInventoryView(inv:Inventory, dropLoc:CGPoint, groundBag:ItemBag?) {
        blurView()
        UIElements.setVisible(false)
        gameScene.paused = true
        let inventoryController = storyboard?.instantiateViewControllerWithIdentifier("inventoryView") as! InventoryViewController
        inventoryController.inventory = inv
        inventoryController.groundBag = groundBag
        inventoryController.dropLoc = dropLoc
        inventoryController.modalTransitionStyle = .CoverVertical
        presentViewController(inventoryController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func exitMenu(segue: UIStoryboardSegue) {
        gameScene.paused = false
        UIElements.setVisible(true)
        LeftJoystickControl.resetControl()
        RightJoystickControl.resetControl()
        if (gameScene.currentGroundBag?.parent == nil) {
            gameScene.currentGroundBag = nil
        }
        if let bag = (segue.sourceViewController as? InventoryViewController)?.groundBag {
            gameScene.addObject(bag)
        }
        for view:UIView in self.view.subviews {
            if let effectView = view as? UIVisualEffectView {
                UIView.animateWithDuration(0.5, animations: {
                    effectView.effect = nil
                    },
                    completion: {(finished:Bool) in
                        effectView.removeFromSuperview()
                })
                return
            }
        }
    }
    
    private func blurView() {
        let blurEffectView = UIVisualEffectView(frame: self.view.bounds)
         blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blurEffectView)
        UIView.animateWithDuration(0.5) {
            blurEffectView.effect = UIBlurEffect(style: .Light)
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