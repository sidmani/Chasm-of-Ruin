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
    @IBOutlet weak var ManaDisplayBar: DisplayBar!
    @IBOutlet weak var HungerDisplayBar: DisplayBar!
    
    @IBOutlet weak var EquipContainer1: ItemContainer!
    @IBOutlet weak var EquipContainer2: ItemContainer!
    @IBOutlet weak var EquipContainer3: ItemContainer!
    @IBOutlet weak var EquipContainer4: ItemContainer!
    
  //  var scene: InGameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        //setup global UI components
        LeftJoystick = LeftJoystickControl
        RightJoystick = RightJoystickControl
        HPBar = HPDisplayBar
        ManaBar = ManaDisplayBar
        HungerBar = HungerDisplayBar
        Equip1 = EquipContainer1
        Equip2 = EquipContainer2
        Equip3 = EquipContainer3
        Equip4 = EquipContainer4

        //////////
        //Joysticks
        LeftJoystickControl.center = CGPoint(x: 75, y: screenSize.height - 75)
        LeftJoystickControl.backgroundColor = UIColor.clearColor()
        RightJoystickControl.center = CGPoint(x: screenSize.width - 75, y: screenSize.height - 75)
        RightJoystickControl.backgroundColor = UIColor.clearColor()
        
        //////////
     
        //Status bars
     
        HungerDisplayBar.center = CGPoint(x: 100, y: 20)
        ManaDisplayBar.center = CGPoint(x: 100, y: 38)
        HPDisplayBar.center = CGPoint(x: screenSize.width-200, y: 27)
        
        //////////
        //Equipment containers
        EquipContainer1.center = CGPoint(x:200, y: screenSize.height - 75)
        EquipContainer1.backgroundColor = UIColor.clearColor()
        EquipContainer2.center = CGPoint(x:275, y: screenSize.height - 75)
        EquipContainer2.backgroundColor = UIColor.clearColor()
        EquipContainer3.center = CGPoint(x:350, y: screenSize.height - 75)
        EquipContainer3.backgroundColor = UIColor.clearColor()
        EquipContainer4.center = CGPoint(x:425, y: screenSize.height - 75)
        EquipContainer4.backgroundColor = UIColor.clearColor()

        //////////
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.ignoresSiblingOrder = true
        gameScene = InGameScene(size:skView.bounds.size)
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