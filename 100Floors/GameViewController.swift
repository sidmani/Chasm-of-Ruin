//
//  GameViewController.swift
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = view as! SKView
        scene = GameScene()
        skView.presentScene(scene)
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
    // MARK: Actions
    
    @IBAction func joinButton(sender: UIButton) {
        print("Button pressed")
    }
   
}
