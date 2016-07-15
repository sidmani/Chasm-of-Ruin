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
    static var SkillButton:ProgressRectButton!
}

var enemyXML: AEXMLDocument! = nil
var itemXML: AEXMLDocument! = nil

class InGameViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: Properties
    @IBOutlet weak var LeftJoystickControl: JoystickControl!
    @IBOutlet weak var RightJoystickControl: JoystickControl!
    @IBOutlet weak var HPDisplayBar: VerticalProgressView!
    @IBOutlet weak var EXPBar: UIProgressView!
    @IBOutlet weak var SkillButton: ProgressRectButton!
    
    @IBOutlet weak var InfoDisplay: TextDisplay!
    
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!
    
 //   private var gameScene:InGameScene!
    private var gameScene:InGameScene {
        return (view as! SKView).scene as! InGameScene
    }
    
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
        
        HPDisplayBar.setProgress(1, animated: false)

        //MenuButton.tintColor = ColorScheme.strokeColor
        view.viewWithTag(1)?.tintColor = ColorScheme.strokeColor
        //////////
        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))

        //////////
        SkillButton.addTarget(thisCharacter, action: #selector(thisCharacter.useSkill), forControlEvents: .TouchUpInside)

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
        
        skView.presentScene(InGameScene(size:skView.bounds.size))
    }
    
    var hasExecutedTutorial = false
    
    func loadLevel(level:LevelHandler.LevelDefinition) {
        gameScene.setLevel(MapLevel(level:level))
        if (gameScene.isTutorial() && !hasExecutedTutorial) {
            popTip1.shouldDismissOnTapOutside = true
            popTip1.shouldDismissOnTap = true

            popTip1.popoverColor = ColorScheme.fillColor
            popTip1.borderColor = ColorScheme.strokeColor
            popTip1.borderWidth = 2.0
            
            popTip1.actionAnimation = .Float
            popTip1.entranceAnimation = .Scale
            popTip1.exitAnimation = .Scale
            popTip1.dismissHandler = {[unowned self] in
                self.incrementTutorial()
            }
            if let recognizers = popTip1.gestureRecognizers {
                for recognizer in recognizers {
                    recognizer.delegate = self
                }
            }
            
            LeftJoystickControl.userInteractionEnabled = false
            LeftJoystickControl.alpha = 0.3
            RightJoystickControl.userInteractionEnabled = false
            RightJoystickControl.alpha = 0.3
            SkillButton.userInteractionEnabled = false
            SkillButton.alpha = 0.3
            self.view.viewWithTag(7)!.userInteractionEnabled = false
            self.view.viewWithTag(7)!.alpha = 0.3
            self.view.viewWithTag(1)!.userInteractionEnabled = false
            self.view.viewWithTag(1)!.alpha = 0.3
            
            incrementTutorial()
            
        }
    }
    
    var popupNum:Int = -1
    let popTip1 = AMPopTip()

    func incrementTutorial() {
        switch (popupNum) {
        case -1:
            popTip1.showText("Welcome to Chasm of Ruin!", direction: .None, maxWidth: self.view.frame.width-20, inView: self.view, fromFrame: self.view.frame)
        case 0:
            popTip1.showText("This displays your health and experience points.", direction: .Down, maxWidth: 150, inView: self.view, fromFrame: HPDisplayBar.frame)
        case 1:
            popTip1.showText("Chasm Crystals are used to purchase upgrades and items.", direction: .Down, maxWidth: 150, inView: self.view, fromFrame: self.view.viewWithTag(5)!.frame)
        case 2:
            popTip1.showText("Coins are used to purchase items.", direction: .Down, maxWidth: 150, inView: self.view, fromFrame: self.view.viewWithTag(6)!.frame)
            popTip1.dismissHandler = { [unowned self] in
                self.view.viewWithTag(7)!.userInteractionEnabled = true
                self.view.viewWithTag(7)!.alpha = 1
                self.incrementTutorial()
            }
        case 3:
            popTip1.showText("Open your inventory by pressing here.", direction: .Right, maxWidth: 150, inView: self.view, fromFrame: self.view.viewWithTag(7)!.frame)
            popTip1.shouldDismissOnTapOutside = false
            popTip1.shouldDismissOnTap = false
            popTip1.dismissHandler = { [unowned self] in
                self.LeftJoystickControl.userInteractionEnabled = true
                self.LeftJoystickControl.alpha = 1
                self.incrementTutorial()
            }
        case 4:
            popTip1.showText("Use this joystick to move.", direction: .Right, maxWidth: 150, inView: self.view, fromFrame: LeftJoystickControl.frame, duration: 3)
            popTip1.shouldDismissOnTapOutside = true
            popTip1.shouldDismissOnTap = true
            popTip1.dismissHandler = { [unowned self] in
                self.RightJoystickControl.userInteractionEnabled = true
                self.RightJoystickControl.alpha = 1
                self.incrementTutorial()
            }

        case 5:
            popTip1.showText("Use this joystick to attack.", direction: .Left, maxWidth: 150, inView: self.view, fromFrame: RightJoystickControl.frame, duration: 3)
            popTip1.dismissHandler = { [unowned self] in
                self.SkillButton.userInteractionEnabled = true
                self.SkillButton.alpha = 1
                self.incrementTutorial()
            }
        case 6:
            popTip1.showText("Press this button to use your skill.", direction: .Left, maxWidth: 150, inView: self.view, fromFrame: SkillButton.frame)
            popTip1.dismissHandler = { [unowned self] in
                self.incrementTutorial()
            }
        case 7:
            popTip1.showText("The red arrows point to enemies. Go after them!", direction: .None, maxWidth: 150, inView: self.view, fromFrame: self.view.frame)
            popTip1.dismissHandler = { [unowned self] in
                self.view.viewWithTag(1)!.userInteractionEnabled = true
                self.view.viewWithTag(1)!.alpha = 1
                self.incrementTutorial()
            }
        default: hasExecutedTutorial = true
        }
        popupNum += 1
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return !(touch.view is JoystickControl)
    }
    
    func levelEndedDefeat() {
        thisCharacter.reset()
        presentingOtherViewController()
        defaultLevelHandler.levelCompleted(false)
        if (presentedViewController != nil && presentedViewController!.restorationIdentifier != "DefeatViewController") {
            let dvc = self.storyboard!.instantiateViewControllerWithIdentifier("DefeatViewController") as! DefeatViewController
            addChildViewController(dvc)
            presentedViewController!.willMoveToParentViewController(nil)
            transitionFromViewController(self.presentedViewController!, toViewController: dvc, duration: 0.25, options: .TransitionCrossDissolve, animations: {},completion: nil)
        }
        else if (presentedViewController == nil) {
            let dvc = storyboard!.instantiateViewControllerWithIdentifier("DefeatViewController") as! DefeatViewController
            presentViewController(dvc, animated: false, completion: nil)
        }
    }
    
    func levelEndedVictory() {
        thisCharacter.reset()
        presentingOtherViewController()
        defaultLevelHandler.levelCompleted(true)
        if (presentedViewController != nil && presentedViewController!.restorationIdentifier != "VictoryViewController") {
            let vvc = self.storyboard!.instantiateViewControllerWithIdentifier("VictoryViewController") as! VictoryViewController
            addChildViewController(vvc)
            presentedViewController!.willMoveToParentViewController(nil)
            transitionFromViewController(self.presentedViewController!, toViewController: vvc, duration: 0.25, options: .TransitionCrossDissolve, animations: {},completion: nil)
        }
        else if (presentedViewController == nil) {
            let vvc = storyboard!.instantiateViewControllerWithIdentifier("VictoryViewController") as! VictoryViewController
            presentViewController(vvc, animated: false, completion: nil)
        }
    }
    
    
    func setInfoDisplayText(notification:NSNotification) {
        let text = notification.object as! String
        InfoDisplay.setText(text, letterDelay: 1.5/Double(text.characters.count), hideAfter: 1)
    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
    
    @IBAction func menuButtonPressed() {
        presentingOtherViewController()
        let igmvc = storyboard!.instantiateViewControllerWithIdentifier("igmvc")
        self.presentViewController(igmvc, animated: true, completion: nil)
    }
    
    @objc func loadCurrencyPurchaseView() {
        presentingOtherViewController()
        let cpvc = storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC")
        self.presentViewController(cpvc, animated: true, completion: nil)
    }
    
    func groundBagTapped(notification: NSNotification) {
        loadInventoryView(notification.object as? ItemBag)
    }

    @IBAction func inventoryButtonPressed(sender: UIButton?) {
        loadInventoryView(gameScene.currentGroundBag)
    }
    
    func loadInventoryView(groundBag:ItemBag?) {
        presentingOtherViewController()
        let inventoryController = storyboard?.instantiateViewControllerWithIdentifier("inventoryView") as! InventoryViewController
        inventoryController.groundBag = groundBag
        presentViewController(inventoryController, animated: true, completion: nil)
    }
    
    @IBAction func exitMenu(segue: UIStoryboardSegue) {
        returnedFromOtherViewController()
        if (gameScene.currentGroundBag?.parent == nil) { //TODO: check if necessary
            gameScene.currentGroundBag = nil
        }
        if let bag = (segue.sourceViewController as? InventoryViewController)?.groundBag {
            gameScene.addObject(bag)
        }
    }
    
    func returnedFromOtherViewController() {
        self.view.subviews.forEach({(view) in view.hidden = false})
        self.InfoDisplay.hidden = true
        gameScene.paused = false
        LeftJoystickControl.resetControl()
        RightJoystickControl.resetControl()
        popTip1.hide()
    }
    
    func presentingOtherViewController() {
        self.view.subviews.forEach({(view) in view.hidden = true})
        gameScene.paused = true
    }
    
    @IBAction func defeatSelectedRevive(segue:UIStoryboardSegue) {
        thisCharacter.enableCondition(.Invincible, duration:StatusCondition.Invincible.rawValue)
        returnedFromOtherViewController()
    }
    
    @IBAction func defeatSelectedRespawn(segue:UIStoryboardSegue) {
        thisCharacter.confirmDeath()
        gameScene.reloadLevel()
        returnedFromOtherViewController()
    }
    
    @IBAction func victorySelectedRespawn(segue:UIStoryboardSegue) {
     //   thisCharacter.reset()
        gameScene.reloadLevel()
        returnedFromOtherViewController()
    }
}