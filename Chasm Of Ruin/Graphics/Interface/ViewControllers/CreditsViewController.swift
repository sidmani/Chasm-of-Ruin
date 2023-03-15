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
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blur)
        UIView.animate(withDuration: 0.5) {
            blur.effect = UIBlurEffect(style: .light)
        }
        blur.alpha = 0.5
        self.view.sendSubview(toBack: blur)
    }
    
    @IBAction func exit() {
        dismissDelegate?.willDismissModalVC(nil)
        self.dismiss(animated: true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
}
