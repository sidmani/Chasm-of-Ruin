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
    
    override func viewDidLoad() {
        super.viewDidLoad() //superclass init
        ///create UI elements
        let scene = GameScene(size: view.bounds.size)
        let joinButton = UIButton()
        //TODO: Other menu buttons
        ///////
        joinButton.setTitle("Join Game", forState: .Normal)
        joinButton.frame = CGRectMake(100,100,320,44)
        joinButton.center = self.view.center
        joinButton.addTarget(self, action:"joinButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        ///////
        //add UI elements//
        ///////
        self.view.addSubview(joinButton)
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
    }
    func joinButtonPressed(sender:UIButton!)
    {
        print("button pressed")
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
