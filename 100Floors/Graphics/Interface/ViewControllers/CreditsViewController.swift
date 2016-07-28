//
//  CreditsViewController.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/28/16.
//
//

import Foundation
import UIKit

class CreditsViewController:UIViewController {
    var dismissDelegate:ModalDismissDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blur)
        UIView.animateWithDuration(0.5) {
            blur.effect = UIBlurEffect(style: .Light)
            blur.alpha = 0.5
        }
        self.view.sendSubviewToBack(blur)
    }
    
    @IBAction func exit() {
        dismissDelegate?.willDismissModalVC(nil)
        self.dismissViewControllerAnimated(true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
}