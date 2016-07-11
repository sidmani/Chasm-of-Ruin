//
//  AlertViewController.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/11/16.
//
//

import Foundation
import UIKit

protocol AlertHandler {
    var alertCompletion:(Bool) -> () { get }
}

class AlertViewController: UIViewController {
    @IBOutlet weak var noButton: RectButton!
    @IBOutlet weak var yesButton: RectButton!
    @IBOutlet weak var label: UILabel!
    
    var text:String = ""
    var yesText:String = "Yes"
    var noText:String = "No"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.setTitle(noText, forState: .Normal)
        yesButton.setTitle(yesText, forState: .Normal)
        label.text = text
    }
    
    @IBAction func yesButtonPressed() {
        if let pvc = self.presentingViewController as? AlertHandler {
            pvc.alertCompletion(true)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func noButtonPressed() {
        if let pvc = self.presentingViewController as? AlertHandler {
            pvc.alertCompletion(false)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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