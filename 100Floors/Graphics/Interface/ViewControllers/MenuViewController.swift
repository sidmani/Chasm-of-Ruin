//
//  MenuViewController
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import UIKit
import SpriteKit
import AVFoundation
protocol ModalDismissDelegate {
    func didDismissModalVC(object:AnyObject?)
    func willDismissModalVC(object:AnyObject?)
}

var globalAudioPlayer:AVAudioPlayer?
var audioEnabled = true {
    didSet(newVal) {
        NSUserDefaults.standardUserDefaults().setBool(audioEnabled, forKey: "audioEnabled")
    }
}
class MenuViewController: UIViewController, ModalDismissDelegate {
    @IBOutlet weak var CrystalLabel: UILabel!
    @IBOutlet weak var CoinLabel: UILabel!
    var menuScene:MenuScene? {
        return (view as! SKView).scene as? MenuScene
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let audio = NSUserDefaults.standardUserDefaults().objectForKey("audioEnabled") as? Bool {
            audioEnabled = audio
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "audioEnabled")
        }
        if (audioEnabled) {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "unmute"), forState: .Normal)
        }
        else {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "mute"), forState: .Normal)
        }

        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.ignoresSiblingOrder = true

        let scene = MenuScene(size: skView.bounds.size)
        skView.presentScene(scene)
        
        setCurrencyLabels()
        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade", object: nil)
        startMusic()
    }
    
    func startMusic()
    {
        stopMusic()
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sunnydaysahead", ofType: "mp3")!)
        do {
            globalAudioPlayer = try AVAudioPlayer(contentsOfURL:url)
            globalAudioPlayer!.numberOfLoops = -1
            globalAudioPlayer!.prepareToPlay()
            if (audioEnabled) {
                globalAudioPlayer!.play()
            }
        } catch {
            print("Error getting the audio file")
        }
    }
    
    @IBAction func muteButtonPressed(sender: AnyObject) {
        if (audioEnabled) {
            audioEnabled = false
            globalAudioPlayer?.pause()
            (sender as? UIButton)?.setImage(UIImage(named: "mute"), forState: .Normal)
        }
        else {
            audioEnabled = true
            globalAudioPlayer?.play()
            (sender as? UIButton)?.setImage(UIImage(named: "unmute"), forState: .Normal)
        }
    }
    
    func stopMusic() {
        globalAudioPlayer?.stop()
    }

    func willDismissModalVC(object: AnyObject?) {
        (view as! SKView).scene?.paused = false
        if (audioEnabled) {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "unmute"), forState: .Normal)
        }
        else {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "mute"), forState: .Normal)
        }
        view.subviews.forEach({(view) in view.hidden = false})
    }
    
    func didDismissModalVC(object:AnyObject? = nil) {

    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
    
    @IBAction func presentStore() {
        let svc = storyboard!.instantiateViewControllerWithIdentifier("storeViewController") as! StoreViewController
        svc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.hidden = true})
        presentViewController(svc, animated: true, completion: nil)
        menuScene?.paused = true

    }
    
    @IBAction func loadLevelSelectVC() {
        let lsvc = storyboard!.instantiateViewControllerWithIdentifier("lsvc") as! LevelSelectViewController
        lsvc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.hidden = true})
        presentViewController(lsvc, animated: true, completion: nil)
        (view as! SKView).scene?.paused = true
    }
    
    @IBAction func loadCredits() {
        let cvc = storyboard!.instantiateViewControllerWithIdentifier("creditsVC") as! CreditsViewController
        cvc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.hidden = true})
        presentViewController(cvc, animated: true, completion: nil)
        (view as! SKView).scene?.paused = true
    }
    
    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewControllerWithIdentifier("currencyPurchaseVC") as! CurrencyPurchaseViewController
        cpvc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.hidden = true})
        self.presentViewController(cpvc, animated: true, completion: nil)
        (view as! SKView).scene?.paused = true
    }
}
