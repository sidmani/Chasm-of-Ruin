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
    var dismissDelegate:ModalDismissDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blur)
        UIView.animateWithDuration(0.5) {
            blur.effect = UIBlurEffect(style: .Light)
        }
        self.view.sendSubviewToBack(blur)
    }
    
    @IBAction func loadStats(sender: RectButton) {
        let alert = storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
        alert.text = "Game Center integration coming in a future version!"
        alert.yesText = "Gotcha"
        alert.noButton.alpha = 0.3
        alert.noButton.enabled = false
        alert.noText = ""
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func respawn(sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC("victoryRespawn")
        self.dismissViewControllerAnimated(true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
}