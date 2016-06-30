//
//  VictoryViewController.swift
//  100Floors
//
//  Created by Sid Mani on 6/20/16.
//
//

import Foundation
import UIKit

class VictoryViewController: UIViewController {
    @IBOutlet weak var MenuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MenuButton.tintColor = ColorScheme.strokeColor
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