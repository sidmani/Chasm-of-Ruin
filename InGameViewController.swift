//
//  InGameViewController.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import UIKit
import SpriteKit
var hundredFloors = HundredFloors(x: 0,y: 0,clothes: Wearable.Cloak)
class InGameViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var LeftJoystickControl: JoystickControl!
    @IBOutlet weak var RightJoystickControl: JoystickControl!
    
    var scene: InGameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        scene = InGameScene(size:skView.bounds.size)
    
      
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)

    }
    //////////////
    // UI triggers
    //////////////
    @IBAction func RightJoystickControl(sender: JoystickControl) {
        hundredFloors.update_joystick_right(sender.abs_distance, angle: sender.angle)

    }
    
    @IBAction func LeftJoystickControl(sender: JoystickControl) {
        hundredFloors.update_joystick_left(sender.abs_distance, angle: sender.angle)
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