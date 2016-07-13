//
//  AlertViewController.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/11/16.
//
//

import Foundation
import UIKit

class AlertViewController: UIViewController {
    @IBOutlet weak var noButton: RectButton!
    @IBOutlet weak var yesButton: RectButton!
    @IBOutlet weak var label: UILabel!
    
    var text:String = ""
    var yesText:String = "Yes"
    var noText:String = "No"
    var completion:(Bool) -> () = {_ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.setTitle(noText, forState: .Normal)
        yesButton.setTitle(yesText, forState: .Normal)
        label.text = text
    }
    
    @IBAction func yesButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.completion(true)
    }
    
    @IBAction func noButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.completion(false)
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