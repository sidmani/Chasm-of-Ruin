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
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blur)
        UIView.animate(withDuration: 0.5) {
            blur.effect = UIBlurEffect(style: .light)
        }
        self.view.sendSubview(toBack: blur)
    }
    
    @IBAction func loadStats(_ sender: RectButton) {
        let alert = storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
        alert.text = "Game Center integration coming in a future version!"
        alert.yesText = "Gotcha"
        alert.noButton.alpha = 0.3
        alert.noButton.isEnabled = false
        alert.noText = ""
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func respawn(_ sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC("victoryRespawn")
        self.dismiss(animated: true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
}
