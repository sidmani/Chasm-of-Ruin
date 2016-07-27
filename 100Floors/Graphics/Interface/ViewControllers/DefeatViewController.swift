//
//  DefeatViewController.swift
//  100Floors
//
//  Created by Sid Mani on 6/20/16.
//
//

import Foundation
import UIKit

class DefeatViewController: UIViewController {
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
    
    func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC")
        self.presentViewController(cpvc, animated: true, completion: nil)
    }
    
    @IBAction func respawn(sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC("defeatRespawn")
        self.dismissViewControllerAnimated(true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
    
    @IBAction func revivePressed(sender: AnyObject) {
        let alert = storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
        alert.text = "Revive for 10 Chasm Crystals?"
        alert.completion = {(response) in
            if (response) {
                if (defaultPurchaseHandler.makePurchase("ReviveSelf", withMoneyHandler: defaultMoneyHandler, currency: CurrencyType.ChasmCrystal)) {
                    //self.performSegueWithIdentifier("revive", sender: self)
                    self.dismissDelegate?.willDismissModalVC("Revive")
                    self.dismissViewControllerAnimated(true, completion: {[unowned self] in
                        self.dismissDelegate?.didDismissModalVC(nil)
                    })
                }
                else {
                    let alert = self.storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
                    alert.text = "You don't have enough Crystals for that! Buy some more?"
                    alert.completion = {(response) in
                        if (response) {
                            self.loadCurrencyPurchaseView()
                        }
                    }
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
}