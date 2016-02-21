//
//  InGameViewController.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import UIKit
import SpriteKit

class InGameViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var LeftJoystickControl: JoystickControl!
    @IBOutlet weak var RightJoystickControl: JoystickControl!
    
    @IBOutlet weak var HPDisplayBar: ReallyBigDisplayBar!
    @IBOutlet weak var HungerDisplayBar: DisplayBar!
    
    @IBOutlet weak var MenuButton: UIButton!
    @IBOutlet weak var InventoryButton: UIButton!
    @IBOutlet weak var InteractButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup UI components
        GameLogic.LeftJoystick = LeftJoystickControl
        GameLogic.RightJoystick = RightJoystickControl
        GameLogic.HPBar = HPDisplayBar
        GameLogic.HungerBar = HungerDisplayBar
        GameLogic.MenuButton = MenuButton
        GameLogic.InventoryButton = InventoryButton
        GameLogic.InteractButton = InteractButton
        //////////
        //Joysticks
        //LeftJoystickControl.center = CGPoint(x: 75, y: screenSize.height - 75)
        //LeftJoystickControl.backgroundColor = UIColor.clearColor()
        //RightJoystickControl.center = CGPoint(x: screenSize.width - 75, y: screenSize.height - 75)
        //RightJoystickControl.backgroundColor = UIColor.clearColor()
        
        /////////
        //Status bars
        //HungerDisplayBar.center = CGPoint(x: 100, y: 20)
        //HPDisplayBar.center = CGPoint(x: screenSize.width-200, y: 27)
        //////////
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.ignoresSiblingOrder = true
        let gameScene = InGameScene(size:skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        skView.presentScene(gameScene)
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}