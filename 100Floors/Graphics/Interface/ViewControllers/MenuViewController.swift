//
//  MenuViewController
//  100Floors
//
//  Created by Sid Mani on 1/2/16.
//
//

import UIKit
import SpriteKit

var thisCharacter:ThisCharacter!
var defaultLevelHandler:LevelHandler!
var defaultMoneyHandler:MoneyHandler!
var defaultPurchaseHandler:InternalPurchaseHandler!

class MenuViewController: UIViewController {
    @IBOutlet weak var SettingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsButton.tintColor = ColorScheme.strokeColor
        
        thisCharacter = SaveData.currentSave.character
        defaultLevelHandler = SaveData.currentSave.levelHandler
        defaultMoneyHandler = SaveData.currentSave.moneyHandler
        defaultPurchaseHandler = SaveData.currentSave.purchaseHandler
        
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.ignoresSiblingOrder = true

        let scene = MenuScene(size: skView.bounds.size)
        skView.presentScene(scene)
        
    }
    
    @IBAction func loadLevelSelectVC() {
        let lsvc = storyboard!.instantiateViewControllerWithIdentifier("lsvc")
        lsvc.modalTransitionStyle = .CrossDissolve
        presentViewController(lsvc, animated: true, completion: nil)
    }
    
    @IBAction func exitToMainMenu(segue: UIStoryboardSegue) {
         (view as! SKView).scene?.paused = false
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
