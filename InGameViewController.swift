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
        UIElements.LeftJoystick = LeftJoystickControl
        UIElements.RightJoystick = RightJoystickControl
        UIElements.HPBar = HPDisplayBar
        UIElements.HungerBar = HungerDisplayBar
        UIElements.MenuButton = MenuButton
        UIElements.InventoryButton = InventoryButton
        UIElements.InteractButton = InteractButton
        //////////
        self.view.backgroundColor = UIColor.clearColor()
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.ignoresSiblingOrder = true
        let gameScene = InGameScene(size:skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        skView.presentScene(gameScene)
    }
    
    @IBAction func interactButtonPressed(sender: UIButton) {
        GameLogic.interactButtonPressed()
    }
    @IBAction func menuButtonPressed(sender: UIButton) {
        blurView()
        GameLogic.setGameState(.InGameMenu)
    }
 
    @IBAction func inventoryButtonPressed(sender: UIButton) {
        blurView()
        GameLogic.setGameState(.InventoryMenu)
    }
    @IBAction func exitMenu(segue: UIStoryboardSegue) {
        
        for view:UIView in self.view.subviews {
            if let effectView = view as? UIVisualEffectView {
                UIView.animateWithDuration(0.5, animations: {
                    effectView.effect = nil
                    },
                    completion: {(finished:Bool) in
                        effectView.removeFromSuperview()
                })
                break
            }
        }
        GameLogic.setGameState(.InGame)
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