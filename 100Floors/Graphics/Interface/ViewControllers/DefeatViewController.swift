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
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (identifier == "revive") {
            if (defaultPurchaseHandler.makePurchase("ReviveSelf", withMoneyHandler: defaultMoneyHandler, currency: CurrencyType.ChasmCrystal)) {
                return true
            }
            else {
                let alert = storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
                alert.text = "You don't have enough Crystals for that! Buy some more?"
                alert.completion = {(response) in
                    if (response) {
                        self.loadCurrencyPurchaseView()
                    }
                }
                self.presentViewController(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
}