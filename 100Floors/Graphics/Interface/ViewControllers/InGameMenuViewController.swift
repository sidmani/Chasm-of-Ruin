//
//  InGameMenuViewController.swift
//  100Floors
//
//  Created by Sid Mani on 2/28/16.
//
//
import UIKit

class InGameMenuViewController: UIViewController {
    
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrencyLabels()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade", object: nil)
        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blur)
        UIView.animateWithDuration(0.5) {
            blur.effect = UIBlurEffect(style: .Light)
        }
        self.view.sendSubviewToBack(blur)
        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))

    }

    @IBAction func levelSelectPressed(sender: AnyObject) {
        let alert = storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
        alert.text = "Are you sure? All level progress will be lost..."
        alert.completion = {(response) in
            if (response) {
                self.performSegueWithIdentifier("unwindToLevelSelect", sender: self)
            }
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func presentStore() {
        let svc = storyboard!.instantiateViewControllerWithIdentifier("storeViewController") as! StoreViewController
        presentViewController(svc, animated: true, completion: nil)
    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
    
    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC")
        self.presentViewController(cpvc, animated: true, completion: nil)
    }
}