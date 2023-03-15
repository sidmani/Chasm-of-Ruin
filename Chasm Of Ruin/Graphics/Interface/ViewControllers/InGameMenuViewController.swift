//
//  InGameMenuViewController.swift
//  100Floors
//
//  Created by Sid Mani on 2/28/16.
//
//
import UIKit

class InGameMenuViewController: UIViewController, ModalDismissDelegate {
    
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!
    var dismissDelegate:ModalDismissDelegate?
    
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
        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        if (audioEnabled) {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "unmute"), for: UIControlState())
        }
        else {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "mute"), for: UIControlState())
        }

    }
    
    @IBAction func exit(_ sender: AnyObject) {
        self.dismissDelegate?.willDismissModalVC(nil)
        self.dismiss(animated: true, completion: {[unowned self] in
            self.dismissDelegate?.didDismissModalVC(nil)
        })
    }

    func willDismissModalVC(_ object: AnyObject?) {
        self.view.subviews.forEach({(view) in view.isHidden = false})
    }
    
    func didDismissModalVC(_ object: AnyObject?) {
        
    }
    
    @IBAction func loadCredits() {
        let cvc = storyboard!.instantiateViewController(withIdentifier: "creditsVC") as! CreditsViewController
        cvc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.isHidden = true})
        present(cvc, animated: true, completion: nil)
    }
    
    @IBAction func muteButtonPressed(_ sender: AnyObject) {
        if (audioEnabled) {
            audioEnabled = false
            globalAudioPlayer?.pause()
            (sender as? UIButton)?.setImage(UIImage(named: "mute"), for: UIControlState())
        }
        else {
            audioEnabled = true
            globalAudioPlayer?.play()
            (sender as? UIButton)?.setImage(UIImage(named: "unmute"), for: UIControlState())
        }
    }
    
    @IBAction func levelSelectPressed(_ sender: AnyObject) {
        let alert = storyboard!.instantiateViewController(withIdentifier: "alertViewController") as! AlertViewController
        alert.text = "Are you sure? All level progress will be lost..."
        alert.completion = {(response) in
            if (response) {
                self.performSegue(withIdentifier: "unwindToLevelSelect", sender: self)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func presentStore() {
        let svc = storyboard!.instantiateViewController(withIdentifier: "storeViewController") as! StoreViewController
        svc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.isHidden = true})
        present(svc, animated: true, completion: nil)
    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
    
    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewController(withIdentifier: "currencyPurchaseVC") as! CurrencyPurchaseViewController
        cpvc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.isHidden = true})
        self.present(cpvc, animated: true, completion: nil)
    }
}
