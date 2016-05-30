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
    
    @IBOutlet weak var MenuButton: UIButton!
    @IBOutlet weak var InventoryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup UI components
        UIElements.LeftJoystick = LeftJoystickControl
        UIElements.RightJoystick = RightJoystickControl
        UIElements.HPBar = HPDisplayBar
        UIElements.MenuButton = MenuButton
        UIElements.InventoryButton = InventoryButton
        //////////
        GameLogic.setViewController(self)
        self.view.backgroundColor = UIColor.clearColor()
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.ignoresSiblingOrder = true
        let gameScene = InGameScene(size:skView.bounds.size)
        gameScene.scaleMode = .AspectFill
        gameScene.view?.window?.rootViewController = self
        skView.presentScene(gameScene)
    }
    
    @IBAction func menuButtonPressed(sender: UIButton) {
        blurView()
        GameLogic.setGameState(.InGameMenu)
    }
 
    @IBAction func inventoryButtonPressed(sender: UIButton?) {
        loadInventoryView(thisCharacter.inventory, dropLoc: thisCharacter.position, groundBag:GameLogic.nearestGroundBag())
    }
    
    func loadInventoryView(inv:Inventory, dropLoc:CGPoint, groundBag:ItemBag?) {
        blurView()
        GameLogic.setGameState(.InventoryMenu)
        let inventoryController = storyboard?.instantiateViewControllerWithIdentifier("inventoryView") as! InventoryViewController
        inventoryController.inventory = inv
        inventoryController.groundBag = groundBag
        inventoryController.dropLoc = dropLoc
        inventoryController.modalTransitionStyle = .CoverVertical
        presentViewController(inventoryController, animated: true, completion: nil)
    }
    
    @IBAction func exitMenu(segue: UIStoryboardSegue) {
        GameLogic.setGameState(.InGame)
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