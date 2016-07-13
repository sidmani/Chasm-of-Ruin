//
//  StoreViewController.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/10/16.
//
//

import Foundation
import UIKit
class StoreViewController: UIViewController {
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!
    
    var alertCompletion: (Bool) -> () = {_ in }
    
    private var items = StoreViewController.getItems()
    
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
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView))
//        tapRecognizer.addTarget(self, action: #selector(loadCurrencyPurchaseView))
//        tapRecognizer.delegate = self
//        
        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
    }
    
    @IBAction func exit() {
        self.dismissViewControllerAnimated(true, completion: nil)
        presentingViewController?.view.subviews.forEach({(view) in view.hidden = false})
    }
    
    static func getItems() -> [Item] {
        //get list of all items (don't init them)
        //sort list by avg stats
        //exclude items which cannot be bought (coins & crystals == 0)
        //find player's position on list (avg stats / 500) & select 35 above/15 below
        //from those 50 select 15 randomly
        //add 3 random (available) consumables & health/mana potions
        //init all of them and return the array
        return []
    }
    
    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC")
        self.presentViewController(cpvc, animated: true, completion: nil)
    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}