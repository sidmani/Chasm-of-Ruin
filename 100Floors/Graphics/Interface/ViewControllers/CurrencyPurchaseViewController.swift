//
//  CurrencyPurchaseViewController.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/12/16.
//
//

import Foundation
import UIKit

class CurrencyPurchaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!

    private var coinPurchases:[(name:String, price:String)] = []
    private var crystalPurchases:[(name:String, price:String)] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrencyLabels()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade", object: nil)

        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blur)
        UIView.animateWithDuration(0.5) {
            blur.effect = UIBlurEffect(style: .Light)
            self.presentingViewController?.view.subviews.forEach({(view) in view.hidden = true})
        }
        self.view.sendSubviewToBack(blur)

    }

    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }

    @IBAction func exit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if (presentingViewController is InGameViewController) {
            (presentingViewController as! InGameViewController).returnedFromOtherViewController()
        }
        else {
            presentingViewController?.view.subviews.forEach({(view) in view.hidden = false})
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            //return # of crystal purchases
            return 3
        }
        else if (section == 1) {
            //return # of coin purchases
            return 3
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("currencyDisplay")!
        cell.backgroundColor = UIColor.clearColor()
        if (indexPath.section == 0) {
            (cell.contentView.viewWithTag(2) as! UIImageView).image = UIImage(named: "ChasmCrystal")
        }
        else if (indexPath.section == 1) {
            (cell.contentView.viewWithTag(2) as! UIImageView).image = UIImage(named: "Coin")
        }
        
        return cell
    }
}
