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
    
    @IBOutlet weak var HPDisplayBar: DisplayBar!
    @IBOutlet weak var ManaDisplayBar: DisplayBar!
    
    var scene: InGameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Joysticks
        //setup position and color
        LeftJoystickControl.center = CGPoint(x: 75, y: screenSize.height - 75)
        LeftJoystickControl.backgroundColor = UIColor.clearColor()
        RightJoystickControl.center = CGPoint(x: screenSize.width - 75, y: screenSize.height - 75)
        RightJoystickControl.backgroundColor = UIColor.clearColor()
        //////////
        //Status bars
        HPDisplayBar.center = CGPoint(x: 100, y: 20)
        ManaDisplayBar.center = CGPoint(x: 100, y: 38)
        //////////
        let skView = view as! SKView
        scene = InGameScene(size:skView.bounds.size)
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)

    }
    //////////////
    // UI triggers
    //////////////
    @IBAction func RightJoystickControl(sender: JoystickControl) {
        right_joystick_angle = sender.angle
        right_joystick_distance = sender.abs_distance

    }
    
    @IBAction func LeftJoystickControl(sender: JoystickControl) {
        left_joystick_angle = sender.angle
        left_joystick_distance = sender.abs_distance
    }
    /////////
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