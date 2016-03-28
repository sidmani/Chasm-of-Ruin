//
//  ModeMenuViewController.swift
//  100Floors
//
//  Created by Sid Mani on 3/28/16.
//
//

import Foundation
import UIKit
import SpriteKit

class ModeMenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func ExploreModeSelected() {
        GameLogic.setMode(.Explore)
    }
    
    @IBAction func SurviveModeSelected() {
        GameLogic.setMode(.Survive)
    }
    
    @IBAction func TutorialModeSelected() {
        GameLogic.setMode(.Tutorial)
    }
}
