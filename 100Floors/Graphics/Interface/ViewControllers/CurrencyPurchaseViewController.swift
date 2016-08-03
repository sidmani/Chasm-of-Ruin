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
    var dismissDelegate:ModalDismissDelegate?
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
        NotificationCenter.default.addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade" as NSNotification.Name, object: nil)

        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blur)
        UIView.animate(withDuration: 0.5) {
            blur.effect = UIBlurEffect(style: .light)
 //           self.presentingViewController?.view.subviews.forEach({(view) in view.hidden = true})
        }
        self.view.sendSubview(toBack: blur)
        
        if (SKPaymentQueue.canMakePayments()) {
            let productID:NSSet = NSSet(objects: "com.B7F.ChasmOfRuin.100ChasmCrystals")
            let productsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        }
        else {
            let alert = storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
            alert.text = "You can't make purchases! Check your purchase information..."
            alert.noText = "Back"
            alert.yesText = "OK"
            alert.completion = {(response) in
                if (response) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("received products")
        print("\(response.products.count) products received")
    
    }
    
    
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }

    
    @IBAction func exit(_ sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC(nil)
        self.dismiss(animated: true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }
    
    
    ////////tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyDisplay")!
        cell.backgroundColor = UIColor.clear
        if ((indexPath as NSIndexPath).section == 0) {
            (cell.contentView.viewWithTag(2) as! UIImageView).image = UIImage(named: "ChasmCrystal")
        }
        else if ((indexPath as NSIndexPath).section == 1) {
            (cell.contentView.viewWithTag(2) as! UIImageView).image = UIImage(named: "Coin")
        }
        
        return cell
    }
}
