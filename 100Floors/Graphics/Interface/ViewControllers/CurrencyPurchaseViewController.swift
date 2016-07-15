//
//  CurrencyPurchaseViewController.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/12/16.
//
//

import Foundation
import UIKit
import StoreKit
class CurrencyPurchaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate {
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!

 //   private var coinPurchases:[(name:String, price:String)] = []
  //  private var crystalPurchases:[(name:String, price:String)] = []
    private let crystalPurchases = [
        "com.B7F.ChasmOfRuin.100ChasmCrystals"
     //   "com.B7F.ChasmOfRuin.250Crystals",
    //    "com.B7F.ChasmOfRuin.500Crystals"
    ]
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
        
        if (SKPaymentQueue.canMakePayments()) {
            var productID:NSSet = NSSet(object: crystalPurchases[0])
            var productsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        }
        else {
            let alert = storyboard!.instantiateViewControllerWithIdentifier("alertViewController") as! AlertViewController
            alert.text = "You can't make purchases! Check your purchase information..."
            alert.noText = "Back"
            alert.yesText = "OK"
            alert.completion = {(response) in
                if (response) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("received products")
        print("\(response.products.count) products received")
        
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
    
    
    ////////tableview
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
