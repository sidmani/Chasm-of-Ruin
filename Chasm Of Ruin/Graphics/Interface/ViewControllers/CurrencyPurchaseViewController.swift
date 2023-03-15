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
class CurrencyPurchaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!
    @IBOutlet weak var purchaseTableView: UITableView!
    
    var dismissDelegate:ModalDismissDelegate?
    private let purchases = [
        "com.B7F.ChasmOfRuin.100ChasmCrystals",
        "com.B7F.ChasmOfRuin.250ChasmCrystals",
        "com.B7F.ChasmOfRuin.500ChasmCrystals",
        "com.B7F.ChasmOfRuin.150Coins",
        "com.B7F.ChasmOfRuin.350Coins",
        "com.B7F.ChasmOfRuin.600Coins"
    ]
    
    private var products:[SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrencyLabels()
        NotificationCenter.default.addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade" as NSNotification.Name, object: nil)

        let blur = UIVisualEffectView(frame: self.view.bounds)
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blur)
        UIView.animate(withDuration: 0.5) {
            blur.effect = UIBlurEffect(style: .light)
        }
        self.view.sendSubview(toBack: blur)
        
        if (SKPaymentQueue.canMakePayments()) {
            let productsRequest = SKProductsRequest(productIdentifiers: Set<String>(purchases))
            SKPaymentQueue.default().add(self)
            productsRequest.delegate = self
            productsRequest.start()
        }
        else {
            let alert = storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
            alert.text = "You can't make purchases! Check your purchase information..."
            alert.noButton.isHidden = true
            alert.noButton.isEnabled = false
            alert.yesText = "OK"
            alert.completion = {(response) in
                self.dismiss(animated: true, completion: nil)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("received products")
        print("\(response.products.count) products received")
        self.products = response.products
        products.sort(by: {$0.0.productIdentifier.hasSuffix("ChasmCrystals")})
        for product in products {
            print(product.localizedTitle)
        }
        purchaseTableView.reloadData()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("updated transaction")
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                switch (transaction.payment.productIdentifier) {
                case purchases[0]:
                    defaultMoneyHandler.addCrystals(100)
                case purchases[1]:
                    defaultMoneyHandler.addCrystals(250)
                case purchases[2]:
                    defaultMoneyHandler.addCrystals(500)
                case purchases[3]:
                    defaultMoneyHandler.addCoins(150)
                case purchases[4]:
                    defaultMoneyHandler.addCoins(350)
                case purchases[5]:
                    defaultMoneyHandler.addCoins(600)
                default: break
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (products.count == 6) else { return }
        print("making purchase of product at index \(indexPath.item + 3*indexPath.section)")
        let payment = SKPayment(product: products[indexPath.item + 3*indexPath.section])
        SKPaymentQueue.default().add(payment)
    }
    
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
        if (products.count < 6) { return cell }
        if ((indexPath as NSIndexPath).section == 0) {
            (cell.contentView.viewWithTag(2) as! UIImageView).image = UIImage(named: "ChasmCrystal")
            (cell.contentView.viewWithTag(3) as! UILabel).text = products[indexPath.item].localizedTitle
            (cell.contentView.viewWithTag(4) as! UILabel).text = "\(products[indexPath.item].localizedPrice())"
        }
        else if ((indexPath as NSIndexPath).section == 1) {
            (cell.contentView.viewWithTag(2) as! UIImageView).image = UIImage(named: "Coin")
            (cell.contentView.viewWithTag(3) as! UILabel).text = products[indexPath.item+3].localizedTitle
            (cell.contentView.viewWithTag(4) as! UILabel).text = "\(products[indexPath.item+3].localizedPrice())"
        }
        return cell
    }
}


extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
    
}



