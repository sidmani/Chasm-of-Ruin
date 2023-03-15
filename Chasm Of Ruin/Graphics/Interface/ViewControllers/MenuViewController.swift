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
    func didDismissModalVC(_ object:AnyObject?)
    func willDismissModalVC(_ object:AnyObject?)
}

var globalAudioPlayer:AVAudioPlayer?
var audioEnabled = true {
    didSet(newVal) {
        UserDefaults.standard.set(audioEnabled, forKey: "audioEnabled")
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
        if let audio = UserDefaults.standard.object(forKey: "audioEnabled") as? Bool {
            audioEnabled = audio
        }
        else {
            UserDefaults.standard.set(true, forKey: "audioEnabled")
        }
        if (audioEnabled) {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "unmute"), for: UIControlState())
        }
        else {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "mute"), for: UIControlState())
        }

        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsDrawCount = false
        skView.ignoresSiblingOrder = false

        let scene = MenuScene(size: skView.bounds.size)
        skView.presentScene(scene)
        
        setCurrencyLabels()
        CrystalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        CoinLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(5)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        self.view.viewWithTag(6)?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadCurrencyPurchaseView)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(setCurrencyLabels), name: "transactionMade" as NSNotification.Name, object: nil)
        startMusic()
    }
    
    func startMusic()
    {
        stopMusic()
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "sunnydaysahead", ofType: "mp3")!)
        do {
            globalAudioPlayer = try AVAudioPlayer(contentsOf:url)
            globalAudioPlayer!.numberOfLoops = -1
            globalAudioPlayer!.prepareToPlay()
            if (audioEnabled) {
                globalAudioPlayer!.play()
            }
        } catch {
            print("Error getting the audio file")
        }
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
    
    func stopMusic() {
        globalAudioPlayer?.stop()
    }

    func willDismissModalVC(_ object: AnyObject?) {
        (view as! SKView).scene?.isPaused = false
        if (audioEnabled) {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "unmute"), for: UIControlState())
        }
        else {
            (view.viewWithTag(11) as? UIButton)?.setImage(UIImage(named: "mute"), for: UIControlState())
        }
        view.subviews.forEach({(view) in view.isHidden = false})
    }
    
    func didDismissModalVC(_ object:AnyObject? = nil) {

    }
    
    func setCurrencyLabels() {
        CrystalLabel.text = "\(defaultMoneyHandler.getCrystals())"
        CoinLabel.text = "\(defaultMoneyHandler.getCoins())"
    }
    
    @IBAction func presentStore() {
        let svc = storyboard!.instantiateViewController(withIdentifier: "storeViewController") as! StoreViewController
        svc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.isHidden = true})
        present(svc, animated: true, completion: nil)
        menuScene?.isPaused = true

    }
    
    @IBAction func loadLevelSelectVC() {
        let lsvc = storyboard!.instantiateViewController(withIdentifier: "lsvc") as! LevelSelectViewController
        lsvc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.isHidden = true})
        present(lsvc, animated: true, completion: nil)
        (view as! SKView).scene?.isPaused = true
    }
    
    @IBAction func loadCredits() {
        let cvc = storyboard!.instantiateViewController(withIdentifier: "creditsVC") as! CreditsViewController
        cvc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.isHidden = true})
        present(cvc, animated: true, completion: nil)
        (view as! SKView).scene?.isPaused = true
    }
    
    @objc func loadCurrencyPurchaseView() {
        let cpvc = storyboard!.instantiateViewController(withIdentifier: "currencyPurchaseVC") as! CurrencyPurchaseViewController
        cpvc.dismissDelegate = self
        self.view.subviews.forEach({(view) in view.isHidden = true})
        self.present(cpvc, animated: true, completion: nil)
        (view as! SKView).scene?.isPaused = true
    }
}
