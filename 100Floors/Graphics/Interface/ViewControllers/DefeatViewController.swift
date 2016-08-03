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
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blur)
        UIView.animate(withDuration: 0.5) {
            blur.effect = UIBlurEffect(style: .light)
        }
        self.view.sendSubview(toBack: blur)
    }
    
    func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewController(withIdentifier: "currencyPurchaseVC")
        self.present(cpvc, animated: true, completion: nil)
    }
    
    @IBAction func respawn(_ sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC("defeatRespawn")
        self.dismiss(animated: true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
    
    @IBAction func revivePressed(_ sender: AnyObject) {
        let alert = storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
        alert.text = "Revive for 10 Chasm Crystals?"
        alert.completion = {(response) in
            if (response) {
                if (defaultPurchaseHandler.makePurchase("ReviveSelf", withMoneyHandler: defaultMoneyHandler, currency: CurrencyType.chasmCrystal)) {
                    //self.performSegueWithIdentifier("revive", sender: self)
                    self.dismissDelegate?.willDismissModalVC("Revive")
                    self.dismiss(animated: true, completion: {[unowned self] in
                        self.dismissDelegate?.didDismissModalVC(nil)
                    })
                }
                else {
                    let alert = self.storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
                    alert.text = "You don't have enough Crystals for that! Buy some more?"
                    alert.completion = {(response) in
                        if (response) {
                            self.loadCurrencyPurchaseView()
                        }
                    }
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}
